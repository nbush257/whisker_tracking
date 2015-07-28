% Use this to preprocess 2D data to E2D

clear;ca;
trackedPaths = 'G:\2015_15\tracked\';% set the path where your whiskers and measurements files are
vidPaths = 'G:\2015_15\avis\';% set the path where your videos are
savePath = 'G:\2015_15\analyzed\';
ii = 36;% 
isRight = 0;% set this to 1 if the face is on the right side. This should only happen in 2015_06
% ======================================================
d = dir([trackedPaths '*_whisker.whiskers']);% find all the whiskers files

% Access the frame numbers in the filename
numIdx = regexp(d(ii).name,'F\d');
startFrame = str2num(d(ii).name(numIdx(1)+1:numIdx(1)+6));
endFrame = str2num(d(ii).name(numIdx(2)+1:numIdx(2)+6));

%extract the tag assuming the file ends '_whisker.whiskers'
TAG = d(ii).name(1:end-17);

% get all the filenames to load in
whiskerName = [trackedPaths TAG '_whisker.whiskers'];
measureName = [trackedPaths TAG '_whisker.measurements'];
videoName = [vidPaths TAG '.avi']
manipTraceName = [trackedPaths TAG '_manip.whiskers'];
manipMeasureName = [trackedPaths TAG '_manip.measurements'];

% Display all the filenames to verify this is the right stuff
disp(whiskerName)
disp(measureName)
disp(videoName)
disp(manipTraceName)
disp(manipMeasureName)

% set the save filename
saveName = [savePath TAG '_E2D.mat'];

%% 
% Load in the data
tV = videoName;
V = VideoReader(tV);
tT = LoadWhiskers(whiskerName);
tM = LoadMeasurements(measureName);
tManip = LoadWhiskers(manipTraceName);
tMManip = LoadMeasurements(manipMeasureName);

numFrames = endFrame - startFrame +1;

% find the traces labelled 0 in the whiskers files
topMeasure = tM([tM.label]==0);
ID = [[topMeasure.fid];[topMeasure.wid]]';
traceID = [[tT.time];[tT.id]]';
traceIDX = ismember(traceID,ID,'rows');
t = tT(traceIDX);

% find the traces labeled 0 in the manipulator files
topManipMeasure = tMManip([tMManip.label]==0);
ID = [[topManipMeasure.fid];[topManipMeasure.wid]]';
traceID = [[tManip.time];[tManip.id]]';
traceIDX = ismember(traceID,ID,'rows');
tManip = tManip(traceIDX);

% flip the basepoint order if the trial is on the right.
if isRight
    for ii = 1:length(t)
        t(ii).x = flipud(t(ii).x);
        t(ii).y = flipud(t(ii).y);
    end
end

%clean up the basepoint
t = trimBP(t,V);
t = trackBP(tV,t);
ca
% Make the struct lengths equal to the number of frames in the video
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

clear tManipTemp
tManipTemp(numFrames) = tManip(end);
tManipTemp([tManip.time]+1) = tManip;
tManip = tManipTemp;
clear tManipTemp

clear tMManipTemp
tMManipTemp(numFrames) = tMManip(end);
tMMManipTemp([tMManip.fid]+1) = tMManip;
tMManip = tMManipTemp;
clear tMTemp

% Clean gaps in the length of the manipulator and whisker
tManip = fill2Dgap(tManip);
t = fill2Dgap(t);

%% Track the tip of the whisker
% was used to find contact, now depricated, but need it for top_tip.time.

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

%% Get Theta for contact
clear TH_linear

for ii = 1:length(t)
    if isempty(t(ii).x)
        continue
    end
    x1 = t(ii).x(1);
    y1 = t(ii).y(1);
    l = length(t(ii).x);
    ye = t(ii).y(ceil(l/5));
    xe = t(ii).x(ceil(l/5));
    TH_linear(ii) = atan2(ye-y1,xe-x1)*180/pi;
end

% wrap theta
TH_linear(TH_linear>nanmean(TH_linear)+180) = TH_linear(TH_linear>nanmean(TH_linear)+180)-360;
TH_linear(TH_linear<nanmean(TH_linear)-180) = TH_linear(TH_linear<nanmean(TH_linear)-180)+360;
TH_linear = double(TH_linear);

% remove large errors
rm = abs(diff(TH_linear))>std(diff(TH_linear));
TH_linear(rm) = NaN;

first = find(~isnan(TH_linear));
first = first(1);
for ii = first:length(TH_linear)
    if isnan(TH_linear(ii))
        next = find(~isnan(TH_linear(ii:end)));
        next  = next(1)+ii-1;
        TH_linear(ii:next-1) = interp1([ii-1 next],[TH_linear(ii-1) TH_linear(next)],ii:next-1);
    end
end
topCind = TH_linear;
figure
topCind = tsmovavg(topCind,'s',10);
% find the peaks an troughs for contact
plot(topCind)
baselinetop = ginput(1);
baselinetop = baselinetop(2);
topCind_rect = abs(topCind - baselinetop);

[~,locs,w] = findpeaks(topCind_rect,'MinPeakProminence',1);
plot(topCind);
hold on
scatter(locs,topCind(locs));
topA = round(locs-w);
topA(topA<1)=1;
topB = round(locs+w);
topB(topB>20000) = 20000;
scatter(topA,topCind(topA));
scatter(topB,topCind(topB));

topFrames= [top_tip.time];
topContactStarts = topFrames(round(topA));
topContactEnds = topFrames(round(topB));
legend({'topCind','Peak','Start','End'})
 %% Manual get contact
% %Use this if it is easier to spot contact manually (usually larger contact
% % bouts
% title('Click on the left and right of each contact period')
% plot(topCind)
% ui = ginput;
% topA_man = ui(1:2:end,1);
% topB_man = ui(2:2:end,1);
% topA_man(topA_man<1)=1;
% topB_man(topB_man>numFrames)=numFrames;
% topFrames= [top_tip.time];
% topA_man = topFrames(round(topA_man));
% topB_man = topFrames(round(topB_man));
%
% topContactStarts = [];
% topContactEnds = [];
% topContactStarts(topContactEnds>topA_man(1) & topContactStarts<topB_man(end)) = [];
% topContactStarts = [topContactStarts topA_man];sort(topContactStarts);
% topContactEnds(topContactEnds>topA_man(1) & topContactEnds<topB_man(end)) = [];
% topContactEnds = [topContactEnds topB_man];sort(topContactEnds);
% fig
% plot(topCind)
% ho
%
% scatter(topContactStarts,topCind(topContactStarts));
% scatter(topContactEnds,topCind(topContactEnds));



%% get the C variable from the Theta peaks
C = logical(zeros(numFrames,1));
mergeFlags = logical(zeros(numFrames,1));
for ii = 1:length(topContactStarts)
    idx = topContactStarts(ii):topContactEnds(ii);
    idx(idx<1)=1;
    C(idx) = 1;
end

% manually edit the contact periods
close all
figure
plot(scale(topCind))
title('Left clicks add contact, Right clicks delete contact')
ho
plot(C)
axy(0,1.1)
ii=1;
while ii<numFrames
    axx(ii,ii+2000)
    x = [NaN];
    while ~isempty(x)
        [x,~,button] = ginput(2);% 1 is left click, 3 is right click
        x = round(x);
        if length(x)==1
            x = [x x];
        end
        x(x<1)=1;
        if button == 3
            C(x(1):x(2)) = 0;
        elseif button == 1
            C(x(1):x(2)) = 1;
        end
    end
    
    ii=ii+2000;
end

% verify the contact periods
close all
figure
plot(scale(topCind))
title('Verify Contact')
ho
plot(C)
pause
%% cast to doubles
for ii = 1:numFrames
    t(ii).x = double(t(ii).x);
    t(ii).y = double(t(ii).y);
end



%% Get CP
markNext = 0;
CP = nan(numFrames,2);
last_ii = 0;
ca
count = 0;
last_ii=1;

for ii = 1:numFrames
    % skip if there is no contact or no whisker or short whisker.
    if ~C(ii)
        continue
    end
    if isempty(t(ii).x)
        continue
    end
    if length(t(ii).x)<5
        C(ii)=0;
        continue
    end
    
    % if the manipulator is not tracked in this frame then manually find
    % the CP
    if isempty(tManip(ii).x) & C(ii)
        clf
        % read the images
        I = read(V,ii);
        lastI = read(V,last_ii);
        
        % plot the images
        subplot(121)
        imshow(lastI)
        ho;
        plot(CP(last_ii,1),CP(last_ii,2),'g*')
        
        subplot(122)
        imshow(I)
        ho;
        
        plot(t(ii).x,t(ii).y,'.')
        plot(tManip(ii).x,tManip(ii).y,'r.')
        title(num2str(ii))
        in = ginput(1);
        if isempty(in)
            C(ii)=0;
            continue
        end
        % find the closest point on the whisker to the clicked point
        [~,choiceDis] = dsearchn(in,[t(ii).x t(ii).y]);
        [~,idx] = min(choiceDis);
        
        CP(ii,:) = [t(ii).x(idx) t(ii).y(idx)];
        last_ii = ii;
        continue
    end
    
    % Find the closest point between manipulator and whisker
    [k,d] = dsearchn([t(ii).x t(ii).y],[tManip(ii).x tManip(ii).y]);
    idx = k(d==min(d));
    
    % If the manipulator is more than 5 pix away from the whisker, deemed
    % no contact
    if min(d)>5
        C(ii) = 0;
        continue
    end
    
    %If there are more than 1 point equidistant to the manipulator,
    % determine it manually
    if length(idx)>1
        if ~isempty(k(d<2))
        idx = k(d<2);% find all points on the whisker within 2 pixels of the manipulator
        end% plot images and tracked entities
        I = read(V,ii);
        lastI = read(V,last_ii);
        clf
        subplot(121)
        imshow(lastI)
        ho
        plot(CP(last_ii,1),CP(last_ii,2),'g*')
        subplot(122)
        imshow(I)
        ho
        plot(t(ii).x,t(ii).y,'.')
        plot(tManip(ii).x,tManip(ii).y,'r.')
        title(num2str(ii))
        
        % Click on a point close to the intersection
        in = ginput(1);
        if isempty(in)
            C(ii)=0;
            continue
        end
        % Determine which of the whisker points within two pixels is
        % closest to the clicked point
        in = repmat(in,length(idx),1);
        [~,choiceDis] = dsearchn(in,[t(ii).x(idx) t(ii).y(idx)]);
        [~,choiceIdx] = min(choiceDis);
        idx = idx(choiceIdx);
        
        last_ii = ii;
        
    end
    % Set the contact point equal to the point on the whisker that has been
    % chosen
    CP(ii,:) = [t(ii).x(idx) t(ii).y(idx)];

end
ca
%
%% View to verify good tracking/right video etc...
count = 0;
for ii = 1:numFrames
    if ~C(ii)
        continue
    end
    
    count = count +1;
    if count>200
        break
    end
    I = read(V,ii);
    cla
    imshow(I)
    ho
    plot(t(ii).x,t(ii).y,'.')
    plot(CP(ii,1),CP(ii,2),'r*')
    axis([0 640 0 480])
    pause(.01)
    
end
ca

if length(C)>numFrames
    error('C is the wrong size.')
end
%% Fix CP Errors

    rm  = zeros(size(CP,1),1);
    CP_rm = CP;
    rm = abs(diff(CP(:,1)))>nanstd(abs(diff(CP(:,1))))*3;
    rm = [0;rm]; starts = find(diff(rm)==1)+1; stops = find(diff(rm)==-1)+1;
    rm = find(rm);
    CP_rm(rm,:) = NaN;
    for jj = 1:length(starts)
        CP_rm(starts(jj):stops(jj)-1,1) = interp1([starts(jj)-1 stops(jj)],[CP(starts(jj)-1,1) CP(stops(jj),1)],starts(jj):stops(jj)-1);
        CP_rm(starts(jj):stops(jj)-1,2) = interp1([starts(jj)-1 stops(jj)],[CP(starts(jj)-1,2) CP(stops(jj),2)],starts(jj):stops(jj)-1);
    end    
    CP = CP_rm;
    
%% Sort whisker
for ii= 1:numFrames
    if isempty(t(ii).x)
        continue
    end
    [val,i] = sort(t(ii).x)
    t(ii).x = t(ii).x(i);
    t(ii).y = t(ii).y(i);
end

%% get reference whisker and save.
xw3d = {t.x};
yw3d = {t.y};

refExist=0;
while refExist == 0
    fprintf('%s\n',videoName)
    RefWhisker = input('what is the frame of the reference whisker?');
    if RefWhisker==0;RefWhisker = 1;end% Catch if I say 0 instead of 1
    REF = ones(length(xw3d),1)*RefWhisker;
    if ~isempty(xw3d{RefWhisker})
        refExist = 1;
    end
end



disp('saving')
save(saveName,'xw3d','yw3d','C','CP','REF')
disp('Saving Done')
