% whisker ttracking readme NB
frontWhiskersName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Front_11008_20644.whiskers';
topWhiskersName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Top_11008_20644.whiskers';
frontVidName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Front.seq';
topVidName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_top.seq';

% is the manipulator loaded?
if exists('frontManip','var')
    frontManLoaded = 1;
else
    frontManLoaded = 0;
    
if exists('topManip','var')
    topManLoaded = 1;
else
    topMmanLoaded = 0;
end

startFrame = 11008;
endFrame =20644;


useX_top = 1;
useX_front = 1;
basepointSmaller_top = 0;
basepointSmaller_front = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Do Not Edit Below This Line %%%%%%%%%%%%
%%%%%%%%%%%%%% NB 3/12/2015 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
front  = LoadWhiskers(frontWhiskersName);
top  = LoadWhiskers(topWhiskersName);

for i = 1:4
    front = merge_matching_ts(front,useX_front,basepointSmaller_front); %(wstruct, useX,basepointSmaller) %you might have to repeat this if you track more than 2 whiskers.
    top = merge_matching_ts(top,useX_top,basepointSmaller_top);
end

front = trackBP(frontVidName,front,startFrame,endFrame);
top = trackBP(topVidName,top,startFrame,endFrame);
close all
%%
% if the manip has not already been tracked and saved into a mat file
if ~frontManLoaded
    frontManip = findManip(frontVidName,manipPresence);
end
if ~topManLoaded
    topManip = findManip(topVidName,manipPresence);
end
% If the manip HAS been tracked and saved, load the file in here.

%% Remove any tracked manipulator. Still need to implement a interpolation, still need to remove other stationary edges from the image if they are present.


[front_manip_removed,frontCP] = rmManip(front,manip_front,startFrame,endFrame);
[top_manip_removed,topCP] = rmManip(top,manip_top,startFrame,endFrame);

%%3D merge
% LOAD CALIB FILE!!!

for ii = 1:1000:length(front_manip_removed)
    parfor i = ii:ii+999
        [tracked_3D(i).x,tracked_3D(i).y,tracked_3D(i).z]= Merge3D_JAEv1(front_manip_removed(i).x,front_manip_removed(i).y,top_manip_removed(i).x,top_manip_removed(i).y,i,calib);
        tracked_3D(i).frame = front_manip_removed(i).time;
    end
    flnm=['3D_rat2105_06_0226_FEB26_vg_B2_t01_CLIP_11008_20644_F',sprintf('%06d',ii),'F',sprintf('%06d',ii+999)];
    save(flnm,'tracked_3D')
    clear tracked_3D
end

% 
% [top_proc,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(top_manip_removed,[],1,0);
% [front_proc,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(front_manip_removed,[],1,0);

A_camera = calib(1:4);%
B_camera = calib(5:8);
A2B_transform = calib([9 10]);

[CP,CP3D,CP3Draw,CPind,ext3D,manipfits,outliers] = calc_CP(top_manip_removed(1:1000),manip_top(startFrame:endFrame),C,useX_top,basepointSmaller_top,tracked_3D, A_camera,B_camera,A2B_transform,[0:999]); % Step 02B

for ii = 1:length(tracked_3D(1:1000))
	xy(ii).x=ext3D(ii).x;
	xy(ii).y=ext3D(ii).y;
	xy(ii).time=ext3D(ii).frame;
	xz(ii).x=ext3D(ii).x;
	xz(ii).y=ext3D(ii).z;
	xz(ii).time=ext3D(ii).frame;
end
