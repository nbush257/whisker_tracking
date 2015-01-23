Hi!  Follow these instructions to take your raw output from Nathan Clack's WHISK program to SeNSE lab E3D-ready data.


Step 00: Preprocess your whisker frames


A) Load your .whiskers files. You can use load_blocks.m and change the relevant text information in 	order to do this in batch form.  You will want top and front camera data loaded, as well as data 	for the tracked manipulator in at least one camera.

B) If you have a whisker tracked more than once, use merge_matching_ts.m to combine these frames.  		This is useful if you have tracked the distal and proximal portions of a whisker separately 		because the manipulator got in the way. 

C) Match_whisker_struct_by_ts.m will output structs with whisker data from ONLY matching frame 			timestamps in the top and front camera views.

D) Smooth basepoints before merging: run preprocessWhiskerData.
		
		(Note: this process is time consuming and if you only need a subset of the data then use appropriate indexing to save unnecessary processing.  For subsequent steps, it will be use to also define the SAME INDICES of the output struct 
		i.e. [top_proc_noSmooth(2000:4000),~,~,~]=preprocessWhiskerData_NoSlopeSmooth(top_matched(2000:4000),[],1,1);)

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
Copy and Paste the following text into your MATLAB command line:

%% Step 00
load_whiskers % Step 0A
top_norepeats = merge_matching_ts(all_top,1,0); % Step 00B
front_norepeats = merge_matching_ts(all_front,1,0); % Step 00B
[top_matched,front_matched] = match_whisker_struct_by_ts(top_norepeats,front_norepeats); % Step 00C
[~,top_manip_matched] = match_whisker_struct_by_ts(top_norepeats,top_manip); % Step 00C
[top_proc_noSmooth,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(top_matched,[],1,1); % Step 00D
[front_proc_noSmooth,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(front_matched,[],1,0); % Step 00D

for ii = 1:length(top_manip_matched)
	top_manip_matched_times(ii)=top_manip_matched(ii).time;
end

%% Just keep *_proc_noSmooth, top_manip_matched, and top_manip_matched_times

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


Step 01: 3D Merge

A) Make sure you have loaded all of necessary subfunctions for 3D merge 
		(on the c0mm0n server in Ellis_Common/Merge3D/3dmergecode.zip)
	
	(Note: This code is "embarassingly parallel" and it is best to set up a parallel workgroup in your MATLAB occurence and use a parfor loop. Know that you cannot save within a parfor-loop, so nest the parfor inside a regular for-loop if you are processing several thousand frames -- this will allow you to intermittently clear your workspace and save the output 3D data.)

	(Note: I have made a slightly modified version of Merge3D that does not require you to load the calibration file for every frame.  Instead run calib_stuffz.m once and then use Merge3D_JAEv1 with the appropriate)

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
Copy and Paste the following text into your MATLAB command line:

need to load in calibration file (.mat) then run calib_stuffz
% outer loop is for processing subsets of the data

%% Step 01
for ii = 1:1000:length(front_proc_noSmooth)
	parfor ll = ii:ii+999 % this is the functional loop. You can comment the outer loop and just run this on the frames you want.
		[tracked_3D(ll).x,tracked_3D(ll).y,tracked_3D(ll).z]=...
		Merge3D_JAEv1(front_proc_noSmooth(ll).x,front_proc_noSmooth(ll).y,top_proc_noSmooth(ll).x,top_proc_noSmooth(ll).y,ll,calib);
		tracked_3D(ll).frame = front_proc_noSmooth(ll).time;
	end
	% Change the below name appropriately for your data
	flnm=['141120_rat1446_E1_merge3D_NoSlopeSmooth_BPSmooth_F',sprintf('%06d',ii),'F',sprintf('%06d',ii+999)];
	save(flnm,tracked_3D)
	clear tracked_3D
end
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



Step 02: Postprocess your whisker frames

A) At this point you need to do some grunt work and find the C logical -- contact frames.  The best way to do this, currently, is to manually inspect the video and record the first frame of contact and detachment.

B) Use calc_CP.m to find the contact point for each frame of contact

	(Note: If you have access to the original .seq files and would like to view the output of the extended whisker from calc_CP: 00) set up a frontseq and topseq object, 01) run BackProject3D.m, 02) use the find_deflection script with appropriate changes)

C) Decompose the 3D whisker frames into an XY and XZ coordinate system. Run preProcessWhiskerData_PostMerge.m to smooth Theta and Phi. You need to create a Settings file for this step.

D) The final step is to run RunProcessWhisker. The TH and PHI output graphs from this stage should look smooth, as should the BP graphs.  If these are acceptable, use your CP3D output from calc_CP and the dsearchn command to find the closest point on the whisker to the contact point.  Also, repopulate the BP matrix with the first points in your xw, yw, and zw vectors, and rename these to xw3d, yw3d, and zw3d.  

E) Final file format for E3D below.
	One file is called:
	Vg_DATA_3D_Merge',PT.TAG,'.mat  (inserting your tag in the 'PT.TAG' area)
	This included:
		xw3d
		yw3d
		zw3d

	These are all cell arrays with the length of the number of frames.  Each cell has the x, y, or z points that correspond with that frame.  None are empty.

	The other file is:
	Vg_DATA_3D_TH_PHI_C_CP_BP',PT.TAG,'.mat (again, with PT.TAG replaced)
	This includes (as in the title):
		TH - the theta angles at the base for every time frame, none are empty (not NaN's or 1's or 0's).
		PHI - the phi angle at the base for every time, again none are empty
		C -  a logical vector of length of number of frames.  0 for no contact, 1 for contact.
		CP - an Nx3 array (N being the number of frames) with the x,y,z contact point location for frames of contact (the others can be filled with NaN's or whatever)
		BP - another Nx3 array with the base points of the whiskers (probably just taking the appropriate point from xw3d, yw3d, zw3d)

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
Copy and Paste the following text into your MATLAB command line:

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

%% use: y for all, 200 nodes and 15 hz as default.

% Set up structs for post-processing
for ii = 1:length(tracked_3D(start:stop))
	xy(ii).x=ext3D(ii).x;
	xy(ii).y=ext3D(ii).y;
	xy(ii).time=ext3D(ii).frame;
	xz(ii).x=ext3D(ii).x;
	xz(ii).y=ext3D(ii).z;
	xz(ii).time=ext3D(ii).frame;
end

Settings_VG2D_20141120_rat1446_E1_smoothCP_F001840F012839 % Run your Settings file

% Step 02C
[xy_proc,~,~] = preprocessWhiskerData_postMerge(xy,PT,1,0);
[xz_proc,~,~] = preprocessWhiskerData_postMerge(xz,PT,1,0);

%%   Use XY and X from XY to evaluate for Z
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
	T=delaunayn([xw{ii} yw{ii} zw{ii}]);% needs to be an nx3 matrix
	finalCPind(ii,:) = dsearchn([xw{ii},yw{ii},zw{ii}],T,CP3D(ii,:));
	finalCP(ii,:) = [xw{ii}(finalCPind(ii)),yw{ii}(finalCPind(ii)),zw{ii}(finalCPind(ii))];
end
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


