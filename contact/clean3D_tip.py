import scipy.io.matlab as sio
from glob import glob
from os import chdir
from os.path import isfile
from sklearn.preprocessing import Imputer
from sklearn.preprocessing import RobustScaler
import pandas as pd
from scipy.signal import medfilt
import matplotlib.pyplot as plt
import numpy as np
import statsmodels.api as sm
import sys

INTERP_WINDOW= 100# in samples
INTERP_METHOD='pchip' #

def cleanTip(filename,outname):
    dat = sio.loadmat(filename)
    t3d = dat['tracked_3D']

    tip = np.empty((t3d.shape[-1],3))
    tip[:] = np.nan
    for ii in xrange(t3d['x'].shape[-1]):
        if len(t3d['x'][0, ii]) > 0:
            if len(t3d['x'][0, ii][0]) > 1:
                x = t3d['x'][0, ii][0, -1]
                y = t3d['y'][0, ii][0, -1]
                z = t3d['z'][0, ii][0, -1]
                tip[ii, :] = np.hstack((x, y, z))

    ########### This section is for de novo cleaning ############
    plt.title('Click to the left of the first contact')
    l = np.round(tip.shape[0]/5)
    plt.plot(tip[:l,:])
    x,y = plt.ginput(1,timeout=0)[0]
    plt.close('all')
    x = int(np.round(x))
    ######### ==================== ################

    # ########## This section is for if we have already manually found the start #############
    # dat_smooth = sio.loadmat(outname)
    # tip_smooth = dat_smooth['tip']
    # x = np.where(np.diff(tip_smooth[:,0])!=0)[0][0]
    # ########## -------------------- ################


    tip[:x,:] = np.nanmedian(tip,axis=0)
    tip[-1,:] = np.nanmedian(tip,axis=0)
    tip_interp = pd.DataFrame(tip).interpolate(method=INTERP_METHOD, limit=INTERP_WINDOW).values
    tip_interp_med = np.empty_like(tip_interp)

    scaler = RobustScaler()
    imp = Imputer(strategy='median')
    tip_interp_imp = imp.fit_transform(tip_interp)
    tip_out = scaler.fit_transform(tip_interp_imp)
    save_dict = {'tip': tip_out}
    sio.savemat(outname,save_dict)
        
if __name__ == '__main__':
    path = sys.argv[1] # first argument is the path which you want to work on
    chdir(path)
    d = glob(sys.argv[2]) # second argument is the string specification for the files that you want to grab
    
    for file in d:
        print('Working on file {}\n'.format(file))
        outname = file[:-4] + '_tip.mat'
        if not isfile(outname):
            cleanTip(file,outname)
