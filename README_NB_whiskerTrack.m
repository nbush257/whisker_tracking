% whisker ttracking readme NB

% Initialize with a settings file
open genSettings2D;



frontWhiskersName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Front_11008_20644.whiskers';
topWhiskersName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Top_11008_20644.whiskers';
frontVidName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_Front.seq';
topVidName = 'L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\rat2105_06_0226_FEB26_vg_B2_t01_top.seq';
topManipulatorName = '';
frontManipulatorName= '';

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

%smooth the initial segment in order to avoid weird kinks that throw off
% %the basepoint
%probably don't want to do this.
% front = smoothInitSegment2D(front);
% top = smoothInitSegment2D(top);


%% The manip should generally be found earlier; the script goes through the whole seq and takes some time.
%%the functions here are primarily for reference
%%if the manip has not already been tracked and saved into a mat file

%   frontManip = findManip(frontVidName,manipPresence);
%   topManip = findManip(topVidName,manipPresence);


%% Remove any tracked manipulator. Still need to implement a interpolation, still need to remove other stationary edges from the image if they are present.
[front_manip_removed,frontCP] = rmManip(front,manip_front,startFrame,endFrame);
[top_manip_removed,topCP] = rmManip(top,manip_top,startFrame,endFrame);

%% make sure contact and CP are referenced the same.
topCP(~contact,:)=nan;
frontCP(~contact,:) = nan;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D merge
% LOAD CALIB FILE
[calib_fName,calib_pName] = uigetfile('Load the calib file','*.mat');
load([calib_pName calib_fName]);

savePath = uigetdir('Where do you want to save the merged tracking?')
cd(savePath)

% 3D Merge Whisker
for ii = 1:1000:length(front_manip_removed)
    parfor i = ii:ii+999
        [tracked_3D(i).x,tracked_3D(i).y,tracked_3D(i).z]= Merge3D_JAEv1(front_manip_removed(i).x,front_manip_removed(i).y,top_manip_removed(i).x,top_manip_removed(i).y,i,calib);
        tracked_3D(i).frame = front_manip_removed(i).time;
    end
    flnm=['3D_rat2105_06_0226_FEB26_vg_B2_t01_CLIP_11008_20644_F',sprintf('%06d',ii),'F',sprintf('%06d',ii+999)];
    save(flnm,'tracked_3D')
    clear tracked_3D
end

A_camera = calib(1:4);%
B_camera = calib(5:8);
A2B_transform = calib([9 10]);

%If you get weird results you might need to swith the cameras
% I should put a test in here to check that.


% takes care of short whiskers, order, and interpolation
tracked_3D_raw = tracked_3D;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THIS IS A SPECIFIC DATA FIX BECUASE MY SECOND POINT IS NOT GOOD. THIS DOES NOT
%GENERALIZE TO ALL DATA!!!!!!!!!!!!!!!
% rm2 = input('Are you sure you want to remove the second point? (y/n)','s')
% if strcmp(rm2,'y')
%     for i = 1:length(tracked_3D)
%         tracked_3D(i).x(2) = [];
%         tracked_3D(i).y(2) = [];
%         tracked_3D(i).z(2) = [];
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tracked_3D,shortWhisker] = clean3Dwhisker(tracked_3D);


%Only need to use one view. Currently using top.
[CP3D,tracked_3D,needToExtend] = get3DCP(top_manip_removed,manip_top,C,1,0,topCP,tracked_3D,B_camera,A_camera,A2B_transform,[manip_top.time]);

%linear fit to initial 3D segment.
clear BP;
for ii = 1:length(tracked_3D)
    x = tracked_3D(ii).x;
    y = tracked_3D(ii).y;
    z = tracked_3D(ii).z;
    [~,~,~,BP(ii,:)] = Process_BP_TH_PHI_v1(x,y,z,PT);
   
    clear x y z xOut yOut zOut
end    

%% Verify plots

for ii = 1: length(tracked_3D)
    x = tracked_3D(ii).x;
    y = tracked_3D(ii).y;
    z = tracked_3D(ii).z;
    
    plot3(x(1:10),y(1:10),z(1:10),'.')
   % plot3(x(1),y(1),z(1),'r*')
    ho
    plot3(BP(ii,1),BP(ii,2),BP(ii,3),'r*')
    pause(.1);
    cla
end



%% check that all vars are in correct format/data quality for E3D

CP = CP3D; clear CP3D;
data_QA;

save([PT.save '\' PT.TAG '_merged.mat']);
save([PT.save '\' PT.TAG '_E3D.mat'],'xw3d','yw3d','zw3d','PT','C','CP','TH','PHI','BP');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% % get 2D structs.
% for ii = 1:length(tracked_3D)
%     xy(ii).x=tracked_3D(ii).x;
%     xy(ii).y=tracked_3D(ii).y;
%     xy(ii).time=tracked_3D(ii).frame;
%     xz(ii).x=tracked_3D(ii).x;
%     xz(ii).y=tracked_3D(ii).z;
%     xz(ii).time=tracked_3D(ii).frame;
% end
%
% % load settings file;
% %
% % [xy_proc,~,~] = preprocessWhiskerData_postMerge(xy,PT,useX_front,basepointSmaller_front);
% % [xz_proc,~,~] = preprocessWhiskerData_postMerge(xz,PT,useX_top,basepointSmaller_top);
% % Calc BP using Process BP_TH_v5 in 2D
%
% %%   Use XY and X from XY to evaluate for Z
% clear xw yw zw
% new_x = {xy_proc.x};
% for ii = 1:length(xz)
%     new_z = polyval(polyfit(xz(ii).x,xz(ii).y,3),new_x{ii});
%     % process new x/new z
%     mini_xz(ii).x = new_x{ii};
%     mini_xz(ii).y = new_z;
%     mini_xz(ii).time = xz(ii).time;
%
% end
%
% %change nans to previous whisker.
% for i = 1:length(mini_xz)
%     if isnan(mini_xz(i).x)
%         mini_xz(i).x = mini_xz(i-1).x;
%         mini_xz(i).y = mini_xz(i-1).y;
%     end
% end
%
% [mini_xz_proc,~,~] = preprocessWhiskerData_postMerge(mini_xz,PT,useX_front,basepointSmaller_front);
%
%
% for ii = 1:length(xz)
%     output_3D(ii).x = mean([new_x{ii},mini_xz_proc(ii).x],2);
%     output_3D(ii).y = xy_proc(ii).y;
%     output_3D(ii).z = mini_xz_proc(ii).y;
%     output_3D(ii).frame = xy_proc(ii).time;
%     xw{ii}=output_3D(ii).x;
%     yw{ii}=output_3D(ii).y;
%     zw{ii}=output_3D(ii).z;
% end
%
%
% for i = 1:length(xw)
%     if isnan(xw{i})
%         i
%         xw{i} = [];
%         yw{i} = [];
%         zw{i} = [];
%     end
% end
%
%
%
% % Find final CP
% tic
%
% finalCP = nan(length(xw),3);
% finalCPind = nan(length(xw),3);
% for ii = 1:length(xw)
%     if ~isnan(CP3D(ii,1)) & ~isempty(xw{ii})
%         T=delaunayn([xw{ii} yw{ii} zw{ii}]);% needs to be an nx3 matrix
%         try
%             finalCPind(ii,:) = dsearchn([xw{ii},yw{ii},zw{ii}],T,CP3D(ii,:));
%             finalCP(ii,:) = [xw{ii}(finalCPind(ii)),yw{ii}(finalCPind(ii)),zw{ii}(finalCPind(ii))];
%         end
%
%     end
% end
% toc

