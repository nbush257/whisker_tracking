import sklearn.neural_network
import scipy.io.matlab as sio
import numpy as np
from scipy.signal import savgol_filter
import matplotlib.pyplot as plt
import sklearn.mixture
from scipy.signal import medfilt

data = sio.loadmat(r'C:\Users\guru\Desktop\tip_data\all_tip.mat')
X = data['all_tip']
breaks = np.squeeze(data['breaks'])


ss=0.
for ii in xrange(X.shape[1]):
    ss = ss+X[:,ii]**2
ss = np.sqrt(ss)
ss = savgol_filter(ss,5,3)
X = savgol_filter(X,5,3,axis=0)
ss_d = np.concatenate((np.array([0.]),np.diff(ss)))

subX = X[:breaks[10]]
subSS = ss[:breaks[10]]
subss_d = ss_d[:breaks[10]]

X_train =X#np.column_stack((subX))


from sklearn.mixture import BayesianGaussianMixture
clf = BayesianGaussianMixture(n_components=9)
clf.fit(X_train)
idx = clf.predict(X_train)



plt.plot(X)
plt.plot(idx)



idx2 = idx!=0
idx2 = medfilt(idx2,5)

from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
knclf = KNeighborsClassifier(n_neighbors = 10,
                             weights='distance',
                             algorithm='kd_tree')


X_train, X_test, y_train, y_test = train_test_split(X, idx2,test_size=0.33)


knclf.fit(X_train,y_train)
y_hat = knclf.predict(X)


save_dict = {'tip':X,'breaks':breaks,'X_smooth':X,'y_hat':y_hat}

sio.savemat('all_tip_labelled.mat',save_dict,oned_as='column')
