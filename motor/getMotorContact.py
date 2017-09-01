import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import pims
from scipy.spatial import distance
import re
import glob

sys.path.append(
    r'L:\Users\guru\Documents\hartmann_lab\proc\whisk\python')
sys.path.append(
    r'L:\Users\guru\Documents\hartmann_lab\proc\whiskerTracking\preMerge')
from trace_2 import Load_Whiskers, Save_Whiskers

def initDistanceMatrix(w):
    num_nodes = np.zeros([max(w.keys())+1,1],dtype='int64')

    for fid,frame in w.iteritems():
        if len(frame)==0:
            continue
        num_nodes[fid] = len(frame[0].x)
    max_nodes = np.max(num_nodes)
    return np.zeros([len(num_nodes),max_nodes])


def getMotionGradient(w):
    last_x = w[0][0].x
    last_y = w[0][0].y
    last_pts = np.vstack((last_x,last_y)).T
    distance_matrix = initDistanceMatrix(w)
    for fid,frame in w.iteritems():
        # skip first frame
        if fid==0:
            continue

        assert(len(frame)<=1),'Frame should not have more than 1 whisker in it'

        # check if frame is empty
        if len(frame)==0:
            continue

        x = frame[0].x
        y = frame[0].y

        min_num_pts = np.min([len(x),len(last_x)])

        x_trim = x[:min_num_pts]
        y_trim = y[:min_num_pts]
        last_x_trim = last_x[:min_num_pts]
        last_y_trim = last_y[:min_num_pts]

        distance_matrix[fid,:min_num_pts] = np.sqrt((x_trim-last_x_trim)**2+(y_trim-last_y_trim)**2)
    return distance_matrix









