% Use this to preprocess 2D data to E2D

%======================================
% may want to manually define contact!!
%=====================================
whiskerName = 'rat2015_06_FEB26_vg_C1_t01_Top_F040001F060000_whisker.whiskers';
measureName = 'rat2015_06_FEB26_vg_C1_t01_Top_F040001F060000_whisker.measurements';
videoName = 'D:\data\avis\2015_06\rat2015_06_FEB26_vg_C1_t01\rat2015_06_FEB26_vg_C1_t01_Top_F040001F060000.avi';

manipTraceName = 'D:\data\tracked\2015_06\rat2015_06_0226_FEB26_vg_C1_t01\rat2015_06_FEB26_vg_C1_t01_Top_F040001F060000_manip_2D.whiskers';
manipMeasureName = 'D:\data\tracked\2015_06\rat2015_06_0226_FEB26_vg_C1_t01\rat2015_06_FEB26_vg_C1_t01_Top_F040001F060000_manip_2D.measurements';

saveName = '';
isRight = 1;
%%
tT = LoadWhiskers(whiskerName);
tM = LoadMeasurements(measureName);
tTManip = LoadWhiskers(manipTraceName);
tMManip = LoadMeasurements(manipMeasureName);

tV = videoName;

numFrames = max([tT.time]);


topMeasure = tM([tM.label]==0);
ID = [[topMeasure.fid];[topMeasure.wid]]';
traceID = [[tT.time];[tT.id]]';
traceIDX = ismember(traceID,ID,'rows');
t = tT(traceIDX);



if isRight
    for ii = 1:length(t)
        t(ii).x = flipud(t(ii).x);
        t(ii).y = flipud(t(ii).y);
    end
end

t = trackBP(tV,t);

clear tTemp
tTemp(numFrames) = t(end);
tTemp([t.time]+1) = t;
t = tTemp;
clear tTemp

clear tMTemp
tMTemp(numFrames) = topMeasure(end);
tMTemp([topMeasure.fid]+1) = topMeasure;
topMeasure = tMTemp;
clear tMTemp

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
end


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


topFrames= [top_tip.time];
topContactStarts = topFrames(round(topA));
topContactEnds = topFrames(round(topB));

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

close all
% Visualize contact and merge flags to see that it makes sense

figure
plot(topCind)
title('Verify that contact is good')
ho
plot(C*500)
pause

%% Set merge flags to zero if both views don't have a whisker

for ii = 1:numFrames
    t(ii).x = double(t(ii).x);
    t(ii).y = double(t(ii).y);
end



%% Get CP
topManipMeasure = tMManip([tMManip.label]==0);
ID = [[topManipMeasure.fid];[topManipMeasure.wid]]';
traceID = [[tTManip.time];[tTManip.id]]';
traceIDX = ismember(traceID,ID,'rows');
tManip = tTManip(traceIDX);

for ii = 1:numFrames
    [k,d] = dsearchn([t(ii).x t(ii).y],[tManip(ii).x tManip(ii).y]);
    idx = k(d==min(d));
    CP(ii,:) = [t(ii).x(idx) t(ii).y(idx)];
end

%% View


for ii = 1:2384
    if ~C(ii)
        continue
    end
    plot(t(ii).x,t(ii).y,'.')
    ho
    plot(CP(ii,1),CP(ii,2),'r*')
    axis([0 640 0 480])
    pause(.01)
    cla
end
