import pims
import numpy as np 
import matplotlib.pyplot as plt
from skimage.transform import (hough_line, hough_line_peaks,probabilistic_hough_line)
from skimage.filter import canny
from skimage.draw import circle
from matplotlib.widgets import Button
import scipy.io.matlab as sio 


def manualTrack(image,bckMean,plotTGL = 0):
    stopTrack = False
    plt.imshow(image,cmap = 'gray')
    rows, cols = image.shape
    plt.title('Click on the manipulator')
    manip = np.asarray(plt.ginput(1,timeout = 0))
    if len(manip)==0:
        y0 = []
        y1 = []
        thetaInit = []
        d = []
        stopTrack = True
        return y0,y1,thetaInit,d,stopTrack
    else:
            
        plt.show()

        roiRow,roiCol = circle(manip[0,1],manip[0,0],30)
        imROI = 255*np.ones_like(image)
        imROI[roiRow,roiCol]=image[roiRow,roiCol]
        BW = imROI<(bckMean-50)
            
        h,theta,d = hough_line(BW)
        _,thetaInit, d = hough_line_peaks(h, theta, d,min_distance=1,num_peaks=1)
        
        y0 = (d - 0 * np.cos(thetaInit)) / np.sin(thetaInit)
        y1 = (d - cols * np.cos(thetaInit)) / np.sin(thetaInit)
        if plotTGL:
            plt.imshow(image)
            plt.plot((0,cols),(y0,y1),'-r')
            plt.axis([0,640,0,480])
            plt.draw()
            plt.close('all')
        plt.close('all')
        thetaInit = np.mean(thetaInit)
        return y0,y1,thetaInit,d,stopTrack

def getBckgd(image):
    # get background measure
    plt.imshow(image,cmap = 'gray')
    plt.title('Click on background near manip')
    bckgd = np.asarray(plt.ginput(1))
         
    plt.draw()
    bckgdR,bckgdC = circle(bckgd[0,1],bckgd[0,0],5)
    bckMean = np.mean(image[bckgdR,bckgdC])
    plt.close('all')
    return bckMean

def manipExtract(image,thetaInit,last_y0 =[],last_y1 = [],lastDist = []):
    if np.issubdtype(image.dtype,'bool'):
        edge = image
    else:
        edge = canny(image)

    h,theta,d = hough_line(edge,theta = np.arange(thetaInit-.1,thetaInit+1,.01))
    # plt.imshow(image,cmap = 'gray')
    rows, cols = image.shape
    idx = 0
    y0 = last_y0
    y1 = last_y1
    
    # distOut = np.array([])
    _, angle, dist= hough_line_peaks(h, theta, d,min_distance=1,num_peaks=1)
    y0 = (dist - 0 * np.cos(angle)) / np.sin(angle)
    y1 = (dist - cols * np.cos(angle)) / np.sin(angle)

    return y0,y1,angle,dist

def getBW(y0,y1,image):
    from skimage.draw import polygon
    from skimage.morphology import dilation,disk
    from time import time
    rows, cols = image.shape
    '''
        t1 = time()
        rr,cc = polygon(np.array([y0[0],y0[1],y1[0],y1[1]]),np.array([0,0,cols,cols]),(rows,cols))

        imROI = np.zeros_like(image,dtype = 'bool')
        imROI[rr,cc]= 1

        selem = disk(8)
        BW = dilation(imROI,selem)
        BW = BW.astype('bool')

        imROI2 = 255*np.ones_like(image)
        imROI2[BW]=image[BW]
        t2 = time()
        print "%.5f" % (t2-t1)
     '''
    #faster version?
#   t1 = time()
    rr,cc = polygon(np.array([y0[0],y0[0],y1[0],y1[0]]),np.array([0,0,cols-15,cols+15]),(rows,cols))
    BW = np.zeros_like(image,dtype = 'bool')
    BW[rr,cc]= 1
    imROI = 255*np.ones_like(image)
    imROI[BW] = image[BW]
#   t2 = time()
#   print "%.5f" % (t2-t1)
    return imROI

def sanityCheck(y0,y1,image,frameNum = 0):
    plt.cla()
    plt.imshow(image,cmap = 'gray')
    rows,cols = image.shape
    lines = plt.plot((0,cols),(y0,y1),'-r')
    plt.axis([0,cols,0,rows])
    plt.gca().invert_yaxis()
    plt.title('Frame: %i' % frameNum)
    plt.draw()
    lines.pop(0).remove()

def frameSeek(fid,n):
    cont = False

    image = fid.get_frame(n)
    im = plt.imshow(image,cmap = 'gray')
    plt.title('Frame: %i' % n)
    plt.draw()

    while not cont:
        
        uIn = raw_input('Advance/Rewind how many frames? Default = +100. 0 exits: ')
        if len(uIn) == 0:
            uIn = 100
            n+=uIn
        else:
            n+=int(uIn)

        if uIn == '0':
            cont = True

        plt.cla()
        image = fid.get_frame(n)
        plt.imshow(image,cmap = 'gray')
        plt.title('Frame: %i' % n)
        plt.draw()

    return n


#=============================================#   

fname = 'N:\\3dTesting\\rat2015_15_JUN11_VG_B1_t01_Front.seq'

fid = pims.open(fname)


nFrames = fid.header_dict['allocated_frames']
ht = fid.height
wd = fid.width
print 'ht: %i \nwd: %i \nNumber of Frames: %i' % (ht,wd,nFrames)

idx = frameSeek(fid,0)


image = fid.get_frame(idx)

b = getBckgd(image)
y0,y1,th,d,stopTrack= manualTrack(image,b,plotTGL = 0)



n = nFrames
D = np.zeros(nFrames)
Y0 = np.zeros(nFrames)
Y1 = np.zeros(nFrames)
Th = np.zeros(nFrames)
d0 = d

plt.close('all')
disp = plt.figure()
plt.imshow(image,cmap = 'gray')
plt.draw()
print 'Tracking manipulator'

for ii in xrange(n-idx):
    manTrack = False
    image = fid.get_frame(idx)
    BW = getBW(y0,y1,image)
    T = BW<(b-50)
    y0,y1,th,d = manipExtract(T,th,y0,y1,lastDist = d0)
    
    # exception handling
    if (len(d)==0):
        print 'No edge detected, retrack' 
        manTrack = True
        y0,y1,th,d,stopTrack= manualTrack(image,b,plotTGL = 0)
        
    elif(np.mean(abs(d0-d))> 20):
        print 'Large distance detected, Retrack' 
        manTrack = True
        y0,y1,th,d,stopTrack= manualTrack(image,b,plotTGL = 0)

    while stopTrack:
        idx = frameSeek(fid,idx)
        image = fid.get_frame(idx)
        manTrack = True
        y0,y1,th,d,stopTrack= manualTrack(image,b,plotTGL = 0)

    d0 = d
    D[idx] = d
    Y0[idx] = y0
    Y1[idx] = y1
    Th[idx] = th

    # running average of last 5 theta and d:

    diffTh = np.mean(np.abs(np.diff(Th[idx-20:idx+1])))
    diffD = np.mean(np.abs(np.diff(D[idx-20:idx+1])))
    # stdTh = np.std(Th[-5:])
    # stdD = np.std(D[-5:])    
    
    if diffTh<10^-8:# this might need to be tweaked
        manTrack = True
        ## rebuild this so it looks at a 5 frame window into the past and says, hey, the last 5 are almost identical.
        print 'identical lines detected. Retrack' 
        idx -=5
        image = fid.get_frame(idx)
        y0,y1,th,d,stopTrack= manualTrack(image,b,plotTGL = 0)
        D[idx] = d
        Y0[idx] = y0
        Y1[idx] = y1
        Th[idx] = th
        idx+=1

    # output handling
   

    if (idx % 100 == 0):
        print idx
    if (idx % 100 == 0) or manTrack:
    	sanityCheck(y0,y1,image,idx)

    if (idx % 1000 ==0):
        plt.close('all')
        sio.savemat('testManipTrack.mat',{'D':D,'Y0':Y0,'Th':Th,'Y1':Y1})

    idx+=1

t2 = time.time()
print 'It took %f seconds' % (t2-t1)



