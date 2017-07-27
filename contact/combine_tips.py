import scipy.io.matlab as sio
import glob
import re
from os import chdir
import numpy as np
chdir(r'C:\Users\guru\Desktop\tip_data')
d_2D = glob.glob('rat*toMerge*clean.mat')
d_3D = glob.glob('rat*3D*tip.mat')

for file_3D in d_3D:
    token = re.search('^rat\d{4}_\d{2}_[A-Z]{3}\d\d_VG_[A-Z]\d_t\d{2}', file_3D).group()
    file_2D = [s for s in d_2D if token in s]

    if len(file_2D)==0:
        continue
    else:
        file_2D = file_2D[0]

    print 'File 3D is %s\t File 2D is ' % file_3D,file_2D

    dat_2D = sio.loadmat(file_2D)
    dat_3D = sio.loadmat(file_3D)

    tip_2D = dat_2D['tip_clean']
    tip_3D = dat_3D['tip']

    tip = np.hstack((tip_2D,tip_3D))

    outname = token + '_combined_tip.mat'
    save_dict = {'tip' : tip}
    sio.savemat(outname,save_dict,oned_as='col')
# ==========================================#
'''This section puts all the tips into a concatenated matrix, along with a vector 
that indicates the boundaries of each trial in the order of the file list'''

# d_combined = glob.glob('rat*combined*.mat')
# all_tip = np.empty((0,7))
# breaks = np.array([0])
# for file in d_combined:
#     data = sio.loadmat(file)
#     tip = data['tip']
#     all_tip = np.vstack((all_tip,tip))
#     breaks = np.hstack((breaks,all_tip.shape[0]))

#     save_dict = {'all_tip':all_tip,'breaks':breaks,'d_combined':d_combined}
#     sio.savemat('all_tip.mat',save_dict)








