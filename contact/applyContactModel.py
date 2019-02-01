from convNN import *
import scipy.io.matlab as sio
import glob
import numpy as np
import sys
import os
import re
def applyModel(mdl,data_fname):
	data = sio.loadmat(data_fname)
	root = re.search('rat\d{4}_\d\d_[A-Z]{3}\d\d_VG_[A-Z]\d_t\d\d',data_fname).group()
	p = os.path.split(data_fname)[0]
	data_out_name = os.path.join(p,root + '_contact2D.mat')
	X = data['X'][:,:4]
	C = np.zeros(X.shape[0],dtype='bool')
	window_size = mdl.layers[0].input_shape[1]/2
	XX = make_tensor(X,window_size)
	C = mdl.predict_classes(XX)
	C = C.astype('bool')
	data_struct = {'C':C,'X':X,'tip':data['tip']}
	sio.savemat(data_out_name,data_struct)

if __name__ == '__main__':
	model_name = sys.argv[1] # model is the first argument
	mdl = load_model(model_name)
	path = sys.argv[2] # path where the combined datas live
	if len(sys.argv) == 4:
		ext = sys.argv[3] # if there is a third argument, it should be the filename string specification (e.g., *combined.mat)
	else:
		ext = '*combined*.mat'
	for file in glob.glob(path + '/' + ext):
		print'Working on file {}\n'.format(file)
		applyModel(mdl,file)
