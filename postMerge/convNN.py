import numpy as np
from keras.layers import Convolution1D, Dense, MaxPooling1D, Flatten
from keras.models import Sequential
import scipy.io.matlab as sio
import sys
from keras.models import Sequential
from keras.layers import Dense,Convolution1D,Dropout,MaxPooling1D,AtrousConv1D,Flatten
from keras.regularizers import l2,l1
from keras.models import model_from_json
from sklearn.preprocessing import scale, Imputer
from scipy.signal import detrend
import scipy.signal as signal
import sys


def make_conv_mdl(X, filter_length=16):
    input_shape = X.shape[1:3]
    model = Sequential()
    penalty = 0.01
    
    model.add(Convolution1D(nb_filter=64,filter_length=filter_length, border_mode='same',input_shape=input_shape,W_regularizer=l2(penalty)))
    model.add(MaxPooling1D(pool_length=4, stride=1, border_mode='same'))

    model.add(Convolution1D(nb_filter=64,filter_length=filter_length, border_mode='same',input_shape=input_shape,W_regularizer=l2(penalty)))
    model.add(MaxPooling1D(pool_length=4, stride=1, border_mode='same'))

    model.add(Convolution1D(nb_filter=64,filter_length=filter_length, border_mode='same',input_shape=input_shape,W_regularizer=l2(penalty)))
    model.add(MaxPooling1D(pool_length=4, stride=1, border_mode='same'))

    model.add(Convolution1D(nb_filter=64,filter_length=filter_length, border_mode='same',input_shape=input_shape,W_regularizer=l2(penalty)))
    model.add(MaxPooling1D(pool_length=4, stride=1, border_mode='same'))

    model.add(Convolution1D(nb_filter=64,filter_length=filter_length, border_mode='same',input_shape=input_shape,W_regularizer=l2(penalty)))
    model.add(MaxPooling1D(pool_length=4, stride=1, border_mode='same'))

    model.add(Dense(512,activation='relu'))
    model.add(Dropout(0.2))
    
    model.add(Dense(512,activation='relu'))
    model.add(Dropout(0.2))

    model.add(Dense(1, activation='sigmoid'))
    # model.compile(loss='mse', optimizer='adam', metrics=['mae'])
    # To perform (binary) classification instead:
    model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    return model


def make_tensor(timeseries, window_size):
    X = np.empty((timeseries.shape[0],window_size*2,timeseries.shape[-1]))
    for ii in xrange(window_size,timeseries.shape[0]-window_size):
        X[ii,:,:] = timeseries[ii-window_size:ii+window_size,:]
    return X


def fit(X,C,mdl,nb_epoch=2,batch_size=128):
    C = make_tensor(C,X.shape[1]/2)
    mdl.fit(X,C,nb_epoch=nb_epoch,batch_size=batch_size)
    return mdl

def cleanVar(x):
    imp = Imputer()
    x = imp.fit_transform(x)
    x = detrend(x,axis=0)
    x = scale(x)
    return x

def saveNN(model,save_file='model'):
    model_json = model.to_json()
    with open(save_file + ".json", "w") as json_file:
        json_file.write(model_json)
    # serialize weights to HDF5
    model.save_weights(save_file + ".h5")
    print("Saved model to disk")

def loadModel(model_fid):
    json_file = open(model_fid+'.json','r')
    loaded_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_json)
    loaded_model.load_weights(model_fid+'.h5')

    loaded_model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    return loaded_model

def main():
    fname = sys.argv[1]
    data = sio.loadmat(fname)
    tip = data['tip']
    tip = cleanVar(tip)

    model = loadModel('full_conv_model')
    window_size = model.layers[0].input_shape[1]/2

    X = make_tensor(tip,window_size)
    print('\nPredicting Contact Variable...')
    C = model.predict_classes(X)
    data['C'] = C[:,model.output_shape[1]/2]
    data['tip_scale'] = tip
    print('Saving Data to .mat file\n')
    sio.savemat(fname,data,oned_as='column')
    print('C Vector Saved\n')

    

if __name__ == '__main__':
    main()
