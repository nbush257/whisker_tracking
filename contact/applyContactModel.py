from convNN import *
import scipy.io.matlab as sio
import glob
import numpy as np
import sys

def applyModel(mdl,data_fname):
	data = sio.loadmat(data_fname)
	X = data['X']
	C = np.zeros(X.shape[0],dtype='bool')
	window_size = mdl.layers[0].input_shape[1]/2
	XX = make_tensor(X,window_size)
	C = mdl.predict_classes(XX)
	C = C.astype('bool')
	data_struct = {'C':C,'X':X,'tip':data['tip']}
	sio.savemat(data_fname,data_struct)

if __name__ == '__main__':
	model_name = sys.argv[1]
	mdl = load_model(model_name)
	path = sys.argv[2]
	for file in glob.glob(path+'/*combined*.mat'):
		print'Working on file {}\n'.format(file)
		applyModel(mdl,file)
