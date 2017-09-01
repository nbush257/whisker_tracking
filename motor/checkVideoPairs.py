import pims
import glob
import shutil
import os
import sys
import re

def checkPairs(w_path) :
    d_front = glob.glob(os.path.join(w_path,'*front.avi'))
    d_top = glob.glob(os.path.join(w_path ,'*top.avi'))
    # d_front_whiskers = glob.glob(w_path + '\*Front.whiskers')
    # d_top_whiskers = glob.glob(w_path + '\*Top.whiskers')

    mismatch = os.path.join(w_path, 'mismatch')
    paired = os.path.join(w_path, 'paired_and_matched')
    if not os.path.isdir(mismatch):
        os.mkdir(mismatch)
    if not os.path.isdir(paired):
        os.mkdir(paired)

    for file_front in d_front:
        token = re.split('front.avi',file_front)[0]
        file_top = token + 'top.avi'
        file_front_whiskers = os.path.splitext(file_front)[0] + '.whiskers'
        file_top_whiskers = os.path.splitext(file_top)[0] + '.whiskers'

        # if there is no corresponding view, then the file remains in the root folder (if no front but a top, does not get checked for, if no top but front, passes
        if file_top in d_top:
            V_front = pims.open(file_front)
            V_top = pims.open(file_top)
            l_front = len(V_front)
            l_top = len(V_top)
            V_front.close()
            V_top.close()
            if l_front != l_top:
                # move to mismatch if there are an uneven number of frames
                shutil.move(file_front, mismatch)
                shutil.move(file_top, mismatch)
                if os.isfile(file_front_whiskers):
                    shutil.move(file_front_whiskers, mismatch)
                if os.isfile(file_top_whiskers):
                    shutil.move(file_top_whiskers, mismatch)
            else:
                # this is the success case
                shutil.move(file_front, paired)
                shutil.move(file_top, paired)
                if os.path.isfile(file_front_whiskers):
                    shutil.move(file_front_whiskers, paired)
                if os.path.isfile(file_top_whiskers):
                    shutil.move(file_top_whiskers, paired)
        else:
            pass


if __name__=='__main__':
    #pass the path of the video files in as a command line argument
    w_path = sys.argv[1]
    checkPairs(w_path)