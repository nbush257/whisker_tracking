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
% also might want to extend the manipulator to cover the entire frame along
% the line of the manipulator.
% Also may want to restrict the manipulator to being within a certain angle
% of the previous manipulator.

front_manip_removed = rmManip(front,frontManip,startFrame,endFrame);
top_manip_removed = rmManip(top,topManip,startFrame,endFrame);

%%3D merge
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
