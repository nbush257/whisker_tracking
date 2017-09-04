import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import pims
from scipy.spatial import distance
import re
import glob
from scipy.interpolate import interp1d
from cleanMotorWhisker import compute_arclength
sys.path.append(
    r'L:\Users\guru\Documents\hartmann_lab\proc\whisk\python')
sys.path.append(
    r'L:\Users\guru\Documents\hartmann_lab\proc\whiskerTracking\preMerge')
from trace_2 import Load_Whiskers, Save_Whiskers

def equidist(w,num_nodes=150,plot_tgl=False):
    for fid,frame in w.iteritems():
        print('\rEquidist {:04d}'.format(fid)),
        if len(frame)==0:
            continue

        x = frame[0].x
        y = frame[0].y

        s_total,s_cumulative = compute_arclength(frame[0])
        s_target = np.linspace(0,s_total,num_nodes)
        a = np.zeros([num_nodes,1])
        b = np.zeros([num_nodes,1])
        a[0] = x[0]
        b[0] = y[0]
        for ii in xrange(1,len(s_target)):
            if ii < (len(s_target)-1):
                idx = np.where(s_cumulative >= s_target[ii])[0][0]
            else:
                idx = len(s_cumulative)-1

            fx = interp1d(s_cumulative[idx - 1:idx + 1], x[idx - 1:idx + 1],fill_value='extrapolate')
            fy = interp1d(s_cumulative[idx - 1:idx + 1], y[idx - 1:idx + 1],fill_value='extrapolate')

            a[ii] = fx(s_target[ii])
            b[ii] = fy(s_target[ii])

        if plot_tgl:
            plt.cla()
            plt.plot(frame[0].x,frame[0].y,'.-')
            plt.plot(a,b,'o-')
            plt.draw()
            plt.pause(0.001)
        frame[0].x = a
        frame[0].y = b


def initDistanceMatrix(w):
    num_nodes = np.zeros([max(w.keys())+1,1],dtype='int64')

    for fid,frame in w.iteritems():
        if len(frame)==0:
            continue
        num_nodes[fid] = len(frame[0].x)
    max_nodes = np.max(num_nodes)
    distance_matrix = np.empty([len(num_nodes),max_nodes,2])
    distance_matrix[:] = np.nan
    return distance_matrix


def getMotionGradient(w):
    dt=1
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
            dt+=1
            continue

        x = frame[0].x
        y = frame[0].y

        min_num_pts = np.min([len(x),len(last_x)])

        x_trim = x[:min_num_pts]
        y_trim = y[:min_num_pts]
        last_x_trim = last_x[:min_num_pts]
        last_y_trim = last_y[:min_num_pts]

        distance_matrix[fid,:min_num_pts] =np.array([(x_trim-last_x_trim),(y_trim-last_y_trim)]).T/dt
        # distance_matrix[fid, :min_num_pts] = np.sqrt((x_trim-last_x_trim)**2 + (y_trim-last_y_trim)**2)
        dt=1
    return distance_matrix


def decomposeGradient(D):
    mag = np.sqrt(D[:,:,0]**2+D[:,:,1]**2)
    direction = np.arctan(D[:,:,0],D[:,:,1])


def main():
    wFile = r'E:\motor_experiment\video_data\_good\RA0_coll_N_e0001\motor_RA0_coll_N_e0001_t35_top_labelled.whiskers'
    w = Load_Whiskers(wFile)
    equidist(w)
    D = getMotionGradient(w)

if __name__=='__main__':
    main()

