%% Step 00
%load_whiskers % Step 0A
load_blocks
top_norepeats = merge_matching_ts(all_top,1,0); % Step 00B
front_norepeats = merge_matching_ts(all_front,1,0); % Step 00B
[top_matched,front_matched] = match_whisker_struct_by_ts(top_norepeats,front_norepeats); % Step 00C
[~,top_manip_matched] = match_whisker_struct_by_ts(top_norepeats,top_manip); % Step 00C
[top_proc_noSmooth,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(top_matched,[],1,1); % Step 00D
[front_proc_noSmooth,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(front_matched,[],1,0); % Step 00D

for ii = 1:length(top_manip_matched)
	top_manip_matched_times(ii)=top_manip_matched(ii).time;
end

for i = 1:500
    plot(front_proc_noSmooth(i).x,front_proc_noSmooth(i).y)
    pause(.1)
end




%% Step 01 --Parallelizeable

%for ii = 1:1000:length(front_proc_noSmooth) % THIS LOOP IS TO RUN LOTS OF
%STUFF OVERNIGHT WITHOUT MEMORY ISSUES. 

	parfor ll = 9451:9800%this should be the frames I want
		[tracked_3D(ll).x,tracked_3D(ll).y,tracked_3D(ll).z]=...
		Merge3D_JAEv1(front_proc_noSmooth(ll).x,front_proc_noSmooth(ll).y,top_proc_noSmooth(ll).x,top_proc_noSmooth(ll).y,ll,calib);
		tracked_3D(ll).frame = front_proc_noSmooth(ll).time;
	end
	% Change the below name appropriately for your data
	%flnm=['141120_rat1446_E1_merge3D_NoSlopeSmooth_BPSmooth_F',sprintf('%06d',ii),'F',sprintf('%06d',ii+999)];
	%save(flnm,tracked_3D)
	%clear tracked_3D
    %end
    
% for i = 9451:9800
%     plot3(tracked_3D(i).x,tracked_3D(i).y,tracked_3D(i).z)
%     pause(.1)
%     axis equal
% end
% 


%% Step 02
A_camera = {fc_left,cc_left,kc_left,alpha_c_left}; % Step 02B
B_camera= {fc_right,cc_right,kc_right,alpha_c_right}; % Step 02B
A2B_transform = {om,T}; % Step 02B
%% Set stop and start of your frames in struct indices -- be sure these match your contact (C) logical, which may be in frames
start = 9451;
stop = 9800;
startframe = front_proc_noSmooth(start).time;
stopframe = front_proc_noSmooth(stop).time;
[CP,CP3D,CP3Draw,CPind,ext3D,manipfits,outliers] =...
 calc_CP(top_proc_noSmooth(start:stop),top_manip_matched,C(startframe:stopframe),1,0,tracked_3D(start:stop), A_camera,B_camera,A2B_transform,top_manip_matched_times); % Step 02B

% Set up structs for post-processing
for ii = 1:length(tracked_3D(start:stop))
	xy(ii).x=ext3D(ii).x;
	xy(ii).y=ext3D(ii).y;
	xy(ii).time=ext3D(ii).frame;
	xz(ii).x=ext3D(ii).x;
	xz(ii).y=ext3D(ii).z;
	xz(ii).time=ext3D(ii).frame;
end

%% This will need to change with each trial
Settings_VG2D_20141120_rat1446_E1_smoothCP_F001840F012839 % Run your Settings file


%% Step 02C
[xy_proc,~,~] = preprocessWhiskerData_postMerge(xy,PT,1,0);
[xz_proc,~,~] = preprocessWhiskerData_postMerge(xz,PT,1,0);

%   Use XY and X from XY to evaluate for Z
clear xw yw zw
new_x = {xy_proc.x};
for ii = 1:length(xz)
    new_z = polyval(polyfit(xz(ii).x,xz(ii).y,3),new_x{ii});
    % process new x/new z
    mini_xz(ii).x = new_x{ii};
    mini_xz(ii).y = new_z;
    mini_xz(ii).time = xz(ii).time;
    
end

[mini_xz_proc,~,~] = preprocessWhiskerData_postMerge(mini_xz,PT,1,0);

for ii = 1:length(xz)
    output_3D(ii).x = mean([new_x{ii},mini_xz_proc(ii).x],2);
    output_3D(ii).y = xy_proc(ii).y; 
    output_3D(ii).z = mini_xz_proc(ii).y; 
    output_3D(ii).frame = xy_proc(ii).time;
    xw{ii}=output_3D(ii).x;
    yw{ii}=output_3D(ii).y;
    zw{ii}=output_3D(ii).z;
end

% Find final CP
for ii = 1:length(xw)
	T=delaunayn([xw{ii} yw{ii} zw{ii}]); %needs to be an Nx3 input matrix
	finalCPind(ii,:) = dsearchn([xw{ii},yw{ii},zw{ii}],T,CP3D(ii,:));
	finalCP(ii,:) = [xw{ii}(finalCPind(ii)),yw{ii}(finalCPind(ii)),zw{ii}(finalCPind(ii))];
end

