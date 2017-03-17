function manip = reformatManip()
[front_name,path] = uigetfile('*Front*manip*.mat','load in the front manipulator');
top_name = uigetfile('*Top*manip*.mat','Load in the top manipulator',path);

load([path '/' front_name],'Y0','Y1');
manip.Y0_f = Y0;
manip.Y1_f = Y1;
clear Y0 Y1

load([path '/' top_name],'Y0','Y1');
manip.Y0_t = Y0;
manip.Y1_t = Y1;



