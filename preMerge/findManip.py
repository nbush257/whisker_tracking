import pims
import numpy as np
import matplotlib
matplotlib.use('GTkAgg')
import matplotlib.pyplot as plt
from skimage.transform import (hough_line, hough_line_peaks)
from skimage.feature import canny
from skimage.draw import circle, polygon,line
from skimage.morphology import dilation,disk,skeletonize,binary_dilation,rectangle
from skimage.segmentation import mark_boundaries
import scipy.io.matlab as sio
from os.path import isfile
import os
from sys import stdout
import sys

key_pressed = ''
listen_to_keyboard = False
stop_all = False

def dil_skel(BW,radius=3):

    selem_disk = disk(radius)
    BW = dilation(BW,selem_disk)
    BW = skeletonize(BW)
    return BW

def get_input_event():
#    print threading.currentThread().getName(), ' wants to get input.'
    if not input_event.is_set():
#       print threading.currentThread().getName(), ' is waiting for keypress event'
        input_event.wait()
        input_event.clear()
#       print threading.currentThread().getName(), ' stopped waiting?'
    input_event.clear()
#    print threading.currentThread().getName(), ' locked the event.'

def manualTrack(image, bckMean, idx=-1):
    contrast = 17.
    radius = 30.

    plt.clf()
    stopTrack = False
    plt.imshow(image, cmap='gray')
    rows, cols = image.shape
    plt.title('Click on the manipulator; Frame: %i' % idx)
    plt.draw()
    plt.pause(0.001)
    manip = np.asarray(plt.ginput(1, timeout=0))
    


    if len(manip) == 0:
        y0 =np.NaN
        y1 = np.NaN
        thetaInit = np.NaN
        d = np.NaN
        stopTrack = True
        return y0, y1, thetaInit, d, stopTrack
    else:

        roiRow, roiCol = circle(manip[0, 1], manip[0, 0], radius)
        # make sure the roi is not too big
        roiRow[roiRow >= rows] = rows - 1
        roiCol[roiCol >= cols] = cols - 1
        #
        imROI = 255 * np.ones_like(image)
        imROI[roiRow, roiCol] = image[roiRow, roiCol]
        BW = imROI < (bckMean - contrast)
        BW = dil_skel(BW)
        h, theta, d = hough_line(BW)
        try:
            _, thetaInit, d = hough_line_peaks(h, theta, d, min_distance=1, num_peaks=1)
        except:
            y0 =np.NaN
            y1 = np.NaN
            thetaInit = np.NaN
            d = np.NaN
            stopTrack = True
            return y0, y1, thetaInit, d, stopTrack            

        y0 = (d - 0 * np.cos(thetaInit)) / np.sin(thetaInit)
        y1 = (d - cols * np.cos(thetaInit)) / np.sin(thetaInit)
        if len(y0) == 0:
            stopTrack = True

        plt.clf()
        thetaInit = np.mean(thetaInit)
        return y0, y1, thetaInit, d, stopTrack


def getBckgd(image):
    # get background measure
    if len(image.shape) == 3:
        image = image[:, :, 0] 

    plt.imshow(image, cmap='gray')
    plt.title('Click on background near manip')
    plt.draw()
    plt.pause(0.001)
    bckgd = np.asarray(plt.ginput(1))
    plt.draw()
    plt.pause(0.001)
    bckgdR, bckgdC = circle(bckgd[0, 1], bckgd[0, 0], 5)
    bckMean = np.mean(image[bckgdR, bckgdC])
    plt.clf()
    return bckMean


def manipExtract(image, thetaInit, method='standard'):
    if np.issubdtype(image.dtype, 'bool'):
        edge = image
    else:
        edge = canny(image)

    rows, cols = image.shape

    h, theta, d = hough_line(edge, theta=np.arange(thetaInit - .3, thetaInit + .3, .01))

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

    rows, cols = image.shape
    # get a one pixel line where the manipulator is
    rr,cc = line(int(y0),0,int(y1),cols)
    
    # remove indices which are out of bounds of the image
    idx = np.any(np.vstack(((rr < 0),(rr >= rows),(cc < 0),(cc >= cols))),0)
    rr = rr[~idx]
    cc = cc[~idx]

    # create a mask for where the manipulator was 
    BW = np.zeros_like(image, dtype='bool')
    BW[rr, cc] = 1
    BW = binary_dilation(BW,selem)

    imROI = 255 * np.ones_like(image)
    imROI[BW] = image[BW]

    return imROI,BW


def sanityCheck(y0, y1, image, frameNum=0,BW = []):
    plt.cla()
    plt.imshow(image, cmap='gray')
    plt.imshow(BW)
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
    if idx >= nFrames:
        idx = nFrames-1
        print 'Reached the end of the video'
        return idx
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

    get_input_event()
    while not cont:
        while True:
            # skip to next not tracked section if it exists
            if len(notTracked) > 0:
                if len(np.where(notTracked[idx:])[0])>0 and int(np.where(notTracked[idx:])[0][0]) > 1:
                    print '\nJumped to next not tracked section'
                    idx += int(np.where(notTracked[idx:])[0][0])
                    break

            uIn = raw_input('\nAdvance/Rewind how many frames? Default = +100. 0 exits, \'e\' erases future tracking'
                            ': ')
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

        plt.clf()
        plt.imshow(image, cmap='gray')
        plt.axis([0, cols, 0, rows])
        plt.gca().invert_yaxis()
        if len(Y0) != 0:
            plt.plot((0, cols), (Y0[idx], Y1[idx]), '-r')

        plt.title('Frame: %i' % idx)
        plt.draw()
        plt.pause(0.001)

    input_event.set()
    return idx


def getMask(image, mask=None):
    if mask is not None:
        image = mark_boundaries(image, mask)
        if len(image.shape) == 3:
            image = image[:, :, 0]

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
    plt.clf()
    return mask


# these two are the functions to run from the shell:
def trackFirstView(fname):
    '''
    First Tracking
    need to write another script that takes into account previously
    tracked frames from the other view.
    '''

    global listen_to_keyboard, key_pressed, stop_all,selem
    plt.close('all')
    contrast = 15
    bounds = 30
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
    #
    #  init output vars
    D = np.empty(nFrames, dtype='float32')
    D[:] = np.nan

    Y0 = np.empty(nFrames, dtype='float32')
    Y0[:] = np.nan

    Y1 = np.empty(nFrames, dtype='float32')
    Y1[:] = np.nan

    Th = np.empty(nFrames, dtype='float32')
    Th[:] = np.nan
    b = []

    mask = []
    selem = rectangle(bounds,bounds)
    # if the output file is found, check to load it in and start where you left off
    # otherwise start from the beginning

    if isfile(outFName_temp):

        get_input_event()
        loadTGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwriteTGL = raw_input('Overwrite old tracking? ([y],n)')
        input_event.set()

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

    if idx >= nFrames-1:
        plt.close('all')
        sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})
        print 'Tracking Done!\n'
        return

    # if there is not a precomputed mask, get one now
    if len(mask) == 0:
        mask = getMask(image)
        
    # get the background intensity
    b = getBckgd(image)

    # do initial tracking of manipulator
    y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)

    d0 = d
    plt.clf()
    plt.imshow(image, cmap='gray')
    plt.draw()
    print '\nTracking manipulator\n\n ==================\n'

    while idx < nFrames:
        listen_to_keyboard = True

        if key_pressed == 'p':
            print 'Tracking paused'
            while key_pressed == 'p':
                continue
            print 'Tracking continued!'
        elif key_pressed == 'q':
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})
            return
        elif key_pressed == 'm':
            print 'Jumping to manual labelling'
            stopTrack = True
            listen_to_keyboard = False
            key_pressed = ''
        elif key_pressed == 'b':
            listen_to_keyboard = False
            image = fid.get_frame(idx)
            mask = getMask(image, mask)
            key_pressed = ''
        elif key_pressed == 'c':
            b = getBckgd(image)
            key_pressed = ''



        manTrack = False
        
        image = fid.get_frame(idx)
        if len(image.shape) == 3:
            image = image[:,:,0]

        image[~mask] = 255
        imROI,BW = getBW(y0, y1, image)
        T = imROI < (b - contrast)
        # T = dil_skel(T,2)
        y0, y1, th, d = manipExtract(T, th)
        # exception handling
        if np.isnan(d) or (len(d) == 0):
            listen_to_keyboard = False
            print '\nNo edge detected, retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)
        elif(abs(D[idx-1] - d) > 75): # Play with this condition if tracking is problematic
            listen_to_keyboard = False
            print '\nLarge distance detected, Retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)

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
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)
            # if not stopTrack:
            #     redefine_mask = raw_input('Redefine mask? ([y]/n)')
            #     if redefine_mask == 'y':
            #         image = fid.get_frame(idx)
            #         if len(image.shape) == 3:
            #             image = image[:, :, 0]
            #         mask = getMask(image, mask)
            #         redefine_mask = ''

        d0 = d
        D[idx] = d
        Y0[idx] = y0
        Y1[idx] = y1
        Th[idx] = th


      
        # Verbose
        if (idx % 100 == 0):
            stdout.write('\rFrame %i of %i' % (idx, nFrames))
            stdout.flush()

        if (idx % 100 == 0) or manTrack or (idx % 1000 == 1):
            sanityCheck(y0, y1, image, idx,BW=BW)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})

        idx += 1
    # save at the end of the tracking

    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})
    print 'Tracking Done!\n'
    listen_to_keyboard = True
    stop_all = True


def trackSecondView(fname, otherView):
    pass

    ''' Follows a similar flow as trackFirstView, but takes in a mat file
    of the previously tracked manipulator to find where we need to track in a
    second view. Should be much faster.

    fname: a '.seq' that we want to track the manipulator in

    otherView: a '.mat' with the other view's tracking.

    '''
    # init local params
    contrast = 15
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
        get_input_event()
        uIn = raw_input('It looks like this file is the wrong type. Continue anyhow? (y,[n])')
        input_event.set()

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
        get_input_event()
        uIn = raw_input('It looks like this file is the wrong type. Continue anyhow? (y,[n])')
        input_event.set()

    if uIn != 'y':
        return

    # check for consistency between basenames if front and top were found
    if (uIn != 'y') and (currentBase != lastBase) and (currentView != lastView):
        get_input_event()
        uIn = raw_input('\nBase file names do not match:\n\n%s\n%s \n continue(y/[n])\n' % (currentBase, lastBase))
        input_event.set()

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
        get_input_event()
        load_TGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwrite_TGL = raw_input('Overwrite old tracking? ([y],n)')
        input_event.set()
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
    y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)
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
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)
        else:# if the current frame has not been tracked, track it
            man_track = False
            image = fid.get_frame(idx)
            if len(image.shape) == 3:
                image = image[:,:,0]
            image[~mask] = 255
            imROI,BW = getBW(y0, y1, image)
            T = BW < (b - contrast)

            y0, y1, th, d = manipExtract(T, th)

        # exception handling
        if (len(d) == 0):
            print '\nNo edge detected, retrack'

            man_track = True
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)


        elif(abs(D[idx-1] - d) > d_thresh):
            print '\nLarge distance detected, Retrack'
            man_track = True
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)


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
            y0, y1, th, d, stopTrack = manualTrack(image, b, idx=idx)


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
            sanityCheck(y0, y1, image, idx,BW=BW)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            plt.close('all')
            sio.savemat(outFName_temp, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})

        
        idx += 1


    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b,'not_tracked_either_view':not_tracked_either_view})
    print 'Tracking Done!\n'
    stop_all = True
    plt.close('all')

def check_key_presses():
    global key_pressed, listen_to_keyboard
    key_pressed = ''
    # Give the Main thread a chance to run its initialization
    time.sleep(1)
    while True:
        if not listen_to_keyboard:
            if stop_all:
                break
            time.sleep(0.1)
            continue
        get_input_event()
        if stop_all:
           break
        key_pressed = raw_input('Press any key to continue (or q=quit, p=pause, m=manual, b=new background/mask):\n')
        if key_pressed == 'q':
            break
        input_event.set()

if __name__ == '__main__':
    import threading, time

    input_event = threading.Event()
    input_event.set()

    key_press_check = threading.Thread(target=check_key_presses)
    key_press_check.start()
    if len(sys.argv)==2:
        trackFirstView(sys.argv[1])
    elif len(sys.argv)==3:
        trackSecondView(sys.argv[1], sys.argv[2])

    listen_to_keyboard = True
    stop_all = True
    input_event.set()