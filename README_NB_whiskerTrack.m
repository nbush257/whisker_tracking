%%%%%%%%% THIS FILE IS DESIGNED TO BE UNEDITED %%%%%%%%%%%%%%%%%
%%% BY THE USER. ALL CHANGES SHOULD BE MADE IN THE SETTINGS %%%%
%%% FILE YOU CREATE, OR TO THE FILENAMES OF YOUR DATA %%%%%%%%%%
%%%. THAT SAID, IT IS PRUDENT TO RUN IT LINE LINE SO YOU %%%%%%%
%%%CAN MAKE CHANGES TO YOUR DATA IF PROBLEMS ARISE %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This file takes 2 .whiskers files, 3D merges them, and saves the
%%% appropriate data for E3D. If you do not want to use raw .whiskers files
%%% you will have to set 'front' and 'top' to your data struct.

%%%     REQUIREMENTS: 
%%%         1) Tracked Whiskers
%%%         2) Contact Logical
%%%         3) Tracked Manipulators
%%%         4) Stereo Camera Calibration 
%%%         5) Avi files of your clip.


%%% For 2 Camera Merges, make sure A  = front = left; B = top = right.

%% Get data specific information
% get pix2m3D fron merge
open pix2m3D;
% Initialize with a settings file, run it.
open genSettings2D;

%% Set paths and names for loading in data

% Need to inclhude a check that that file exists. 

% clip whisker files
frontWhiskersName = [PT.path '\' PT.TAG '_Front.whiskers'];
topWhiskersName = [PT.path '\' PT.TAG '_Top.whiskers'];

% file for the clip avi.
frontVidName = [PT.path '\' PT.TAG '_Front.avi'];
topVidName = [PT.path '\' PT.TAG '_Top.avi'];

% all manipulatror
frontManipulatorName= [PT.path '\' PT.dataname '_manip_Front.mat'];
topManipulatorName = [PT.path '\' PT.dataname '_manip_Top.mat'];

contactName = [PT.path '\' PT.TAG '_contacts.mat'];

calibName = [PT.path '\' PT.dataname '_calibration.mat'];
% check existence of the input filenames
checkDataExistence;
%
savePath = uigetdir(PT.path,'Where do you want to save the merged tracking?');

% Frames are inclusive and indexed at 1
startFrame = PT.Frames(1);
endFrame =PT.Frames(2);

% Generally, useX = 1. For whiskers on the animal's right,
% basepoint_smaller is often 0, else 1.
useX_top = 1; % Should we sort on X?
useX_front = 1;
basepointSmaller_top = 0; % Is the basepoint smaller or larger than teh rest of the whisker?
basepointSmaller_front = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Do Not Edit Below This Line %%%%%%%%%%%%
%%%%%%%%%%%%%% NB 3/12/2015 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Load whisker,manipulator, and contact data
load(contactName)
load(frontManipulatorName)
load(topManipulatorName)

if ~exist('C','var')
    warning('There is not contact variable associated with this dataset')
end
if ~exist('front','var')
    front  = LoadWhiskers(frontWhiskersName);
end
if ~exist('top','var')
    top  = LoadWhiskers(topWhiskersName);
end

%% Merges all whiskers in a frame together. 
front = merge_matching_ts(front,useX_front,basepointSmaller_front); 
top = merge_matching_ts(top,useX_top,basepointSmaller_top);
%% Track the basepoint
front = trackBP(frontVidName,front);
top = trackBP(topVidName,top);
close all

%% The manip should generally be found earlier; the script goes through the whole seq and takes some time.
%%the functions here are primarily for reference
%%if the manip has not already been tracked and saved into a mat file

%   frontManip = findManip(frontVidName,manipPresence);
%   topManip = findManip(topVidName,manipPresence);


%% Remove any tracked manipulator and calculate CP. This code takes some time
[front_manip_removed,frontCP] = rmManip(front,manip_front,startFrame,endFrame);
[top_manip_removed,topCP] = rmManip(top,manip_top,startFrame,endFrame);
%

%% Interpolate 2D Whiskers. VERY slow. Unknown effect on result. Kept for reference and posterity.
% front_manip_removed_int = interp2D_wstruct(front_manip_removed(1));
% top_manip_removed_int = interp2D_wstruct(top_manip_removed(1));


%% Remove the contact point if there is no contact (the CP
topCP(~C,:) = nan;
frontCP(~C,:) = nan;

%% Make sure no emptys in 3D merge input
for ii = 1:length(top_manip_removed)
    if isempty(top_manip_removed(ii).x)
        top_manip_removed(ii).x = top_manip_removed(ii-1).x;
        top_manip_removed(ii).y = top_manip_removed(ii-1).y;
    end
    
    if isempty(front_manip_removed(ii).x)
        front_manip_removed(ii).x = front_manip_removed(ii-1).x;
        front_manip_removed(ii).y = front_manip_removed(ii-1).y;
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D merge
% Load Calibration file data.
cd(savePath)

load(calibName);
A_camera = calib(1:4);
B_camera = calib(5:8);
A2B_transform = calib([9 10]);


% 3D Merge Whisker % Might want to try to make the seed whisker variable.
minDS = .40;% sets the minimum internode distance.
minWhiskerSize = 20; % in # of nodes
N = 20; % I think this is the number of fits to try. More should give a stabler fit.

%Maybe only look at +- 100 around contact.

tracked_3D = struct([]);

%% This control breaks on the last
tic;
step = 1000;% Saves every 1000 frames
% Outer loop is big serial chunks that saves every [step] frames
for ii = 1:step:length(front_manip_removed)
    
    % Makes sure we don't try to access a frame past the last frame.
    if (ii+step-1)>length(front_manip_removed)
        iter = length(front_manip_removed)-ii;
    else
        iter = step-1;
    end
    % Parallel for loop which does the actual merging. Gets batches from
    % the current outer loop.
    parfor i = ii:ii+iter
        close all
        merge_x = [];merge_y = [];merge_z = [];
        DS = minDS;
        [merge_x,merge_y,merge_z]= Merge3D_JAEv1(front_manip_removed(i).x,front_manip_removed(i).y,top_manip_removed(i).x,top_manip_removed(i).y,i,calib,'wm_opts',{'DS',DS,'N',N});
        
        % The while loop steps DS up until either a satisfactory whisker is reached or DS gets too big.
        while length(merge_x)<minWhiskerSize
            DS = DS+.05;
            [merge_x,merge_y,merge_z]= Merge3D_JAEv1(front_manip_removed(i).x,front_manip_removed(i).y,top_manip_removed(i).x,top_manip_removed(i).y,i,calib,'wm_opts',{'DS',DS,'N',N});
            if DS>=2
                break
            end
        end% end while
        % Save into workspace
        tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
        tracked_3D(i).frame = front_manip_removed(i).time;
    end
    flnm=[PT.path '\' PT.TAG '_rawMerged.mat'];
    save(flnm,'tracked_3D')
end
timer = toc;
fprintf('It took %.1f seconds to merge %i frames \n',timer,length(tracked_3D));

%% Clean whiskers and verify merge
% Takes care of short whiskers, order, and interpolation
[tracked_3D_clean,shortWhisker] = clean3Dwhisker(tracked_3D);

% use to visually inspect the merge
figure
for ii =1:100
    [check_top,check_front] = BackProject3D(tracked_3D_clean(ii),B_camera,A_camera,A2B_transform);
    
    subplot(121);
    plot(check_front(:,1),check_front(:,2),'.')
    hold on
    plot(front_manip_removed(ii).x,front_manip_removed(ii).y,'r.')
    title('Front')
    legend({'Back Project','Original Tracking'});
    subplot(122);
    plot(check_top(:,1),check_top(:,2),'.')
    hold on
    plot(top_manip_removed(ii).x,top_manip_removed(ii).y,'r.')
    legend({'Back Project','Original Tracking'});
    title('Top')
    pause(.01)
    clf
end
close all

%% Get Contact Point
[CP,tracked_3D_extended,needToExtend] = get3DCP(top_manip_removed,manip_top,C,1,0,topCP,tracked_3D_clean,B_camera,A_camera,A2B_transform,[manip_top.time]);
% Visually inspect CP
cpCheck = figure;
contactFrames = find(~isnan(CP(:,1)));
for i = 1:100
    ii = contactFrames(i);
    plot3(tracked_3D_extended(ii).x,tracked_3D_extended(ii).y,tracked_3D_extended(ii).z,'.')
    hold on
    plot3(CP(ii,1),CP(ii,2),CP(ii,3),'r*')
    legend({'Whisker','Contact Point'});
    pause(.01)
    clf
end
%% check that all vars are in correct format/data quality for E3D
data_QA;

save([PT.save '\' PT.TAG '_merged.mat']);
save([PT.save '\' PT.TAG '_E3D.mat'],'xw3d','yw3d','zw3d','C','CP');

