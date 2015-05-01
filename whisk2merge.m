tT = LoadWhiskers('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_noClass.whiskers');
tM = LoadMeasurements('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_whisker.measurements');
fT = LoadWhiskers('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_noClass.whiskers');
fM = LoadMeasurements('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_whiskers.measurements');
fV = 'D:\data\2015_08\avis\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000.avi';
tV = 'D:\data\2015_08\avis\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000.avi';
stereo_c = 'D:\data\2015_08\analyzed\rat2015_08_APR09_VG_C1_t01_stereo_calib.mat';
tracked_3D_fileName = 'D:\data\2015_08\analyzed\rat2015_08_APR09_VG_C1_t01_F000001F020001_tracked_3D.mat';
tTManip = LoadWhiskers('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_noClass.whiskers');
tMManip = LoadMeasurements('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_manip.measurements');
fTManip = LoadWhiskers('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_manip.whiskers');
fMManip = LoadMeasurements('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_manip.measurements');
savePrepLoc = 'D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_F000001F020001_preMerge.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



t = trackBP(tV,t);
f = trackBP(fV,f);

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


%% Get Contact Still should edit this to check within windows as regards to findin peaks pos or neg.
% front
figure
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


frontCind = sqrt([front_tip.x].^2 + [front_tip.y].^2);
frontCind = tsmovavg(frontCind,'s',10);
plot(frontCind)
baselineFront = ginput(1);
baselineFront = baselineFront(2);
frontCind_rect = abs(frontCind - baselineFront);

[~,locs,w] = findpeaks(frontCind_rect,'MinPeakProminence',10);
plot(frontCind);
hold on
scatter(locs,frontCind(locs));
frontA = round(locs-w);
frontB = round(locs+w);
scatter(frontA,frontCind(frontA));
scatter(frontB,frontCind(frontB));

% top
figure
topCind = sqrt([top_tip.x].^2 + [top_tip.y].^2);
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


frontFrames= [front_tip.time];
frontContactStarts = frontFrames(frontA);
frontContactEnds = frontFrames(frontB);

topFrames= [top_tip.time];
topContactStarts = topFrames(topA);
topContactEnds = topFrames(topB);

C = logical(zeros(numFrames,1));
mergeFlags = logical(zeros(numFrames,1));
for ii = 1:length(topContactStarts)
    idx = topContactStarts(ii)+1:topContactEnds(ii)+1;
    idxMerge = (topContactStarts(ii)-30):(topContactEnds(ii)+30);
    C(idx) = 1;
    mergeFlags(idxMerge) = 1;
end


for ii = 1:length(frontContactStarts)
    idx = frontContactStarts(ii)+1:frontContactEnds(ii)+1;
    idxMerge = frontContactStarts(ii)-30:frontContactEnds(ii)+30;
    C(idx) = 1;
    mergeFlags(idxMerge) = 1;
end
figure
plot(topCind)
title('Verify that contact is good')
hold on
plot(frontCind);
plot(C*500)
plot(mergeFlags*600)

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


%% load calibration
load(stereo_c)
calib_stuffz;
frontCam = calib(1:4);
topCam = calib(5:8);
A2B_transform = calib(9:10);

%save(savePrepLoc);


