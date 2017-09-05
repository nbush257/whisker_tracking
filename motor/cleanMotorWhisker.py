import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import pims
from scipy.spatial import distance
import csv
from scipy.interpolate import interp1d
import re
import glob
sys.path.append(
    r'C:\Users\nbush257\Documents\hartmann_lab\proc\whisk\python')
sys.path.append(
    r'C:\Users\nbush257\Documents\hartmann_lab\proc\whiskerTracking\preMerge')
from trace_2 import Load_Whiskers, Save_Whiskers
# from findManip import getMask
from statsmodels.nonparametric.smoothers_lowess import lowess

# ============================================ #


def sortWhisker(w, direction='y'):
    '''
    Sorts every trace in every frame by the coordinate given.
    Whisker files should be sorted by X automatically.
    This func is particularly useful if the whisker is vertical
    '''

    direction = direction.lower()
    if direction not in ('x', 'y'):
        raise ValueError('Improper sort direction')

    # loop over frames
    for frame in w.itervalues():
        # loop over each trace in that frame
        for trace in frame.itervalues():
            if direction == 'y':
                # order by ascending y coord (top to bottom)
                idx = trace.y.argsort()
                trace.x = trace.x[idx]
                trace.y.sort()
            else:
                # order by ascending X coord. (left to right)
                idx = trace.x.argsort()
                trace.y = trace.y[idx]
                trace.x.sort()


def labelWhisker(w, BP_init, thresh=35, l_thresh=50):
    '''
    This function first removes all traces with length shorter
    than 'l_thresh'.

    Given an initial BP, this function finds the trace
    with the BP closest to that in the first frame. It then uses
    the new BP to look in the next frame for the trace that has
    a BP closest to the current BP estimate (a la Severson).
    If there is no new BP within 'thresh' pixels of the previous BP,
    then we re-initialize to the user supplied BP
    '''

    if type(BP_init) is not np.ndarray:
        raise ValueError('Input BP is not a 2D array')

    BP = BP_init
    # iterate over every frame
    for fid, frame in w.iteritems():
        # verbose
        if fid % 100 == 0:
            print('\rLabel Frame {:04d}'.format(fid)),
        # init the BP matrix for this frame as inf
        # Need this initialization so that there is an array
        # entry that corresponds to each wid. 
        BP_frame = np.empty([max(frame.keys()) + 1, 2], dtype='float32')
        BP_frame[:] = np.Inf
        # init a vector that holds the lengths of all the traces in a frame
        trace_lengths = np.zeros(max(frame.keys()) + 1, dtype='int64')

        # loop through each trace in the frame and get the BP and length
        # if it exists
        for wid, trace in frame.iteritems():
            if len(trace.x) == 0:
                # I want to test this to see if I can replace it with a continue
                BP_frame[wid, :] = np.hstack((np.Inf, np.Inf))
            else:
                BP_frame[wid, :] = np.hstack((trace.x[0], trace.y[0]))
                trace_lengths[wid] = compute_arclength(trace)[0]

        # calculate distance between target BP and each BP in the frame.
        # Find the minimum distance
        D = distance.cdist(BP_frame, BP)
        # ignore whiskers shorter than thresh.
        # This could be replaced by removing all short whiskers first.
        D[trace_lengths < l_thresh] = np.Inf
        idx = np.argmin(D)
        min_D = np.min(D)

        # If the nearest BP is within thresh, rewrite the frame to only have the desired whisker in it.
        # If it is not, write an empty dict as the frame
        if min_D > thresh:
            BP = BP_init
            idx = None
            w[fid] = {}
        else:
            w[fid] = {0: w[fid][idx]}
            BP = np.expand_dims(BP_frame[idx, :], 0)


def applyMaskToWhisker(w, mask):
    '''
    given a boolean 'mask' of the image,
    removes any points of the whisker dict 'w'
    that fall inside the mask
    '''
    for frame in w.itervalues():
        for trace in frame.itervalues():
            # cast trace points as ints to allow for indexing
            xx = trace.x.astype('int64')
            yy = trace.y.astype('int64')
            rm_idx = mask[yy, xx]
            trace.x = trace.x[~rm_idx]
            trace.y = trace.y[~rm_idx]


def plotW(w, V, mask):
    '''
    Simple function that plots the whisker over the video.
    Not very useful since you can call Save_Whiskers and
    use whisk to visualiz.
    '''
    for ii in xrange(len(w)):
        img = V.get_frame(ii)
        plt.cla()
        plt.imshow(img)
        plt.imshow(mask, alpha=0.1)
        for trace in w[ii].itervalues():
            plt.plot(trace.x, trace.y)
        plt.draw()
        plt.pause(0.01)


def extendBP(w, BP, lin_pct=0.05):
    '''
    takes a user-defined BP and a whisker dict.
    Each frame in the whisker dict must contain only one key-value pair.
    This means the whisker dict should have been lablled already.
    Computes a linear fit to the proximal part of the whisker, and
    extrapolates the whisker toeards the BP. Importantly, the BP is not
    the same for every frame, but rather, the coordinate
    on which the whisker is ordered is the same in every frame

    Optional argument for the proximal length to consider linear
    '''

    for fid, frame in w.iteritems():
        assert len(frame) <= 1, 'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame) == 0:
            continue
        if len(frame[0].x) == 0:
            continue

        # get x and y coords of the user defined basepoint
        # and the first tracked point
        x = np.array([BP[0, 0], frame[0].x[0]])
        y = np.array([BP[0, 1], frame[0].y[0]])

        # extD = distance.euclidean(BP, np.array([frame[0].x[0], frame[0].y[0]]))
        lin_nodes = np.ceil(len(frame[0].x) * lin_pct).astype('int')
        # get the internode spacing
        x_diff = np.abs(np.mean(np.diff(frame[0].x)))
        y_diff = np.abs(np.mean(np.diff(frame[0].y)))

        # sort the user-defined basepoint
        # and the first tracked along the x direction
        xq = frame[0].x[:lin_nodes]
        yq = frame[0].y[:lin_nodes]

        # automatically compute linear fit along axis of most variation
        # this prevents ill-conditioned fits

        # if y varies more
        if yq.ptp() > xq.ptp():
            f = np.polyfit(yq, xq, 1)
            y.sort()
            yy = np.arange(y[0], y[1], y_diff)
            xx = np.polyval(f, yy)
        # if x varies more
        else:
            f = np.polyfit(xq, yq, 1)
            x.sort()
            xx = np.arange(x[0], x[1], x_diff)
            yy = np.polyval(f, xx)

        # append to frame
        frame[0].x = np.concatenate((xx.astype('float32'), frame[0].x))
        frame[0].y = np.concatenate((yy.astype('float32'), frame[0].y))


def compute_arclength(trace):
    '''
    takes a trace and returns its arclength and the cumulative sum along the arclength
    '''
    x_d = np.diff(trace.x)
    y_d = np.diff(trace.y)
    ds = np.sqrt(x_d ** 2 + y_d ** 2)
    s_cum = np.cumsum(np.hstack((np.array([0]), ds)))
    return np.sum(ds),s_cum


def getLength(w):
    '''
    computes the arclength for every
    frame in a whisker dict. Assumes a whisker dict
    with only one trace per frame.
    MAYBE CHANGE THIS SO IT CAN COMPUTE THEM ALL
    '''
    w_lengths = np.zeros(len(w))
    for fid, frame in w.iteritems():
        assert len(frame) <= 1, 'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame) == 0:
            continue
        w_lengths[fid] = compute_arclength(frame[0])[0]
    return w_lengths


def trimToLengthTop(w, w_lengths):
    '''
    In a top view, the apparent length of the whisker
    should not change. Therefore, we can trim the whisker
    to the length we expect in case tracking continues onto
    a background edge.
    '''

    # use the last 500 frames to get the expected whisker length
    l_avg = np.nanmedian(w_lengths[-500:])
    for fid, frame in w.iteritems():
        assert len(frame) <= 1, 'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        # skip if there are no traces in a frame
        if len(frame) == 0:
            continue
        trace = frame[0]
        # need to compute the cumulative sum to find the point at
        # which the whisker becomes too long

        s = compute_arclength(trace)[1]
        # get indices at which the length is less than the expected length
        idx = s < l_avg

        # remove points past the expected length
        trace.x = trace.x[idx]
        trace.y = trace.y[idx]


def extendToLengthTop(w, l):
    pass


def rmShort(w, pct=0.95):
    '''
    we want to remove whiskers that are shorter than expected.
    Takes a whisker dict with one entry per frame
    '''
    # get a reference length from the last 500 frames
    w_lengths = getLength(w)
    l_ref = np.nanmedian(w_lengths[-500:])

    for fid, frame in w.iteritems():
        assert len(frame) <= 1, 'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame[0].x) == 0:
            continue
        trace = frame[0]
        l_trace = compute_arclength(trace)[0]
        # make frame empty if the trace is shorter than a percentage of the reference
        if l_trace < pct * l_ref:
            w[fid] = {}


def smooth2D(w,direction,frac=0.15):

    for fid,frame in w.iteritems():
        if fid % 100 ==0:
            print('\rSmooth Frame {:04d}'.format(fid)),
        assert len(frame) <= 1, 'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        # skip if there are no traces in a frame
        if len(frame) == 0:
            continue
        trace = frame[0]
        if direction=='y':
            exog = trace.y
            endog = trace.x
        else:
            exog = trace.x
            endog = trace.y


        ret = lowess(endog, exog,frac=frac,it=1,delta=0.001*exog.ptp()).astype('float32')
        exog = ret[:,0]
        endog = ret[:,1]
        if np.any(np.isnan(ret)):
            continue
        elif direction=='y':
            trace.y = exog
            trace.x = endog
        else:
            trace.x = exog
            trace.y = endog


def save_no_overwrite(wFileOut,w):
    if os.path.isfile(wFileOut):
        uin = raw_input('File exists, Overwrite? (Y,n)').lower()
        if len(uin) == 0 or uin == 'y':
            Save_Whiskers(wFileOut, w)
        else:
            wFileOut = os.path.splitext(wFileOut)[0]+'temp'+os.path.splitext(wFileOut)[1]
            Save_Whiskers(wFileOut, w)
    else:
        Save_Whiskers(wFileOut, w)


if  __name__=='__main__':
    # input argument is path to process

    w_path = sys.argv[1]    
    # get the mask
    mask_filename = glob.glob(os.path.join(w_path,'*.npz'))[0]
    mask_data = np.load(mask_filename)

    # get the directory of whisker files
    w_dir = glob.glob(os.path.join(w_path,'*.whiskers'))
    err_file = os.path.join(w_path, 'ERRS.csv')

    for wFile in w_dir:
        # get view and sort direction
        if re.search('(front|top).whiskers',wFile)==None:
            print('Lablled file found, skipping...')
            continue
        wFileOut = os.path.splitext(wFile)[0] + '_labelled' + os.path.splitext(wFile)[1]
        if os.path.isfile(wFileOut):
            continue

        view = re.search('(?i)front|(?i)top', wFile).group().lower()
        if view == 'top':
            direction = 'y'
            mask = mask_data['mask_top']
            BP = mask_data['BP_top']
        elif view == 'front':
            direction = 'x'
            mask = mask_data['mask_front']
            BP = mask_data['BP_front']
        else:
            raise ValueError('View does not appear to be front or top')

        # Load the whiskers
        print('Loading {}'.format(wFile))
        w = Load_Whiskers(wFile)
        print('Loaded!')

        # get output filename


        # perform preprocessing
        sortWhisker(w, direction)
        applyMaskToWhisker(w, mask)
        labelWhisker(w, BP, thresh=50, l_thresh=200)
        extendBP(w, BP)
        smooth2D(w,direction,frac=0.15)
        if view == 'top':
            w_lengths = getLength(w)
            trimToLengthTop(w, w_lengths)

        # save to a new whiskers file
        try:
            Save_Whiskers(wFileOut, w)
        except:
            print('WARNING FILE: {} did not save properly'.format(wFileOut))
            with open(err_file,'ab') as csvfile:
                csvwriter = csv.writer(csvfile)
                csvwriter.writerow([wFileOut])
            continue




elif False:
    # ========================== #
    trial_num = 25
    wFile = r'J:\motor_experiment\video_data\nick_TODO\heal_contact\POS2_RB1\motor_collision_POS2_RB1__t{}_Top_proc.whiskers'.format(trial_num)
    wFileOut = os.path.splitext(wFile)[0] + '_mod' + os.path.splitext(wFile)[1]
    vFile = os.path.splitext(wFile)[0] + '.avi'

    view = re.search('(?i)front|(?i)top', wFile).group().lower()
    if view == 'top':
        direction = 'y'
    elif view == 'front':
        direction = 'x'
    else:
        raise ValueError('View does not appear to be front or top')

    print('Loading...')
    w = Load_Whiskers(wFile)
    V = pims.Video(vFile)
    print('Loaded!')

    sortWhisker(w, direction)

    img = V.get_frame(0)
    plt.imshow(img)
    plt.title('click on basepoint')
    BP = np.asarray(plt.ginput(1, timeout=0))

    mask = getMask(img[:, :, 0])
    plt.close('all')

    applyMaskToWhisker(w, mask)
    labelWhisker(w, BP, thresh=60, l_thresh=100)
    extendBP(w, BP)

    if view == 'top':
        w_lengths = getLength(w)
        trimToLengthTop(w, w_lengths)

        # rm short might need some work if it is to work on the front view. Maybe check for length deviations in neighboring frames?
        # rmShort(w,pct=0.80)


    if os.path.isfile(wFileOut):
        uin = raw_input('File exists, Overwrite? (Y,n)').lower()
        if len(uin) == 0 or uin == 'y':
            Save_Whiskers(wFileOut, w)
        else:
            wFileOut = os.path.splitext(wFileOut)[0]+'temp'+os.path.splitext(wFileOut)[1]
            Save_Whiskers(wFileOut, w)
    else:
        Save_Whiskers(wFileOut, w)
