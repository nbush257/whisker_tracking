import pims
import numpy as np
import matplotlib.pyplot as plt
from skimage.transform import (hough_line, hough_line_peaks)

from skimage.filter import canny
from skimage.draw import circle, polygon
import scipy.io.matlab as sio
from os.path import isfile
from sys import stdout

fname = 'N:\\3dTesting\\rat2015_15_JUN11_VG_B1_t01_Front.seq'


def manualTrack(image, bckMean, plotTGL=0):
    stopTrack = False
    plt.imshow(image, cmap='gray')
    rows, cols = image.shape
    plt.title('Click on the manipulator')
    manip = np.asarray(plt.ginput(1, timeout=0))
    if len(manip) == 0:
        y0 = []
        y1 = []
        thetaInit = []
        d = []
        stopTrack = True
        return y0, y1, thetaInit, d, stopTrack
    else:
        plt.show()

        roiRow, roiCol = circle(manip[0, 1], manip[0, 0], 30)
        # make sure the roi is not too big
        roiRow[roiRow >= rows] = rows - 1
        roiCol[roiCol >= cols] = cols - 1
        #
        imROI = 255 * np.ones_like(image)
        imROI[roiRow, roiCol] = image[roiRow, roiCol]
        BW = imROI < (bckMean - 50)

        h, theta, d = hough_line(BW)
        _, thetaInit, d = hough_line_peaks(h, theta, d, min_distance=1, num_peaks=1)
        y0 = (d - 0 * np.cos(thetaInit)) / np.sin(thetaInit)
        y1 = (d - cols * np.cos(thetaInit)) / np.sin(thetaInit)
        if len(y0) ==0:
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
    plt.close('all')
    return bckMean


def manipExtract(image, thetaInit, method='standard'):
    if np.issubdtype(image.dtype, 'bool'):
        edge = image
    else:
        edge = canny(image)

    rows, cols = image.shape
    h, theta, d = hough_line(edge, theta=np.arange(thetaInit - .2, thetaInit + .2, .03))
    _, angle, dist = hough_line_peaks(h, theta, d, min_distance=1, num_peaks=1)
    y0 = (dist - 0 * np.cos(angle)) / np.sin(angle)
    y1 = (dist - cols * np.cos(angle)) / np.sin(angle)

    return y0, y1, angle, dist


def getBW(y0, y1, image):
    from skimage.draw import polygon
    rows, cols = image.shape
    rr, cc = polygon(np.array([y0[0], y0[0], y1[0], y1[0]]), np.array([0, 0, cols - 15, cols + 15]), (rows, cols))
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
    lines.pop(0).remove()


def frameSeek(fid, n, Y0=[], Y1=[]):
    nFrames = fid.header_dict['allocated_frames']
    if n > nFrames:
        n = nFrames - 1
        print 'Reached the end of the video'
    cont = False
    image = fid.get_frame(n)
    rows, cols = image.shape

    plt.imshow(image, cmap='gray')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()
    if len(Y0) > 0 and len(Y1) > 0:
        plt.plot((0, cols), (Y0[n], Y1[n]), '-r')
    plt.title('Frame: %i' % n)
    plt.draw()

    while not cont:
        while True:
            uIn = raw_input('\nAdvance/Rewind how many frames? Default = +100. 0 exits: ')
            stdout.flush()
            try:
                if len(uIn) == 0:
                    uIn = 100
                    n += uIn
                else:
                    n += int(uIn)

                if uIn == '0':
                    cont = True
                break
            except:
                print 'Invalid input try again'


        if n > nFrames:
            n = nFrames - 1
            return n
            break
            plt.cla()
        image = fid.get_frame(n)
        plt.imshow(image, cmap='gray')
        plt.axis([0, cols, 0, rows])
        plt.gca().invert_yaxis()
        if len(Y0) != 0:
            plt.plot((0, cols), (Y0[n], Y1[n]), '-r')

        plt.title('Frame: %i' % n)
        plt.draw()

    return n


def getMask(image):
    rows, cols = image.shape
    plt.imshow(image, cmap='gray')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()

    plt.title('Outline the Mask')

    ii = 0
    pts = np.asarray(plt.ginput(1))[0]
    plt.plot(pts[0], pts[1], 'r*')
    plt.draw()
    cont = True
    while cont:
        ii += 1
        pt = np.asarray(plt.ginput(1))
        if len(pt) == 0:
            cont = False
        else:
            pt = pt[0]
            pts = np.vstack([pts, pt])
            plt.plot(pt[0], pt[1], 'r*')
            plt.draw()
    rr, cc = polygon(pts[:, 1], pts[:, 0], (rows, cols))
    mask = np.zeros_like(image, dtype='bool')
    mask[rr, cc] = 1
    return mask


def trackFirstView(fname):
    '''
    First Tracking
    need to write another script that takes into account previously
    tracked frames from the other view.
    '''
    outFName = fname[:-4] + '_manip.mat'

    fid = pims.open(fname)
    nFrames = fid.header_dict['allocated_frames']
    ht = fid.height
    wd = fid.width
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

    if isfile(outFName):
        loadTGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwriteTGL = raw_input('Overwrite old tracking? ([y],n)')
        if loadTGL == 'n':
            idx = frameSeek(fid, 0)
        else:
            fOld = sio.loadmat(outFName)
            D = fOld['D'][0]
            Th = fOld['Th'][0]
            Y0 = fOld['Y0'][0]
            Y1 = fOld['Y1'][0]
            try:
                mask = np.asarray(fOld['mask'], dtype='bool')
            except:
                mask = []
            idx = int(np.where(np.isfinite(D))[0][-1])
            print 'loaded data in. Index is at Frame %i\n' % idx
            idx = frameSeek(fid, idx, Y0, Y1)

        if overwriteTGL == 'n':
            suffix = 0
            while isfile(outFName):
                suffix += 1
                outFName = fname[:-4] + '_manip(%i).mat' % suffix
    else:
        idx = frameSeek(fid, 0)

    # Get your image
    image = fid.get_frame(idx)

    # if there is not a precomputed mask, get one now
    if len(mask) == 0:
        mask = getMask(image)

    # get the background intensity
    b = getBckgd(image)

    # do initial tracking of manipulator
    y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

    d0 = d
    plt.close('all')
    plt.figure()
    plt.imshow(image, cmap='gray')
    plt.draw()
    print '\nTracking manipulator\n\n ==================\n'

    while idx < nFrames:
        manTrack = False
        image = fid.get_frame(idx)
        image[~mask] = 255
        BW = getBW(y0, y1, image)
        T = BW < (b - 30)

        y0, y1, th, d = manipExtract(T, th)

        # exception handling
        if (len(d) == 0):
            print '\nNo edge detected, retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
        elif(np.mean(abs(d0 - d)) > 35):
            print '\nLarge distance detected, Retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        while stopTrack:
            idx = frameSeek(fid, idx, Y0, Y1)
            if idx >= (nFrames - 1):
                d = np.NaN
                y0 = np.NaN
                y1 = np.NaN
                th = np.NaN
                break
            image = fid.get_frame(idx)
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        d0 = d
        D[idx] = d
        Y0[idx] = y0
        Y1[idx] = y1
        Th[idx] = th

        # running average of last 5 theta and d:

        diffTh = np.mean(np.abs(np.diff(Th[idx - 20:idx + 1])))

        diffD = np.mean(np.abs(np.diff(D[idx - 20:idx + 1])))
        # stdTh = np.std(Th[-5:])
        # stdD = np.std(D[-5:])
        # if the angle doesn't change much
        # THIS IS NOT CURRENTLY WORKING WELL!!
        if diffTh < 10 ^ -5:
            manTrack = True
            # rebuild this so it looks at a 5 frame window into the past and says, hey, the last 5 are almost identical.
            print 'identical lines detected. Retrack'
            idx -= 5
            image = fid.get_frame(idx)
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
            D[idx] = d
            Y0[idx] = y0
            Y1[idx] = y1
            Th[idx] = th
            idx += 1

        # if the line is at an edge
        if diffD < 2 and (np.mean(D[idx - 20:idx + 1]) > 638 or np.mean(D[idx - 20:idx + 1]) < 3):
            print 'Close to edge'
            idx -= 20
            idx = frameSeek(fid, idx, Y0, Y1)
            if idx > (nFrames - 1):
                break
            else:
                image = fid.get_frame(idx)
                manTrack = True
                y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        # Verbose
        if (idx % 100 == 0):
            stdout.write('\rFrame %i of %i' % (idx, nFrames))
            stdout.flush()

        if (idx % 100 == 0) or manTrack or (idx % 1000 == 1):
            sanityCheck(y0, y1, image, idx)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            plt.close('all')
            sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})

        idx += 1
    # save at the end of the tracking

    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})


def trackSecondView(fname, otherView):
    ''' Follows a similar flow as trackFirstView, but takes in a mat file
    of the previously tracked manipulator to find where we need to track in a
    second view. Should be much faster.

    fname: a '.seq' that we want to track the manipulator in

    otherView: a '.mat' with the other view's tracking.

    '''

    # Set outPut
    outFName = fname[:-4] + '_manip.mat'
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
    fid = pims.open(fname)
    fPreviousTrack = sio.loadmat(otherView, squeeze_me=True, variable_names='D')
    tracked = np.isfinite(fPreviousTrack['D'])

    # Init Vars

    nFrames = fid.header_dict['allocated_frames']
    ht = fid.height
    wd = fid.width
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

    if isfile(outFName):
        loadTGL = raw_input('Load in previously computed manipulator? ([y]/n)')
        overwriteTGL = raw_input('Overwrite old tracking? ([y],n)')
        if loadTGL == 'n':
            idx = frameSeek(fid, 0)
        else:
            fOld = sio.loadmat(outFName, squeeze_me=True)
            D = fOld['D']
            Th = fOld['Th']
            Y0 = fOld['Y0']
            Y1 = fOld['Y1']
            mask = np.asarray(fOld['mask'], dtype='bool')

            idx = int(np.where(np.isfinite(D))[0][-1])
            print 'loaded data in. Index is at Frame %i\n' % idx
            idx = frameSeek(fid, idx, Y0, Y1)

        if overwriteTGL == 'n':
            suffix = 0
            while isfile(outFName):
                suffix += 1
                outFName = fname[:-4] + '_manip(%i).mat' % suffix
    else:
        firstTrackedFrame = np.where(tracked)[0][0]
        notTracked = np.invert(tracked)
        notTracked[:firstTrackedFrame] = False
        idx = np.where(notTracked)[0][0]
        idx = int(idx)
        # use the first not tracked frame as the first frame
        idx = frameSeek(fid, idx)

    # Get your image
    image = fid.get_frame(idx)

    # if there is not a precomputed mask, get one now

    if len(mask) == 0:
        mask = getMask(image)

    # get the background intensity
    b = getBckgd(image)

    # do initial tracking of manipulator
    y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
    d0 = d

    while idx < nFrames:
        if tracked[idx]:

            idx += int(np.where(notTracked[idx:])[0][0])
            image = fid.get_frame(idx)
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
        else:
            manTrack = False
            image = fid.get_frame(idx)
            image[~mask] = 255
            BW = getBW(y0, y1, image)
            T = BW < (b - 50)

            y0, y1, th, d = manipExtract(T, th)

        # exception handling
        if (len(d) == 0):
            print '\nNo edge detected, retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
        elif(np.mean(abs(d0 - d)) > 35):
            print '\nLarge distance detected, Retrack'
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        while stopTrack:
            idx = frameSeek(fid, idx, Y0, Y1)
            if idx >= (nFrames - 1):
                d = np.NaN
                y0 = np.NaN
                y1 = np.NaN
                th = np.NaN
                break
            image = fid.get_frame(idx)
            manTrack = True
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        d0 = d
        D[idx] = d
        Y0[idx] = y0
        Y1[idx] = y1
        Th[idx] = th

        # running average of last 5 theta and d:

        diffTh = np.mean(np.abs(np.diff(Th[idx - 20:idx + 1])))

        diffD = np.mean(np.abs(np.diff(D[idx - 20:idx + 1])))
        # stdTh = np.std(Th[-5:])
        # stdD = np.std(D[-5:])
        # if the angle doesn't change much
        # THIS IS NOT CURRENTLY WORKING WELL!!
        if diffTh < 10 ^ -5:
            manTrack = True
            # rebuild this so it looks at a 5 frame window into the past and says, hey, the last 5 are almost identical.
            print 'identical lines detected. Retrack'
            idx -= 5
            image = fid.get_frame(idx)
            y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)
            D[idx] = d
            Y0[idx] = y0
            Y1[idx] = y1
            Th[idx] = th
            idx += 1

        # if the line is at an edge
        if diffD < 2 and (np.mean(D[idx - 20:idx + 1]) > 637 or np.mean(D[idx - 20:idx + 1]) < 3):
            print 'Close to edge'
            idx -= 20
            idx = frameSeek(fid, idx, Y0, Y1)
            if idx > (nFrames - 1):
                break
            else:
                image = fid.get_frame(idx)
                manTrack = True
                y0, y1, th, d, stopTrack = manualTrack(image, b, plotTGL=0)

        # Verbose
        if (idx % 100 == 0):
            stdout.write('\rFrame %i of %i' % (idx, nFrames))
            stdout.flush()

        if (idx % 100 == 0) or manTrack or (idx % 1000 == 1):
            sanityCheck(y0, y1, image, idx)

        # Refresh and save every 1000 frames
        if (idx % 1000 == 0):
            plt.close('all')
            sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})

        idx += 1

    sio.savemat(outFName, {'D': D, 'Y0': Y0, 'Th': Th, 'Y1': Y1, 'mask': mask, 'b': b})
