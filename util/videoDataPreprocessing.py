import pims
import numpy
import matplotlib.pyplot as plt
import subprocess
import os
from glob import glob


def seq2avi(seqPath,aviPath):

	f = os.listdir(path)
	f = list(set(glob(path + '*.seq')) - set(glob(path + '*calib*.seq')))
	for file in f:
		fileAVI = os.path.split(file)[1]
		fileAVI = os.path.splitext(fileAVI)[0] + '.avi'
		subprocess(['clexport','-i',file,'-f','avi','-cv','0','-o',aviPath,'-ofs',fileAVI])
