import glob
import shutil
import os
import sys
import re
sys.path.append(r'L:\Users\guru\Documents\hartmann_lab\proc\whisk\python')
from trace_2 import Load_Whiskers,Save_Whiskers
def checkPairs(w_path) :

    # d_front = glob.glob(os.path.join(w_path,'*front.avi'))
    # d_top = glob.glob(os.path.join(w_path ,'*top.avi'))
    d_front_whiskers = glob.glob(w_path + '\*front_labelled.whiskers')
    d_top_whiskers = glob.glob(w_path + '\*top_labelled.whiskers')

    mismatch = os.path.join(w_path, 'mismatch')
    paired = os.path.join(w_path, 'paired_and_matched')
    if not os.path.isdir(mismatch):
        os.mkdir(mismatch)
    if not os.path.isdir(paired):
        os.mkdir(paired)

    for file_front in d_front_whiskers:
        token = re.split('front_labelled.whiskers',file_front)[0]
        print('Working on {}'.format(token[:-1]))
        file_top = token + 'top_labelled.whiskers'
        file_front_video = token+'front.avi'
        file_top_video = token+'top.avi'

        # if there is no corresponding view, then the file remains in the root folder (if no front but a top, does not get checked for, if no top but front, passes
        if file_top in d_top_whiskers:
            w_top = Load_Whiskers(file_top)
            w_front = Load_Whiskers(file_front)
            l_top = max(w_top.keys())
            l_front = max(w_front.keys())

            if l_front != l_top:
                # move to mismatch if there are an uneven number of frames
                shutil.move(file_front, mismatch)
                shutil.move(file_top, mismatch)
                if os.path.isfile(file_front_video):
                    shutil.move(file_front_video, mismatch)
                if os.path.isfile(file_top_video):
                    shutil.move(file_top_video, mismatch)
            else:
                # this is the success case
                shutil.move(file_front, paired)
                shutil.move(file_top, paired)
                if os.path.isfile(file_front_video):
                    shutil.move(file_front_video, paired)
                if os.path.isfile(file_top_video):
                    shutil.move(file_top_video, paired)
        else:
            pass

def removeFirstFrame(w):
    w.pop(0)
    for fid,frame in w.iteritems():
        w[fid-1] = w.pop(fid)

def removeLastFrame(w):
    last_fid = max(w.keys())
    w.pop(last_fid)

def removeFrame(w,which_frame):
    if which_frame=='first':
        removeFirstFrame(w)
    elif which_frame=='last':
        removeLastFrame(w)
    else:
        raise ValueError('Improper frame deletion choice')

if __name__=='__main__':
    #pass the path of the video files in as a command line argument
    if len(sys.argv)==2:
        w_path = sys.argv[1]
        checkPairs(w_path)

    elif len(sys.argv)==3:
        filename = sys.argv[1]
        which_frame = sys.argv[2]

        w = Load_Whiskers(filename)
        removeFrame(w,which_frame)
        filename_out = os.path.splitext(filename)[0]+'[matched]'+os.path.splitext(filename)[1]
        Save_Whiskers(filename_out,w)
    else:
        raise ValueError('Improper input argument number')



