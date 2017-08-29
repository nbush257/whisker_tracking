import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import pims
from scipy.spatial import distance
sys.path.append('L:\Users\guru\Documents\hartmann_lab\proc\whisk\python')
sys.path.append('L:\Users\guru\Documents\hartmann_lab\proc\whiskerTracking\preMerge')
from trace_2 import Load_Whiskers,Save_Whiskers
from findManip import getMask
from scipy.interpolate import interp1d
import re
# ============================================ #
def sortWhisker(w, direction='y'):

    direction = direction.lower()
    if direction not in ('x','y'):
        raise ValueError('Improper sort direction')

    for frame in w.itervalues():
        for trace in frame.itervalues():
            if direction=='y':
                idx = trace.y.argsort()
                trace.x = trace.x[idx]
                trace.y.sort()
            else:
                idx = trace.x.argsort()
                trace.y = trace.y[idx]
                trace.x.sort()


def labelWhisker(w,BP_init,thresh=35,l_thresh=50):
    frame_num = -1
    if type(BP_init) is not np.ndarray:
        raise ValueError('Input BP is not a 2D array')

    BP = BP_init

    for frame in w.itervalues():
        frame_num += 1

        if frame_num%100 == 0:
            print 'Frame {:06d}'.format(frame_num)


        BP_frame = np.empty([max(frame.keys())+1,2],dtype='float32')
        BP_frame[:] = np.Inf
        l = np.zeros(max(frame.keys())+1,dtype='int64')

        for wid,trace in frame.iteritems():
            if len(trace.x)==0:
                BP_frame[wid, :] = np.hstack((np.Inf, np.Inf))
            else:
                BP_frame[wid, :] = np.hstack((trace.x[0], trace.y[0]))
            l[wid] = len(trace.x)


        D = distance.cdist(BP_frame,BP)
        D[l<l_thresh] = np.Inf
        idx = np.argmin(D)
        min_D = np.min(D)

        if min_D>thresh:
            BP = BP_init
            idx = None
            w[frame_num]={}
        else:
            w[frame_num] = {0:w[frame_num][idx]}
            BP = np.expand_dims(BP_frame[idx,:],0)


def applyMaskToWhisker(w,mask):
    for frame in w.itervalues():
        for trace in frame.itervalues():
            xx = trace.x.astype('int64')
            yy = trace.y.astype('int64')
            rm_idx = mask[yy,xx]
            trace.x = trace.x[~rm_idx]
            trace.y = trace.y[~rm_idx]


def plotW(w,V,mask):
    for ii in xrange(len(w)):
        I = V.get_frame(ii)
        plt.cla()

        plt.imshow(I)
        plt.imshow(mask,alpha=0.1)
        for trace in w[ii].itervalues():
            plt.plot(trace.x,trace.y)
        plt.draw()
        plt.pause(0.01)


def extendBP(w,BP,direction='y'):
    lin_pct = 0.05 #
    for fid,frame in w.iteritems():
        assert len(frame)<=1,'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame)==0:
            continue
        if len(frame[0].x)==0:
            continue

        # get x and y coords of the user defined basepoint and the first tracked point
        x = np.array([BP[0, 0], frame[0].x[0]])
        y = np.array([BP[0, 1], frame[0].y[0]])

        extD = distance.euclidean(BP,np.array([frame[0].x[0],frame[0].y[0]]))
        lin_nodes = np.ceil(len(frame[0].x)*lin_pct).astype('int')
        # get the internode spacing
        x_diff = np.abs(np.mean(np.diff(frame[0].x)))
        y_diff = np.abs(np.mean(np.diff(frame[0].y)))

        # sort the user-defined basepoint and the first tracked along the x direction
        # idx = np.argsort(x)

        # f = interp1d(x,y)
        #
        # xx = np.arange(x[0],x[1],x_diff)
        # yy = f(xx)

        xq = frame[0].x[:lin_nodes]
        yq = frame[0].y[:lin_nodes]

        if yq.ptp()>xq.ptp():
            f = np.polyfit(yq,xq,1)
            y.sort()
            yy = np.arange(y[0],y[1],y_diff)
            xx = np.polyval(f,yy)
        else:
            f = np.polyfit(xq,yq,1)
            x.sort()
            xx = np.arange(x[0],x[1],x_diff)
            yy = np.polyval(f,xx)


        # if the whisker is primarily along the Y direction, sort on y
        # if direction=='y':
        #     idx = yy.argsort()
        #     yy.sort()
        #     xx = xx[idx]

        # add the new points to the whisker structure
        frame[0].x = np.concatenate((xx.astype('float32'), frame[0].x))
        frame[0].y = np.concatenate((yy.astype('float32'), frame[0].y))


def compute_arclength(trace):

    x_d = np.diff(trace.x)
    y_d = np.diff(trace.y)
    ds = np.sqrt(x_d ** 2 + y_d ** 2)
    return np.sum(ds)


def getLength(w):
    l = np.zeros(len(w))
    for fid,frame in w.iteritems():
        assert len(frame)<=1,'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame)==0:
            continue
        l[fid] = compute_arclength(frame[0])
    return l


def trimToLengthTop(w,l):
    l_avg = np.nanmedian(l[-500:])
    for fid,frame in w.iteritems():
        assert len(frame)<=1,'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame[0].x)==0:
            continue
        trace = frame[0]
        x_d = np.diff(trace.x)
        y_d = np.diff(trace.y)
        ds = np.sqrt(x_d ** 2 + y_d ** 2)
        s = np.cumsum(np.hstack((np.array([0]),ds)))
        idx = s<l_avg
        trace.x = trace.x[idx]
        trace.y = trace.y[idx]

def extendToLengthTop(w,l):
    pass

def rmShort(w,pct=0.95):
    l=getLength(w)
    l_ref = np.nanmedian(l[-500:])
    for fid,frame in w.iteritems():
        assert len(frame)<=1,'Frame {} should only have one whisker. Have you run labelWhisker yet?'.format(fid)
        if len(frame[0].x)==0:
            continue
        trace = frame[0]
        l_trace = compute_arclength(trace)
        if l_trace<pct*l_ref:
            w[fid]={}


if False:#__name__=='__main__':
    wFile = sys.argv[1]
    vFile = sys.argv[2]


    print('Loading...')
    w = Load_Whiskers(wFile)
    V = pims.Video(vFile)
    print 'Loaded!'
elif False:
    ## ========================== ##
    wFile = r'J:\motor_experiment\video_data\_unfinished\no_params_yet\POS2_RB1\new\motor_collision_POS2_RB1__t07_Top_proc.whiskers'
    wFileOut = os.path.splitext(wFile)[0]+'_mod'+os.path.splitext(wFile)[1]
    vFile = os.path.splitext(wFile)[0]+'.avi'

    view = re.search('(?i)front|(?i)top', wFile).group().lower()
    if view=='top':
        direction = 'y'
    elif view=='front':
        direction = 'x'
    else:
        raise ValueError('View does not appear to be front or top')


    print('Loading...')
    w = Load_Whiskers(wFile)
    V = pims.Video(vFile)
    print 'Loaded!'

    sortWhisker(w,direction)

    I = V.get_frame(0)
    plt.imshow(I)
    plt.title('click on basepoint')
    BP = np.asarray(plt.ginput(1,timeout=0))

    mask = getMask(I[:,:,0])
    plt.close('all')

    applyMaskToWhisker(w,mask)
    labelWhisker(w,BP,thresh=60,l_thresh=100)
    extendBP(w, BP, direction)

    if view=='top':
        l = getLength(w)
        trimToLengthTop(w,l)

    rmShort(w)


    if os.path.isfile(wFileOut):
        uin = raw_input('File exists, Overwrite? (Y,n)').lower()
        if len(uin)==0 or uin=='y':
            Save_Whiskers(wFileOut, w)
        else:
            Save_Whiskers('temp_' + wFileOut, w)
    else:
        Save_Whiskers(wFileOut, w)