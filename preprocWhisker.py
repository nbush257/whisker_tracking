import os
import sys
pwd = os.getcwd()


w_fName = "N:\\2015_15\\tracked\\rat2015_15_JUN11_VG_B1_t01_Top_F000001F020000_whisker.whiskers"
m_fName = "N:\\2015_15\\tracked\\rat2015_15_JUN11_VG_B1_t01_Top_F000001F020000_whisker.measurements"
os.chdir("C:\\Users\\guru\\Documents\\hartmann_lab\\proc\\whisk32\\python\\")
import traceWhisk as t
import traj as j
fid_w = t.Load_Whiskers(w_fName)
fid_m = j.MeasurementsTable(m_fName)
