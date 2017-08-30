import pims
import glob
import shutil
import os
import sys

def checkPairs(w_path) :
    d_front = glob.glob(w_path + '\*Front.avi')
    d_top = glob.glob(w_path + '\*Top.avi')
    # d_front_whiskers = glob.glob(w_path + '\*Front.whiskers')
    # d_top_whiskers = glob.glob(w_path + '\*Top.whiskers')

    mismatch = os.path.join(w_path, 'mismatch')
    paired = os.path.join(w_path, 'paired_and_matched')
    if not os.path.isdir(mismatch):
        os.mkdir(mismatch)
    if not os.path.isdir(paired):
        os.mkdir(paired)

    for file_front in d_front:
        token = file_front[:-9]
        file_top = token + 'Top.avi'
        file_front_whiskers = file_front[:-3] + '.whiskers'
        file_top_whiskers = file_top[:-3] + '.whiskers'

        # if there is no corresponding view, then the file remains in the root folder (if no front but a top, does not get checked for, if no top but front, passes
        if file_top in d_top:
            V_front = pims.Video(file_front)
            V_top = pims.Video(file_top)

            if len(V_front) != len(V_top):
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
                if os.isfile(file_front_whiskers):
                    shutil.move(file_front_whiskers, paired)
                if os.isfile(file_top_whiskers):
                    shutil.move(file_top_whiskers, paired)
        else:
            pass


if __name__=='__main__':
    #pass the path of the video files in as a command line argument
    w_path = sys.argv[1]
    checkPairs(w_path)