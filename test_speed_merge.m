% parfor ll = 9451:9800%this should be the frames I want
% 		[tracked_3D(ll).x,tracked_3D(ll).y,tracked_3D(ll).z]=...
% 		Merge3D_JAEv1(front_proc_noSmooth(ll).x,front_proc_noSmooth(ll).y,top_proc_noSmooth(ll).x,top_proc_noSmooth(ll).y,ll,calib);
% 		tracked_3D(ll).frame = front_proc_noSmooth(ll).time;
% end
    ll =9451
    
[tracked_3D(ll).x,tracked_3D(ll).y,tracked_3D(ll).z]=Merge3D_JAEv1(front_proc_noSmooth(ll).x,front_proc_noSmooth(ll).y,top_proc_noSmooth(ll).x,top_proc_noSmooth(ll).y,ll,calib);