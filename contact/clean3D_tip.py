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

INTERP_WINDOW= 1000# in samples
INTERP_METHOD='pchip' #
dir = r"L:\Users\guru\Documents\hartmann_lab\data\tracked_3D\good"
chdir(dir)
d = glob('*.mat')

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

    tip_interp = pd.DataFrame(tip).interpolate(method=INTERP_METHOD, limit=INTERP_WINDOW).values
    tip_interp_med = np.empty_like(tip_interp)
    # for ii in xrange(tip_interp.shape[-1]):
    #     tip_interp_med[:,ii] = medfilt(tip_interp[:,ii],5)

    scaler = RobustScaler()
    imp = Imputer(strategy='median')
    tip_interp_imp = imp.fit_transform(tip_interp)
    tip_out = scaler.fit_transform(tip_interp_imp)

    save_dict = {'tip': tip_out}
    sio.savemat(outname,save_dict)
for file in d:
    print('Working on file {}\n'.format(file))
    outname = file[:-4] + '_tip.mat'
    if not isfile(outname):
        cleanTip(file,outname)
