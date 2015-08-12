

tT = LoadWhiskers('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Top_F020001F040000_noClass.whiskers');
tM = LoadMeasurements('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Top_F020001F040000_whiskers.measurements');
fT = LoadWhiskers('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Front_F020001F040000_noClass.whiskers');
fM = LoadMeasurements('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Front_F020001F040000_whiskers.measurements');
fV = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Front_F020001F040000.avi';
tV = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Top_F020001F040000.avi';
stereo_c = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_stereo_calib_top_left.mat';
tracked_3D_fileName = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_F020001F040000_tracked_3D.mat';
tTManip = LoadWhiskers('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Top_F020001F040000_noClass.whiskers');
tMManip = LoadMeasurements('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Top_F020001F040000_manip.measurements');
fTManip = LoadWhiskers('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Front_F020001F040000_noClass.whiskers');
fMManip = LoadMeasurements('C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01\rat2015_08_APR09_VG_C2_t01_Front_F020001F040000_manip.measurements');
saveName = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C2_t01_F020001F040000_pre_merge.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = struct([]);
t = struct([]);
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

[t,f] = match_whisker_struct_by_ts(t,f);


t = trackBP(tV,t);
f = trackBP(fV,f);


%% Get Contact Still should edit this to check within windows as regards to findin peaks pos or neg.
% front
figure
[sortedFrontFrame,sortFront] = sort(frontFrames);
frontCind = sqrt([frontMeasure.tip_x].^2 + [frontMeasure.tip_y].^2);
frontCind(sortFront) = frontCind;
frontCind = tsmovavg(frontCind,'s',10);
%frontCind = bwfilt(topCind,300,1,150);
plot([frontMeasure.fid],frontCind)
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
[sortedTopFrames,sortTop] = sort(topFrames);

topCind = sqrt([topMeasure.tip_x].^2 + [topMeasure.tip_y].^2);
topCind(sortTop) = topCind;
topCind = tsmovavg(topCind,'s',10);
topCind(isnan(topCind))=  0;
%topCind = bwfilt(topCind,300,1,150);
plot(topCind)
baselinetop = ginput(1);
baselinetop = baselinetop(2);
topCind_rect = abs(topCind - baselinetop);

[~,locs,w] = findpeaks(topCind_rect,'MinPeakProminence',15);
plot(sortedTopFrames,topCind);
hold on
scatter(locs,topCind(locs));
topA = round(locs-w);
topB = round(locs+w);
scatter(topA,topCind(topA));
scatter(topB,topCind(topB));




frontContactStarts = frontFrames(frontA);
frontContactEnds = frontFrames(frontB);


topContactStarts = sortedTopFrames(topA);
topContactEnds = sortedTopFrames(topB);

C = logical(zeros(numFrames,1));
mergeFlags = logical(zeros(numFrames,1));
for ii = 1:length(topContactStarts)
    idx = topContactStarts(ii)+1:topContactEnds(ii)+1;
    idxMerge = (topContactStarts(ii)-50):(topContactEnds(ii)+50);
    idxMerge(idxMerge<1)=1;
    C(idx) = 1;
    mergeFlags(idxMerge) = 1;
end


for ii = 1:length(frontContactStarts)
    idx = frontContactStarts(ii)+1:frontContactEnds(ii)+1;
    idxMerge = frontContactStarts(ii)-50:frontContactEnds(ii)+50;
    C(idx) = 1;
    idxMerge(idxMerge<1)=1;
    mergeFlags(idxMerge) = 1;
end
figure
plot(sortedTopFrames,topCind)
title('Verify that contact is good')
hold on
plot(sortedFrontFrames,frontCind);
plot(C*500)
plot(mergeFlags*600)

%% load calibration
load(stereo_c)
calib_stuffz;
frontCam = calib(1:4);
topCam = calib(5:8);
A2B_transform = calib(9:10);
%% Output
save(saveName);
