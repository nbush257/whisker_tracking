from keras.layers.convolutional import Convolution1D
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras.optimizers import SGD
import scipy.io.matlab as sio
import numpy as np
def contact(tip,labels):

    filter_length = 20
    # apply a convolution 1d of length 3 to a sequence with 10 timesteps,
    # with 64 output filters
    model = Sequential()
    model.add(Convolution1D(64, 10, border_mode='same', input_dim=3))

    # add a new conv1d on top
    # model.add(Convolution1D(32, filter_length, border_mode='same',input_dim = 3))
    # now model.output_shape == (None, 10, 32)
    # print model.output_shape
    model.add(Dense(64, activation = 'relu'))
    model.add(Dropout(0.5))
    model.add(Dense(1, activation='sigmoid'))

    model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])

    model.fit(tip,labels,nb_epoch=20,batch_size=32)

def contact2(tip,labels):
    t_len = tip.shape[0]
    model = Sequential()
    model.add(Dense(64, input_dim = 3, init='uniform', activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(64, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(1, activation='sigmoid'))
    sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)

    model.compile(loss='binary_crossentropy',
                  optimizer='sgd',
                  metrics=['accuracy'])

    model.fit(tip,labels,nb_epoch=20,batch_size=32)

import scipy.io.matlab as sio
import numpy as np
fid = r'C:\Users\guru\Documents\hartmann_lab\data\2016_45\tip_test.mat'
f = sio.loadmat(fid)

tip = f['tip_clean']
C = f['C']
labelled = np.isfinite(C)[:,0]

train_data = tip[labelled,:]
train_labels = C[labelled]
