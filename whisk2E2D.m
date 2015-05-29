% Use this to preprocess 2D data to E2D

whiskerName = '';
measureName = '';
videoName = '';
saveName = '';
isRight = 0;
%%
tT = LoadWhiskers(whiskerName);
tM = LoadMeasurements(measureName);
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

t = trackBP(t,tV);

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
frontA(frontA<1)=1;

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

plot(C*500)
plot(mergeFlags*600)
pause

%% Set merge flags to zero if both views don't have a whisker
for ii = 1:numFrames
    if isempty(t(ii))
        mergeFlags(ii) = 0;
        continue
    end
    if isempty(t(ii).x)
        mergeFlags(ii)=0;
    end
end

fprintf('\nSaving to HDD')
for ii = 1:numFrames
    t(ii).x = double(t(ii).x);
    t(ii).y = double(t(ii).y);
end
%% Save to HDD
save(saveName)
fprintf('\nAll Done! Your data are ready to merge!\n') 
