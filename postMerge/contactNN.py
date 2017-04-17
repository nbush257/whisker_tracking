import scipy.io.matlab as sio
import sys
from keras.models import Sequential
from keras.layers import Dense,Convolution1D,Dropout,MaxPooling1D,AtrousConv1D,Flatten
from keras.layers.advanced_activations import LeakyReLU
from keras.regularizers import l2,l1
from keras.models import model_from_json
from sklearn.preprocessing import scale, Imputer
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import AdaBoostClassifier
from scipy.signal import detrend
import matplotlib.patches as patches
import scipy.signal as signal



def trainNN(X,C):
    leak = 0.3
    dropout_pct = 0.3
    penalty = 0
    # data = sio.loadmat(fid)
    # X = data['X']
    # C = data['C']
    # tip = data['tip']

    # X = cleanVar(X)
    # tip = cleanVar(tip)
    # apply a convolution 1d of length 3 to a sequence with 10 timesteps,
    # with 64 output filters
    ## ==========================
    model = Sequential()
    # model.add(Convolution1D(64,32, border_mode='same',input_dim=X.shape[-1],W_regularizer=l2(penalty)))
    # now model.output_shape == (None, 10, 64)
    model.add(Dense(4096,input_dim=X.shape[-1]))
    model.add(LeakyReLU(leak))
    # model.add(Dropout(0.5))
    # model.add(Dense(256,activation='relu'))
    # model.add(MaxPooling1D(pool_length=5, stride=None, border_mode='same'))
    # model.add(Dropout(dropout_pct))
    ## ==========================
    # model.add(Convolution1D(32, 32, border_mode='same', W_regularizer=l2(penalty)))
    # now model.output_shape == (None, 10, 64)
    # model.add(Dense(128,activation='relu'))
    # model.add(Dense(256))
    # model.add(LeakyReLU(leak))

    # model.add(MaxPooling1D(pool_length=5, stride=None, border_mode='same'))
    # model.add(Dropout(dropout_pct))
    # model.add(Dense(64))
    # model.add(LeakyReLU(leak))

    # model.add(MaxPooling1D(pool_length=5, stride=None, border_mode='same'))
    # model.add(Dropout(dropout_pct))
    ## ===========================
    # model.add(Convolution1D(8, 32, border_mode='same', W_regularizer=l2(penalty)))
    # model.add(MaxPooling1D(pool_length=5, stride=None, border_mode='same'))
    # now model.output_shape == (None, 10, 64)
    # model.add(Dense(256))
    # model.add(LeakyReLU(leak))
    #
    # # model.add(Dropout(0.5))
    # # model.add(Dense(32, activation='relu'))
    # model.add(Dropout(dropout_pct))
    # ==========================
    # model.add(Convolution1D(32, 10, border_mode='same',W_regularizer=l2(penalty)))
    model.add(Dense(4096))
    model.add(LeakyReLU(leak))
    #
    model.add(Dense(4096))
    model.add(LeakyReLU(leak))
    # model.add(Dropout(0.5))
    # model.add(Dense(16,activation='relu'))
    model.add(Dropout(dropout_pct))
    ## ==========================
    # now model.output_shape == (None, 10, 32)
    model.add(Dense(1, activation='sigmoid'))

    # sgd = keras.optimizers.SGD(lr=0.000000000001, momentum=0.0, decay=0.0, nesterov=True)
    model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])


    model.fit(X[:,None,:], C[:,None],
              nb_epoch=5,
              batch_size=128)
    # serialize model to JSON
    return model

def trainADA(fid):

    data = sio.loadmat(fid)
    X = data['X']
    C = data['C']

    #
    imp = Imputer()
    X = imp.fit_transform(X)
    X = scale(X)

    clf = AdaBoostClassifier()
    clf.fit(X,np.ravel(C))
    return clf
def trainSVM(fid):
    from sklearn.svm import SVC
    data = sio.loadmat(fid)
    tip = data['tip']
    X = data['X']
    C = data['C']

    tip = cleanVar(tip)
    clf = SVC(verbose=True)
    clf.fit(tip,np.ravel(C),C=.75,cache_size=1000)

    return clf


def cleanVar(x):
    imp = Imputer()
    x = imp.fit_transform(x)
    x = detrend(x,axis=0)
    x = scale(x)
    return x

def lagVector(x, filter_length=10, stride=1):
    from scipy.ndimage.interpolation import shift

    y = np.empty((x.shape[0],(filter_length*2)*x.shape[1]))
    count = 0
    for dim in xrange(x.shape[1]):
        temp = shift(x[:,dim],-filter_length)
        for ii in xrange(-filter_length+1, filter_length+1,stride):
            y[:,count] = shift(x[:,dim],ii)
            count+=1
    return y

def saveNN(model,save_file='model'):
    model_json = model.to_json()
    with open(save_file + ".json", "w") as json_file:
        json_file.write(model_json)
    # serialize weights to HDF5
    model.save_weights(save_file + ".h5")
    print("Saved model to disk")

## load data from new data

# fid = r'/home/nbush257/Desktop/contactTesting/tip_test_28_E1.mat'

def findC(tip_fid,model_fid,model_weights_fid):
    import scipy.io.matlab as sio
    data = sio.loadmat(tip_fid)
    tip = data['tip']
    X = data['X']

    imp = Imputer()
    tip = imp.fit_transform(tip)
    tip = scale(tip)

    X = imp.fit_transform(X)
    X = scale(X)

    json_file = open(model_fid,'r')
    loaded_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_json)
    loaded_model.load_weights(model_weights_fid)

    loaded_model.compile(loss='binary_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    C_pred = loaded_model.predict(X,batch_size=512,verbose=1)
    C_pred = C_pred
    C = np.zeros_like(C_pred)
    C[C_pred>=0.5]=1

    plt.plot(tip,'k')
    plt.plot(C)
    plt.show()
    return C,tip

def visFilters(model_fid,model_weights_fid,node=0):
    from keras.models import model_from_json
    json_file = open(model_fid, 'r')
    loaded_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_json)
    loaded_model.load_weights(model_weights_fid)

    loaded_model.compile(loss='binary_crossentropy',
                         optimizer='rmsprop',
                         metrics=['accuracy'])
    L1 = loaded_model.layers[0]
    L1_W = L1.get_weights()[0]
    plt.plot(L1_W[:,0,:,node])
    plt.show()

def saveSKlearnModel(clf,save_file='model'):
    from sklearn.externals import joblib
    joblib.dump(clf,save_file+'.pkl')

def applySVM(data_fid,model_fid):
    from sklearn.externals import joblib
    clf = joblib.load(model_fid)
    data = sio.loadmat(data_fid)
    X = cleanVar(data['X'])
    tip = cleanVar(data['tip'])
    C_pred = clf.predict(X)
    plt.plot(tip)
    plt.plot(C_pred)
    plt.show()
    return C_pred

if __name__ == '__main__':
    fid = sys.argv[1]#input('\nFull Path to matfile: ')
    data = sio.loadmat(fid)
    model_fid = 'contact_model.json'
    weights_fid = 'contact_model.h5'
    C,tip_scale = findC(fid,model_fid,weights_fid)
    data['C'] = C
    data['tip_scale'] = tip_scale
    print('\nsaving C vector...')
    sio.savemat(fid,data,oned_as='column')
    print('\nC vector saved')
#
# fid = r'/home/nbush257/Desktop/contactTesting/tip_test_45_B1.mat'
# model = trainNN(fid)
# contactNN.saveModel(model,'regularized_model')
# test_fid = r'/home/nbush257/Desktop/contactTesting/tip_test_28_E1.mat'
# model_fid = 'regularized_model.json'
# model_weights_fid = 'regularized_model.h5'
# contactNN.visFilters(model_fid,model_weights_fid)
