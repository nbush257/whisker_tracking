import numpy as np
from keras.models import Sequential
import scipy.io.matlab as sio
import sys
from keras.models import Sequential
from keras.layers import Dense,Convolution1D,Dropout,MaxPooling1D,AtrousConv1D,Flatten,AveragePooling1D,UpSampling1D
from keras.layers.recurrent import LSTM
from keras.callbacks import EarlyStopping
from keras.regularizers import l2,l1
from keras.models import model_from_json
from sklearn.preprocessing import scale, Imputer
from scipy.signal import detrend
import scipy.signal as signal
import sys
from keras.layers.wrappers import Bidirectional


def make_conv_mdl(X, 
    filter_length=8,
    n_layers=10,
    penalty=0.,
    nb_filter=16,
    nb_fully_connected=256,
    drop_pct=0.2,
    pool_size=3,
    ):
    
    input_shape = X.shape[1:3]
    model = Sequential()

    # for ii in xrange(n_layers):
    nb_filter = 16
    filter_length=64
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            input_shape=input_shape,
            kernel_regularizer=l2(penalty)
        )
    )
    
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    

    model.add(
        MaxPooling1D(
            pool_size=pool_size,
            strides=1,
            padding='same'
        )
    )
# ==================================
    nb_filter = 32
    filter_length=32
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    

    model.add(
        MaxPooling1D(
            pool_size=pool_size,
            strides=1,
            padding='same'
        )
    )
# ==================================
    nb_filter = 64
    filter_length = 16
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    

    model.add(
        MaxPooling1D(
            pool_size=pool_size,
            strides=1,
            padding='same'
        )
    )
# ==================================

    nb_filter = 128
    filter_length = 8
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    

    model.add(
        MaxPooling1D(
            pool_size=pool_size,
            strides=1,
            padding='same'
        )
    )
# ===========================
    nb_filter = 256
    filter_length = 4
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    
    model.add(
        Convolution1D(
            filters=nb_filter,
            kernel_size=filter_length, 
            padding='same',
            kernel_regularizer=l2(penalty)
        )
    )
    

    model.add(
        MaxPooling1D(
            pool_size=pool_size,
            strides=1,
            padding='same'
        )
    )
# ==================================

    model.add(Dense(nb_fully_connected,activation='relu'))
    model.add(Dropout(drop_pct))

    model.add(Dense(nb_fully_connected,activation='relu'))
    model.add(Dropout(drop_pct))

    model.add(Dense(1, activation='sigmoid'))
    # model.compile(loss='mse', optimizer='adam', metrics=['mae'])
    # To perform (binary) classification instead:
    model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    return model

def make_tensor(timeseries, window_size=16):
    X = np.empty((timeseries.shape[0],window_size*2,timeseries.shape[-1]))
    for ii in xrange(window_size,timeseries.shape[0]-window_size):
        X[ii,:,:] = timeseries[ii-window_size:ii+window_size,:]
    return X

def make_tensor_RNN(timeseries,window_size=16):
    X = np.empty((timeseries.shape[0],window_size,timeseries.shape[-1]))
    for ii in xrange(window_size,timeseries.shape[0]-window_size):
        X[ii,:,:] = timeseries[ii-window_size:ii,:]
    return X

def makeRNN(X,batch_size,n_layers=5,nb_units=64,penalty=0.,drop_pct=0.,pool_size=3):
    input_shape = X.shape[1:3]
    model = Sequential()

    model.add(Bidirectional(LSTM(nb_units,stateful=True,return_sequences=False),input_shape=input_shape,batch_size=batch_size))
    # model.add(LSTM(nb_units,input_shape=input_shape,return_sequences=True))
    # model.add(
    #     MaxPooling1D(
    #         pool_size=pool_size,
    #         strides=1,
    #         padding='same'
    #     )
    # )

    # model.add(Bidirectional(LSTM(nb_units,return_sequences=True,stateful=True)))#,return_sequences=True,stateful=False)))

    # model.add(
    #     MaxPooling1D(
    #         pool_size=pool_size,
    #         strides=1,
    #         padding='same'
    #     )
    # )

    # model.add(Bidirectional(LSTM(nb_units)))

    # model.add(MaxPooling1D(pool_size=pool_size,strides=1,padding='same'))
    # # 
    # model.add(LSTM(32,return_sequences=True,stateful=True))
    # model.add(MaxPooling1D(pool_size=pool_size,strides=1,padding='same'))
    
    # model.add(LSTM(32,return_sequences=True,stateful=True))

    # model.add(Dense(nb_units,activation='relu',kernel_regularizer=l2(penalty)))
    # model.add(Dropout(drop_pct))
    # model.add(Dense(nb_units,activation='relu'))
    # model.add(Dropout(drop_pct))


    model.add(Dense(1, activation='sigmoid'))
    # model.compile(loss='mse', optimizer='adam', metrics=['mae'])
    # To perform (binary) classification instead:
    model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    return model


def fit(X,C,mdl,epochs=2,batch_size=128,validation_split=0.3):
    C = make_tensor(C,X.shape[1]/2)
    # if (valid_X is None) != (valid_y is None):
    #     raise ValueError('validation data are not correct')
    # if valid_y is not None:
    #     valid_y = make_tensor(valid_y,X.shape[1]/2)
    early_stopping=EarlyStopping(monitor='val_loss', min_delta=0.001, patience=1, verbose=0, mode='auto')
    mdl.fit(X,C,
        epochs=epochs,
        batch_size=batch_size,
        validation_split=validation_split,
        shuffle=False
        )
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
                  optimizer='adagrad',
                  metrics=['accuracy'])
    return loaded_model

def main():
    fname = sys.argv[1]
    model_name = sys.argv[2]

    data = sio.loadmat(fname)
    tip = data['tip']
    tip = cleanVar(tip)

    model = loadModel(model_name)
    window_size = model.layers[0].input_shape[1]/2

    X = make_tensor(tip,window_size)
    print('\nPredicting Contact Variable...')
    C = model.predict_classes(X)
    data['C'] = C[:,model.output_shape[1]/2]
    C = C.astype('bool')
    data['tip_scale'] = tip
    print('\nSaving Data to .mat file\n')
    sio.savemat(fname,data,oned_as='column')
    print('C Vector Saved\n')

    

if __name__ == '__main__':
    main()
