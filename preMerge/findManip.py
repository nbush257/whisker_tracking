import pims
import numpy as np
import matplotlib
matplotlib.use('GTkAgg')
import matplotlib.pyplot as plt
from skimage.transform import (hough_line, hough_line_peaks)

from skimage.feature import canny
from skimage.draw import circle, polygon
import scipy.io.matlab as sio
from os.path import isfile
import os
from sys import stdout
import sys

def manualTrack(image, bckMean, idx=-1, plotTGL=0):
    contrast = 25
    plt.cla()

    def getROI_from_click(manip,radius=30):
        roiRow, roiCol = circle(manip[0, 1], manip[0, 0], radius)
        # make sure the roi is not too big
        roiRow[roiRow >= rows] = rows - 1
        roiCol[roiCol >= cols] = cols - 1
        #
        imROI = 255 * np.ones_like(image)
        imROI[roiRow, roiCol] = image[roiRow, roiCol]
        BW = imROI < (bckMean - contrast)
        return BW

    stopTrack = False
    plt.imshow(image, cmap='gray')
    rows, cols = image.shape
    plt.title('Click on the manipulator; Frame: %i' % idx)
    manip = np.asarray(plt.ginput(1, timeout=0))


    if len(manip) == 0:
        y0 = []
        y1 = []
        thetaInit = []
        d = []
        stopTrack = True
        return y0, y1, thetaInit, d, stopTrack
    else:
        plt.draw()
        plt.pause(.001)
        BW = getROI_from_click(manip)

        h, theta, d = hough_line(BW)
        try:
            _, thetaInit, d = hough_line_peaks(h, theta, d, min_distance=1, num_peaks=1)
        except:
            print 'No manipulator found at click. Try again'
            BW = getROI_from_click(manip,50)



        y0 = (d - 0 * np.cos(thetaInit)) / np.sin(thetaInit)
        y1 = (d - cols * np.cos(thetaInit)) / np.sin(thetaInit)
        if len(y0) == 0:
            stopTrack = True

        if plotTGL:
            plt.imshow(image)
            plt.plot((0, cols), (y0, y1), '-r')
            plt.axis([0, 640, 0, 480])
            plt.draw()
            plt.close('all')
        plt.close('all')
        thetaInit = np.mean(thetaInit)
        return y0, y1, thetaInit, d, stopTrack


def getBckgd(image):
    # get background measure
    plt.imshow(image, cmap='gray')
    plt.title('Click on background near manip')
    bckgd = np.asarray(plt.ginput(1))
    plt.draw()
    bckgdR, bckgdC = circle(bckgd[0, 1], bckgd[0, 0], 5)
    bckMean = np.mean(image[bckgdR, bckgdC])
    plt.cla()
    return bckMean


def manipExtract(image, thetaInit, method='standard'):
    if np.issubdtype(image.dtype, 'bool'):
        edge = image
    else:
        edge = canny(image)

    rows, cols = image.shape

    h, theta, d = hough_line(edge, theta=np.arange(thetaInit - .2, thetaInit + .2, .01))

    try:
        _, angle, dist = hough_line_peaks(h, theta, d, min_distance=1, num_peaks=1)
        y0 = (dist - 0 * np.cos(angle)) / np.sin(angle)
        y1 = (dist - cols * np.cos(angle)) / np.sin(angle)
    except IndexError: # i think this error is being thrown if the manipulator is not found?
        y0 = np.NaN
        y1 = np.NaN
        angle = np.NaN
        dist = np.NaN

    return y0, y1, angle, dist


def getBW(y0, y1, image):
    from skimage.draw import polygon
    bounds = 15

    rows, cols = image.shape

    rr, cc = polygon(np.array([y0[0], y0[0], y1[0], y1[0]]), np.array([0, 0, cols - bounds, cols + bounds]), (rows, cols))


    BW = np.zeros_like(image, dtype='bool')
    BW[rr, cc] = 1
    imROI = 255 * np.ones_like(image)
    imROI[BW] = image[BW]

    return imROI


def sanityCheck(y0, y1, image, frameNum=0):
    plt.cla()
    plt.imshow(image, cmap='gray')
    rows, cols = image.shape
    lines = plt.plot((0, cols), (y0, y1), '-r')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()
    plt.title('Frame: %i' % frameNum)
    plt.draw()
    plt.pause(.0001)
    lines.pop(0).remove()
def eraseFuture(Y0, Y1, Th, D, idx):
    Y0[idx:] = np.NaN
    Y1[idx:] = np.NaN
    D[idx:] = np.NaN
    Th[idx:] = np.NaN
    return Y0, Y1, Th, D

def frameSeek(fid, idx, Y0=[], Y1=[],notTracked=[],Th=[],D=[]):
    nFrames= len(fid)
    plt.clf()
    # If you have given a bool vector of frames that have not been tracked, skips the manual portion and goes to the next untracked frame
    if len(notTracked) > 0:
        if len(np.where(notTracked[idx:])[0]) > 0:
            idx += int(np.where(notTracked[idx:])[0][0])

    # if you are past the last frame, set n to the last frame.
    if idx > nFrames:
        idx = nFrames - 1
        print 'Reached the end of the video'
    cont = False

    image = fid.get_frame(idx)
    if len(image.shape) == 3:
        image = image[:,:,0]

    rows, cols = image.shape

    plt.imshow(image, cmap='gray')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()
    if len(Y0) > 0 and len(Y1) > 0:
        plt.plot((0, cols), (Y0[idx], Y1[idx]), '-r')
    plt.title('Frame: %i' % idx)
    plt.draw()
    plt.pause(0.001)

    while not cont:
        while True:
            # skip to next not tracked section if it exists
            if len(notTracked) > 0:
                if len(np.where(notTracked[idx:])[0])>0 and int(np.where(notTracked[idx:])[0][0]) > 1:
                    print '\nJumped to next not tracked section'
                    idx += int(np.where(notTracked[idx:])[0][0])
                    break

            uIn = raw_input('\nAdvance/Rewind how many frames? Default = +100. 0 exits, \'e\' erases future tracking: ')
            stdout.flush()
            try:
                if len(uIn) == 0:
                    uIn = 100
                    
                elif uIn == '0':
                    cont = True
                elif uIn == 'e':
                    eraseFuture(Y0, Y1, Th, D, idx)
                    uIn = 0
                else:
                    uIn = int(uIn)

            except:
                print 'Invalid input try again'
                break
            
            # If we go backward, mark anything between last index and new index as not tracked
            if uIn < 0:
                notTracked[idx+uIn:idx] = True

            # add uIn to current frame index                
            idx += int(uIn)
            
            # boundary conditions on the index
            if idx >= nFrames:
                idx = nFrames-1
                plt.cla()
                return idx
                break

            if idx<=0:
                idx = 0
                break

            # mark all points up to the current index as tracked within the function. This needs to occur outside the function too
            notTracked[:idx] = False
            break # break the while loop to update the image

        image = fid.get_frame(idx)
        if len(image.shape) == 3:
            image = image[:,:,0]

        plt.cla()
        plt.imshow(image, cmap='gray')
        plt.axis([0, cols, 0, rows])
        plt.gca().invert_yaxis()
        if len(Y0) != 0:
            plt.plot((0, cols), (Y0[idx], Y1[idx]), '-r')

        plt.title('Frame: %i' % idx)
        plt.draw()
        plt.pause(0.001)

    return idx


def getMask(image):
    rows, cols = image.shape
    plt.imshow(image, cmap='gray')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()

    plt.title('Outline the Mask. Left to add, right to remove, middle to continue')
    plt.draw()
    plt.pause(0.001)
    pts = np.asarray(plt.ginput(-1,timeout=0,show_clicks=True))
    rr, cc = polygon(pts[:, 1], pts[:, 0], (rows, cols))
    mask = np.zeros_like(image, dtype='bool')
    mask[rr, cc] = 1
    plt.close('all')
    return mask




# these two are the functions to run from the shell:
def trackFirstView(fname):
    '''
    First Tracking
    need to write another script that takes into account previously
    tracked frames from the other view.
    '''
    plt.close('all')
    contrast = 25
    outFName = fname[:-4] + '_manip.mat'
    outFName_temp = fname[:-4] + '_manip_temp.mat'
    fname_ext = os.path.splitext(fname)[-1]

    print 'Loading Video...'

    if fname_ext == '.seq':
        fid = pims.NorpixSeq(fname)
        nFrames = fid.header_dict['allocated_frames']
        ht = fid.height
        wd = fid.width
    else:
        fid = pims.Video(fname)
        ht = fid.frame_shape[1]
        wd = fid.frame_shape[0]
        nFrames= len(fid)
    print 'Loaded!'

    print 'ht: %i \nwd: %i \nNumber of Frames: %i' % (ht, wd, nFrames)
    # init output vars
    D = np.empty(nFrames, dtype='float32')
    D[:] = np.nan

    Y0 = np.empty(nFrames, dtype='float32')
    Y0[:] = np.nan

    Y1 = np.empty(nFrames, dtype='float32')
    Y1[:] = np.nan

    Th = np.empty(nFrames, dtype='float32')
    Th[:] = np.nan

    mask = []
    # if the output file is found, check to load it in and start where you left off
    # otherwise start from the beginning

    if isfile(outFName_temp):
        loadTGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwriteTGL = raw_input('Overwrite old tracking? ([y],n)')

        if loadTGL == 'n':
            idx = frameSeek(fid, 0, notTracked=np.ones(nFrames,dtype='bool'))
        else:
            fOld = sio.loadmat(outFName_temp)
            D = fOld['D'][0]
            Th = fOld['Th'][0]
            Y0 = fOld['Y0'][0]
            Y1 = fOld['Y1'][0]
            
            idx = int(np.where(np.isfinite(D))[0][-1])
            notTracked = np.ones(nFrames,dtype='bool')
            notTracked[0:idx] = False
            print 'loaded data in. Index is at Frame %i\n' % idx
            idx = frameSeek(fid, idx, Y0, Y1,notTracked=notTracked,Th=Th,D=D)
            Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)

        if overwriteTGL == 'n':
            suffix = 0
            while isfile(outFName_temp):
                suffix += 1
                outFName_temp = fname[:-4] + '_manip(%i).mat' % suffix
    else:
        notTracked = np.ones(nFrames,dtype='bool')
        idx = frameSeek(fid, 0,notTracked=np.ones(nFrames,dtype='bool'))

    # Get your image
    image = fid.get_frame(idx)
    if len(image.shape) == 3:
        image = image[:,:,0]

    # if there is not a precomputed mask, get one now
    if len(mask) == 0:
        mask = getMask(image)
        
    # get the background intensity
    b = getBckgd(image)

    # do initial tracking of manipulator
    y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)

    d0 = d
    plt.close('all')
    plt.figure()
    plt.imshow(image, cmap='gray')
    plt.draw()
    print '\nTracking manipulator\n\n ==================\n'

    while idx < nFrames:
        try:
            manTrack = False
            
            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]

            image[~mask] = 255
            BW = getBW(y0, y1, image)
            T = BW < (b - contrast)

            y0, y1, th, d = manipExtract(T, th)

            # exception handling
            if (len(d) == 0) or np.isnan(d):
                print '\nNo edge detected, retrack'
                manTrack = True
                y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)
            elif(abs(D[idx-1] - d) > 75): # Play with this condition if tracking is problematic
                print '\nLarge distance detected, Retrack'
                manTrack = True
                y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)

            while stopTrack:
                idx = frameSeek(fid, idx, Y0, Y1,notTracked=notTracked,Th=Th,D=D)
                # end of video condition
                if idx >= (nFrames - 1):
                    d = np.NaN
                    y0 = np.NaN
                    y1 = np.NaN
                    th = np.NaN
                    break

                Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)
                image = fid.get_frame(idx)
                if len(image.shape) == 3:
                    image = image[:,:,0]
                manTrack = True
                y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)

            d0 = d
            D[idx] = d
            Y0[idx] = y0
            Y1[idx] = y1
            Th[idx] = th
            # If user throws a ctrl-c then get a new mask and manual track
        except KeyboardInterrupt:
            idx = frameSeek(fid, idx, Y0, Y1,notTracked=notTracked,Th=Th,D=D)
            Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)
            mask = getMask(image)
            b = getBckgd(image)
            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)


      
        # Verbose
        if (idx % 100 == 0):
            stdout.write('\rFrame %i of %i' % (idx, nFrames))
            stdout.flush()

        if (idx % 100 == 0) or manTrack or (idx % 1000 == 1):
            sanityCheck(y0, y1, image, idx)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})

        idx += 1
    # save at the end of the tracking

    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})
    print 'Tracking Done!\n'


def trackSecondView(fname, otherView):
    ''' Follows a similar flow as trackFirstView, but takes in a mat file
    of the previously tracked manipulator to find where we need to track in a
    second view. Should be much faster.

    fname: a '.seq' that we want to track the manipulator in

    otherView: a '.mat' with the other view's tracking.

    '''
    # init local params
    contrast = 25
    d_thresh = 75
    # Set output
    outFName = fname[:-4] + '_manip.mat'
    outFName_temp = fname[:-4] + '_manip_temp.mat'
    # First check if the names make sense
    # Check new filename for front and top
    uIn = 'y'
    if fname.find('Front') > 0:
        currentView = 'Front'
        currentBase = fname[:fname.find('Front')]
    elif fname.find('Top') > 0:
        currentView = 'Top'
        currentBase = fname[:fname.find('Top')]
    else:
        uIn = raw_input('It looks like this file is the wrong type. Continue anyhow? (y,[n])')

    if uIn != 'y':
        return
    
    # Check old filename for front and top
    if otherView.find('Front') > 0:
        lastView = 'Front'
        lastBase = otherView[:otherView.find('Front')]

    elif otherView.find('Top') > 0:
        lastView = 'Top'
        lastBase = otherView[:otherView.find('Top')]
    else:
        uIn = raw_input('It looks like this file is the wrong type. Continue anyhow? (y,[n])')

    if uIn != 'y':
        return

    # check for consistency between basenames if front and top were found
    if (uIn != 'y') and (currentBase != lastBase) and (currentView != lastView):
        uIn = raw_input('\nBase file names do not match:\n\n%s\n%s \n continue(y/[n])\n' % (currentBase, lastBase))

    if uIn != 'y':
        return

    # Load data files
    print 'Loading Video...'
    if fname_ext == '.seq':
        fid = pims.NorpixSeq(fname)
        nFrames = fid.header_dict['allocated_frames']
        ht = fid.height
        wd = fid.width
    else:
        fid = pims.Video(fname)
        ht = fid.frame_shape[0]
        wd = fid.frame_shape[1]
        nFrames= len(fid)
    print 'Video Loaded!'

    f_previous_track = sio.loadmat(otherView, squeeze_me=True, variable_names='D')
    tracked_previous_view = np.isfinite(f_previous_track['D'])

    print 'ht: %i \nwd: %i \nNumber of Frames: %i' % (ht, wd, nFrames)
    # init output vars
    D = np.empty(nFrames, dtype='float32')
    D[:] = np.nan

    Y0 = np.empty(nFrames, dtype='float32')
    Y0[:] = np.nan

    Y1 = np.empty(nFrames, dtype='float32')
    Y1[:] = np.nan

    Th = np.empty(nFrames, dtype='float32')
    Th[:] = np.nan

    mask = []

    # Use other view to start the tracking
    first_tracked_frame = np.where(tracked_previous_view)[0][0]
    not_tracked_previous_view = np.invert(tracked_previous_view)
    idx = int(first_tracked_frame)
    not_tracked_either_view = not_tracked_previous_view
        
    if isfile(outFName_temp):
        load_TGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwrite_TGL = raw_input('Overwrite old tracking? ([y],n)')
        if load_TGL == 'n':
            idx = frameSeek(fid, idx, notTracked=not_tracked_either_view,Th=Th,D=D)
            not_tracked_either_view[:idx] = False
        else:
            fOld = sio.loadmat(outFName_temp, squeeze_me=True)
            D = fOld['D']
            Th = fOld['Th']
            Y0 = fOld['Y0']
            Y1 = fOld['Y1']
            not_tracked_either_view = fOld['not_tracked_either_view']
            idx = frameSeek(fid, idx, notTracked=not_tracked_either_view)

            print 'loaded data in. Index is at Frame %i\n' % idx
            Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)

            not_tracked_either_view[:idx] = False

        if overwrite_TGL == 'n':
            suffix = 0
            while isfile(outFName_temp):
                suffix += 1
                outFName_temp = fname[:-4] + '_manip(%i).mat' % suffix
    else:
        # if no tracking done on this file yet, use the previous view tracking as the notTracked
        not_tracked_either_view = not_tracked_previous_view
        idx = frameSeek(fid, idx, notTracked=not_tracked_previous_view)
        Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)


    # Get your image
    image = fid.get_frame(idx)
    if len(image.shape) == 3:
        image = image[:,:,0]

    # if there is not a precomputed mask, get one now
    if len(mask) == 0:
        mask = getMask(image)

    # get the background intensity
    b = getBckgd(image)

    # do initial tracking of manipulator
    y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)
    d0 = d

    while idx < nFrames:
        if not np.any(not_tracked_either_view[idx:]): # if the rest of the video has been tracked, save and quit
            break
        if not not_tracked_either_view[idx]:# if the current frame has been tracked, go to the next frame that hasn't been tracked
            man_track = True
            idx += int(np.where(not_tracked_either_view[idx:])[0][0])
            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)
        else:# if the current frame has not been tracked, track it
            man_track = False
            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]
            image[~mask] = 255
            BW = getBW(y0, y1, image)
            T = BW < (b - contrast)

            y0, y1, th, d = manipExtract(T, th)

        # exception handling
        if (len(d) == 0):
            print '\nNo edge detected, retrack'

            man_track = True
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)


        elif(abs(D[idx-1] - d) > d_thresh):
            print '\nLarge distance detected, Retrack'
            man_track = True
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)


        while stopTrack:

            idx = frameSeek(fid, idx, Y0, Y1, notTracked=not_tracked_either_view,Th=Th,D=D)
            if idx >= (nFrames - 1):
                d = np.NaN
                y0 = np.NaN
                y1 = np.NaN
                th = np.NaN
                break
            Y0, Y1, Th, D = eraseFuture(Y0, Y1, Th, D, idx)

            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]
            man_track = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx, plotTGL=0)


        d0 = d
        D[idx] = d
        Y0[idx] = y0
        Y1[idx] = y1
        Th[idx] = th
        not_tracked_either_view[:idx] = False

        # Verbose
        if (idx % 100 == 0):
            stdout.write('\rFrame %i of %i' % (idx, nFrames))
            stdout.flush()

        if (idx % 100 == 0) or man_track or (idx % 1000 == 1):
            sanityCheck(y0, y1, image, idx)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            plt.close('all')
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

        
        idx += 1


    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})
    print 'Tracking Done!\n'

    plt.close('all')

if __name__ == '__main__':
    if len(sys.argv)==2:
        trackFirstView(sys.argv[1])
    elif len(sys.argv)==3:
        trackSecondView(sys.argv[1], sys.argv[2])
