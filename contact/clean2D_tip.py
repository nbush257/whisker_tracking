import scipy.io.matlab as sio
from glob import glob
from os import chdir
from os.path import isfile
from sklearn.preprocessing import Imputer
from sklearn.preprocessing import RobustScaler
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

INTERP_WINDOW= 100# in samples
INTERP_METHOD='pchip' #
dir = r"C:\Users\guru\Desktop\tip_data"
chdir(dir)
d = glob('*tip.mat')

def cleanTip(file,outname):
    dat = sio.loadmat(file)


    tip_raw = dat['tip']
    temp = tip_raw
    temp[np.isnan(temp)]=np.nanmedian(tip_raw)
    idx = abs(temp)>2000
    tip_raw[idx] = np.nan

    plt.title('Click to the left of the first contact')
    l = np.round(tip_raw.shape[0]/5)
    plt.plot(tip_raw[:l,:])
    x,y = plt.ginput(1,timeout=0)[0]
    plt.close('all')
    x = int(np.round(x))

    tip_raw[:x,:] = np.nanmedian(tip_raw,axis=0)
    tip_interp = pd.DataFrame(tip_raw).interpolate(method=INTERP_METHOD,limit=INTERP_WINDOW).values
    # tip_interp = medfilt(tip_interp)

    scaler = RobustScaler()
    imp = Imputer(strategy='median')
    tip_interp = imp.fit_transform(tip_interp)
    tip = scaler.fit_transform(tip_interp)
    plt.plot(tip)
    plt.title('Cleaned')
    plt.draw()

    save_dict={'tip_clean':tip}
    sio.savemat(outname,save_dict)

for file in d:
    plt.close('all')
    outname = file[:-4] + '_clean.mat'
    if not isfile(outname):
        cleanTip(file,outname)







