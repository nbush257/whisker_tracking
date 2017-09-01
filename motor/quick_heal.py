import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import pims
from scipy.spatial import distance
from cleanMotorWhisker import sortWhisker
from scipy.interpolate import interp1d
import re
sys.path.append(
     r'L:\Users\guru\Documents\hartmann_lab\proc\whisk\python')
sys.path.append(
    r'L:\Users\guru\Documents\hartmann_lab\proc\whiskerTracking\preMerge')
from trace_2 import Load_Whiskers, Save_Whiskers

trial_num = 25
frame_nums = [318,320,321,322,323,325,326,327,328,329,330,331,332,335]
wFile = r'J:\motor_experiment\video_data\nick_TODO\heal_contact\POS2_RB1\motor_collision_POS2_RB1__t{}_Top_proc.whiskers'.format(trial_num)
fileparts = os.path.splitext(wFile)
wFileOut = fileparts[0]+'_heal'+fileparts[1]
vFile = os.path.splitext(wFile)[0]+'.avi'
try:
    v = pims.Video(vFile)
except:
    print('Video did not load')

w = Load_Whiskers(wFile)
for fid in frame_nums:
    frame = w[fid]
    try:
        img = v[fid]
        plt.imshow(img)
    except:
        pass

    for wid,trace in frame.iteritems():
        plt.plot(trace.x,trace.y)
    uIn = np.array(plt.ginput(2,timeout=0))
    uIn[uIn[:,1].argsort()]

    plt.close('all')

    D = np.empty([max(frame.keys())+1,2])
    D[:] = np.Inf
    for wid,trace in frame.iteritems():
        pts = np.vstack((trace.x,trace.y)).T
        D[wid,:] = np.min(distance.cdist(pts,uIn),0)
    idx = np.argmin(D,0)

    frame[idx[0]]=frame[idx[0]].join(frame[idx[0]],frame[idx[1]])
    frame.pop(idx[1])

Save_Whiskers(wFileOut,w)






