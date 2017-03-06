function manip = reformatManip(front_name,top_name)


load(front_name,'Y0','Y1');
manip.Y0_f = Y0;
manip.Y1_f = Y1;
clear Y0 Y1

load(top_name,'Y0','Y1');
manip.Y0_t = Y0;
manip.Y1_t = Y1;

