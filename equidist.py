import pandas as pd
from scipy.interpolate import UnivariateSpline
import numpy as np
import skimage.io as io
import os
import glob
import sys
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
mpl.rcParams['axes.prop_cycle'] = plt.cycler(color=plt.cm.Set1.colors)

def check_monotonic(x,y):
    x_mono= np.all(np.diff(x)>0)
    y_mono= np.all(np.diff(y)>0)
    if x_mono:
        return('x')
    elif y_mono:
        return('y')
    return('')


def equidist(x,y,n_pts):
    xsup,ysup = interp(x,y,1000)
    if len(xsup)!=1000:
        return(x,y)
    d = np.sqrt(np.diff(xsup)**2+np.diff(ysup)**2)
    s = np.cumsum(d)
    target_ds = s[-1]/(n_pts-1)
    node_ds = target_ds*(np.arange(n_pts-2)+1)
    idx=[0]
    for node in node_ds:
        idx.append(np.argmin(np.abs(s-node)))
    idx.append(999)
    xout = xsup[idx]
    yout = ysup[idx]

    return xout,yout




def interp(x,y,n_pts=None):
    """
    Takes a set of unevenly spaced points and returns n evenly spaced points interpolated by a spline
    :param x: x coords
    :param y: y coords
    :param n_pts: number of points to return (Default to 10)
    :return xhat,yhat: new, evenly spaced x and y coordinates
    """
    if len(x)!= len(y):
        raise ValueError('Number of points in x:{} not equal to the number of points in y:{}'.format(len(x),len(y)))
    # make sure the inputs are 1D numpy arrays
    x = np.asarray(x).ravel()
    y = np.asarray(y).ravel()
    if n_pts is None:
        n_pts = len(x)

    if check_monotonic(x,y) == 'x':
        interp = UnivariateSpline(x,y,k=2)
        xhat = np.linspace(np.min(x),np.max(x),n_pts)
        yhat = interp(xhat)
    elif check_monotonic(x,y) == 'y':
        interp = UnivariateSpline(y,x,k=2)
        yhat = np.linspace(np.min(y),np.max(y),n_pts)
        xhat = interp(yhat)
    else:
        print('No whisker points are monotonic. Returning raw')
        return(x,y)

    return(xhat,yhat)

def equidist_imagej_csv(csv_file,pts_per_whisker=10,thresh=15,new_num_pts=10):
    """
    Gets the input from an imageJ measurements CSV and replaces the points
    near (0,0) with nans so we dont mess up the spline fit

    :param csv_file: filename of the csv
    :param pts_per_whisker: number of points in each whisker. Default=10
    :param thresh: points closer to the origin by <= thresh are replaced as NaNs. Default = 15
    :return: dat - a pandas dataframe of the CSV file data, modified
    """
    dat = pd.read_csv(csv_file,index_col=0)
    if len(dat.groupby('Slice').count().X.unique())>1:
        raise ValueError('Number of tracked points is not the same in each frame')
    idx = (dat.X<thresh)| (dat.Y<thresh)
    dat.loc[idx,'X']=np.nan
    dat.loc[idx,'Y']=np.nan
    dat_out = pd.DataFrame()
    num_whiskers = len(dat)/pts_per_whisker/dat.Slice.max()

    wid = np.array([np.ones(pts_per_whisker)*ii for ii in range(num_whiskers)]).ravel()
    wid = np.tile(wid,len(dat.Slice.unique())).astype('int')
    dat['wid']=wid
    for slice_num in dat.Slice.unique():
        slice = dat[dat.Slice==slice_num]
        df_slice = pd.DataFrame()
        for whisker in slice.wid.unique():
            x = slice[slice.wid==whisker].X
            y = slice[slice.wid==whisker].Y
            idx = np.logical_or(np.isfinite(x),np.isfinite(y))
            if np.sum(idx)<(pts_per_whisker*0.4):
                temp = pd.DataFrame()
                temp['X'] = x
                temp['Y'] = y
                temp['Slice'] =slice_num
            else:
                xhat = np.empty_like(x)
                yhat = np.empty_like(y)
                xhat[:]=np.nan
                yhat[:]=np.nan

                xtemp,ytemp = equidist(x[idx],y[idx],np.sum(idx))
                xhat[np.where(idx)[0]]=xtemp
                yhat[np.where(idx)[0]]=ytemp
                temp = pd.DataFrame()
                temp['X'] = xhat
                temp['Y'] = yhat
                temp['Slice'] =slice_num
            df_slice = pd.concat([df_slice,temp],axis=0)
        dat_out = pd.concat([dat_out,df_slice])

    dat_out.fillna(0,inplace=True)
    dat_out.index = np.arange(1,len(dat_out)+1)
    idx = (dat_out.X<thresh)| (dat_out.Y<thresh)
    dat_out.loc[idx,'X']=np.nan
    dat_out.loc[idx,'Y']=np.nan
    dat_out.fillna(0,inplace=True)

    return(dat_out)

def plot_equidist(p):
    """
    This function plots and saves all images with the equidist points plotted
    """
    im_list = glob.glob(os.path.join(p,'*.png'))
    im_list.sort()
    dat = pd.read_csv(os.path.join(p,'Results_equidist.csv'))
    for ii,im in enumerate(im_list,1):
        outname = os.path.splitext(im)[0]+'labelled.png'
        I = io.imread(im)
        plt.imshow(I)
        x = dat[dat.Slice==ii].X.as_matrix()
        y = dat[dat.Slice==ii].Y.as_matrix()
        for wid in range(len(x)/10):
            pt_idx = range(wid*10,(wid+1)*10)
            plt.scatter(x[pt_idx],y[pt_idx],s=20)
        plt.draw()
        plt.savefig(outname)
        plt.close('all')


if __name__=='__main__':
    csv_file = sys.argv[1]
    if len(sys.argv)>2:
        plot_tgl = sys.argv[2]
    else:
        plot_tgl=[]
    if plot_tgl=='plot':
        plot_equidist(sys.argv[1])
    else:
        df = equidist_imagej_csv(csv_file)
        outpath,basename = os.path.split(csv_file)
        outname = os.path.join(outpath,os.path.splitext(basename)[0]+'_equidist.csv')
        df.to_csv(outname)

