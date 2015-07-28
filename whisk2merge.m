close all force
clear
NAME.path = 'D:\data\tracked\2015_06\rat2015_06_0226_FEB26_vg_C1_t01\';
NAME.saveFolder = 'D:\data\tracked\2015_06\rat2015_06_0226_FEB26_vg_C1_t01\';
NAME.tag = 'rat2015_06_0226_FEB26_vg_C1_t01_';
frames = [020001 040000];
NAME.frames = sprintf('F%06iF%06i',frames(1),frames(2));
%% Load in data and set paths for loading and saving.
fprintf('Loading Data...')
tT = LoadWhiskers([NAME.path NAME.tag 'Top_' NAME.frames '_whisker.whiskers']);
tM = LoadMeasurements([NAME.path NAME.tag 'Top_' NAME.frames '_whisker.measurements']);
fT = LoadWhiskers([NAME.path NAME.tag 'Front_' NAME.frames '_whisker.whiskers']);
fM = LoadMeasurements([NAME.path NAME.tag 'Front_' NAME.frames '_whisker.measurements']);
fV = [NAME.path NAME.tag 'Front_' NAME.frames '.avi'];
tV = [NAME.path NAME.tag 'Top_' NAME.frames '.avi'];
stereo_c = [NAME.path NAME.tag 'stereo_calib.mat'];
tracked_3D_fileName = [NAME.path NAME.tag NAME.frames '_tracked_3D.mat'];
tTManip = LoadWhiskers([NAME.path NAME.tag 'Top_' NAME.frames '_manip.whiskers']);
tMManip = LoadMeasurements([NAME.path NAME.tag 'Top_' NAME.frames '_manip.measurements']);
fTManip = LoadWhiskers([NAME.path NAME.tag 'Front_' NAME.frames '_manip.whiskers']);
fMManip = LoadMeasurements([NAME.path NAME.tag 'Front_' NAME.frames '_manip.measurements']);
savePrepLoc = [NAME.saveFolder NAME.tag NAME.frames '_preMerge.mat'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the labeled whisker from the measurents files.
numFrames = max([fM.fid])+1;
frontMeasure = fM([fM.label]==0);
ID = [[frontMeasure.fid];[frontMeasure.wid]]';
traceID = [[fT.time];[fT.id]]';
traceIDX = ismember(traceID,ID,'rows');
f = fT(traceIDX);

topMeasure = tM([tM.label]==0);
ID = [[topMeasure.fid];[topMeasure.wid]]';
traceID = [[tT.time];[tT.id]]';
traceIDX = ismember(traceID,ID,'rows');
t = tT(traceIDX);

fprintf('Done Loading')
%% Track the base point
t = trackBP(tV,t);
f = trackBP(fV,f);
%% Fill in the whisker structs with empties if untracked
clear tTemp
tTemp(numFrames) = t(end);
tTemp([t.time]+1) = t;
t = tTemp;
clear tTemp

clear fTemp
fTemp(numFrames) = f(end);
fTemp([f.time]+1) = f;
f = fTemp;
clear fTemp

clear tMTemp
tMTemp(numFrames) = topMeasure(end);
tMTemp([topMeasure.fid]+1) = topMeasure;
topMeasure = tMTemp;
clear tMTemp

clear fMTemp
fMTemp(numFrames) = frontMeasure(end);
fMTemp([frontMeasure.fid]+1) = frontMeasure;
frontMeasure = fMTemp;
clear fMTemp

if length(f)~=numFrames | length(t)~=numFrames
    error('front and top not of equal length to the number of frames in the clip. This probably means there are some frames at the end of the clip that dont have a tracked whisker')
end


%% Get the tip position for top and front for use in contact detection.
fprintf('\nGetting Contact')
% Untracked are set as NaN
for ii = 1:numFrames
    if isempty(topMeasure(ii).tip_x)
        top_tip(ii).x = NaN;
        top_tip(ii).y = NaN;
        top_tip(ii).time = ii-1;
    else
        
        top_tip(ii).x = topMeasure(ii).tip_x;
        top_tip(ii).y = topMeasure(ii).tip_y;
        top_tip(ii).time = ii-1;
    end
    if isempty(frontMeasure(ii).tip_x)
        front_tip(ii).x = NaN;
        front_tip(ii).y = NaN;
        front_tip(ii).time = ii-1;
    else
        
        front_tip(ii).x = frontMeasure(ii).tip_x;
        front_tip(ii).y = frontMeasure(ii).tip_y;
        front_tip(ii).time = ii-1;
    end
    
    
end

%% Get contact
% use tip position as an indicator; find the peaks and corresponding widths
% to flag contact.
frontCind = sqrt([front_tip.x].^2 + [front_tip.y].^2);
for kk = 2:length(frontCind)
    
    if isnan(frontCind(ii))
        frontCind(ii) = frontCind(ii-1);
    end
end

frontCind = tsmovavg(frontCind,'s',30);
plot(frontCind)
baselineFront = ginput(1);
baselineFront = baselineFront(2);
frontCind_rect = abs(frontCind - baselineFront);

[~,locs,w] = findpeaks(frontCind_rect,'MinPeakProminence',15);
plot(frontCind);
hold on
scatter(locs,frontCind(locs));
frontA = round(locs-w);
frontB = round(locs+w);
scatter(frontA,frontCind(round(frontA)));
scatter(frontB,frontCind(round(frontB)));

% top
figure
topCind = sqrt([top_tip.x].^2 + [top_tip.y].^2);
for kk = 2:length(topCind)
    
    if isnan(topCind(ii))
        topCind(ii) = topCind(ii-1);
    end
end

topCind = tsmovavg(topCind,'s',10);
plot(topCind)
baselinetop = ginput(1);
baselinetop = baselinetop(2);
topCind_rect = abs(topCind - baselinetop);

[~,locs,w] = findpeaks(topCind_rect,'MinPeakProminence',15);
plot(topCind);
hold on
scatter(locs,topCind(locs));
topA = round(locs-w);
topB = round(locs+w);
scatter(topA,topCind(topA));
scatter(topB,topCind(topB));
topA(topA<1)=1;
frontA(frontA<1)=1;


frontFrames= [front_tip.time];
frontContactStarts = frontFrames(round(frontA));
frontContactEnds = frontFrames(round(frontB));



topFrames= [top_tip.time];
topContactStarts = topFrames(round(topA));
topContactEnds = topFrames(round(topB));
% Use the peaks to mark contact in the logical 'C'

% Use windows around contact regions to only merge frames near contact.
% Will prevent us from merging frames where nothing is happening.

%% Manual get contact
%Use this if it is easier to spot contact manually (usually larger contact
% bouts
subplot(211)
title('Click on the left and right of each contact period')
plot(frontCind)
subplot(212)
plot(topCind)
ui = ginput;
frontA = ui(1:2:end,1);
frontB = ui(2:2:end,1);
%%

C = logical(zeros(numFrames,1));
mergeFlags = logical(zeros(numFrames,1));
for ii = 1:length(topContactStarts)
    idx = topContactStarts(ii)+1:topContactEnds(ii)+1;
    idxMerge = (topContactStarts(ii)-30):(topContactEnds(ii)+30);
    idxMerge(idxMerge<1)=1;
    idxMerge(idxMerge>numFrames) = numFrames;
    C(idx) = 1;
    mergeFlags(idxMerge) = 1;
end


for ii = 1:length(frontContactStarts)
    idx = frontContactStarts(ii)+1:frontContactEnds(ii)+1;
    idxMerge = frontContactStarts(ii)-30:frontContactEnds(ii)+30;
    idxMerge(idxMerge<1)=1;
    idxMerge(idxMerge>numFrames) = numFrames;
    
    C(idx) = 1;
    mergeFlags(idxMerge) = 1;
end
close all
% Visualize contact and merge flags to see that it makes sense

figure
plot(topCind)
title('Verify that contact is good')
hold on
plot(frontCind);
plot(C*500)
plot(mergeFlags*600)
pause




%% Set merge flags to zero if both views don't have a whisker
for ii = 1:numFrames
    if isempty(t(ii)) | isempty(f(ii))
        mergeFlags(ii) = 0
        continue
    end
    if isempty(t(ii).x) | isempty(f(ii).x)
        mergeFlags(ii)=0;
    end
end


%% convert to doubles
fprintf('\nSaving to HDD')
for ii = 1:numFrames
    t(ii).x = double(t(ii).x);
    t(ii).y = double(t(ii).y);
    
    f(ii).x = double(f(ii).x);
    f(ii).y = double(f(ii).y);
end
%% Save to HDD
save(savePrepLoc)
fprintf('\nAll Done! Your data are ready to merge!\n')
