% whisker ttracking readme NB
frontWhiskersName = 'rat2015_04_vg_D1_t02_Front_3080_7500.whiskers';
topWhiskersName = 'rat2015_04_vg_D1_t02_Top_3080_7500.whiskers';
frontVidName = 'rat2015_04_vg_D1_t02_Front.seq';
topVidName = 'rat2015_04_vg_D1_t02_Top.seq';

startFrame = 3080;
endFrame =7500;

%% Load in the manipPresence.mat file

%% 
front  = LoadWhiskers(frontWhiskersName);
top  = LoadWhiskers(topWhiskersName);

front = merge_matching_ts(front,1,0); %(wstruct, useX,basepointSmaller)
top = merge_matching_ts(top,1,0);

front = trackBP(frontVidName,front,startFrame,endFrame);
top = trackBP(topVidName,top,startFrame,endFrame);
%% 
% if the manip has not already been tracked and saved into a mat file
frontManip = findManip(frontVidName,manipPresence);
topManip = findManip(topVidName,manipPresence);

% If the manip HAS been tracked and saved, load the file in here. 

%% Remove any tracked manipulator. Still need to implement a interpolation, still need to remove other stationary edges from the image if they are present. 
% also might want to extend the manipulator to cover the entire frame along
% the line of the manipulator. 
% Also may want to restrict the manipulator to being within a certain angle
% of the previous manipulator.

front_manip_removed = rmManip(front,frontManipOut,startFrame,endFrame);
top_manip_removed = rmManip(top,topManipOut,startFrame,endFrame);

[top_proc,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(top_manip_removed,[],1,0);
[front_proc,~,~,~] = preprocessWhiskerData_NoSlopeSmooth(front_manip_removed,[],1,0);
