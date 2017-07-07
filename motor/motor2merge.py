import imp
trace = imp.load_source('trace',r'L:\Users\guru\Documents\hartmann_lab\proc\whisk\python\trace.py')


w_fname = r'D:\motor_data\_good\motor_collision_neg1_A0__t01_Top.whiskers'

W = trace.Load_Whiskers(w_fname)

nFrames = len(W)

for ii in xrange()