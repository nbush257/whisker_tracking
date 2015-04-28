tT = LoadWhiskers('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_noClass.whiskers');
tM = LoadMeasurements('D:\data\2015_08\analyzed\C1_top\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_whisker.measurements');
fT = LoadWhiskers('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_noClass.whiskers');
fM = LoadMeasurements('D:\data\2015_08\analyzed\C1_front\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_whiskers.measurements');
fV = 'D:\data\2015_08\avis\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000.avi';
tV = 'D:\data\2015_08\avis\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000.avi';
stereo_c = 'D:\data\2015_08\analyzed\rat2015_08_APR09_VG_C1_t01_stereo_calib.mat';
tracked_3D_fileName = 'D:\data\2015_08\analyzed\rat2015_08_APR09_VG_C1_t01_F000001F020001_tracked_3D.mat';
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
frontCind = sqrt([frontMeasure.tip_x].^2 + [frontMeasure.tip_y].^2);
frontCind = tsmovavg(frontCind,'s',10);
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
topCind = sqrt([topMeasure.tip_x].^2 + [topMeasure.tip_y].^2);
topCind = tsmovavg(topCind,'s',10);
plot([topMeasure.fid],topCind)
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


frontFrames= [frontMeasure.fid];
frontContactStarts = frontFrames(frontA);
frontContactEnds = frontFrames(frontB);

topFrames= [topMeasure.fid];
topContactStarts = topFrames(topA);
topContactEnds = topFrames(topB);

C = logical(zeros(numFrames,1));
for ii = 1:length(topContactStarts)
    idx = topContactStarts(ii)+1:topContactEnds(ii)+1;
    C(idx) = 1;
end


for ii = 1:length(frontContactStarts)
    idx = frontContactStarts(ii)+1:frontContactEnds(ii)+1;
    C(idx) = 1;
end
figure
plot(topFrames,topCind)
title('Verify that contact is good')
hold on
plot(frontFrames,frontCind);
plot(C*500)


%% load calibration
load(stereo_c)
calib_stuffz;

frontCam = calib{1:4};
topCam = calib{5:8};
A2Btransform = calib{9:10};

%% merge


% 3D Merge Whisker % Might want to try to make the seed whisker variable.
minDS = .7;% sets the minimum internode distance.
minWhiskerSize = 20; % in # of nodes
N = 20; % I think this is the number of fits to try. More should give a stabler fit.

%Maybe only look at +- 100 around contact.

tracked_3D = struct([]);

tic;
step = 1000;% Saves every 1000 frames
% Outer loop is big serial chunks that saves every [step] frames
for ii = 1:step:length(front)
    
    % Makes sure we don't try to access a frame past the last frame.
    if (ii+step-1)>length(f)
        iter = length(f)-ii;
    else
        iter = step-1;
    end
    % Parallel for loop which does the actual merging. Gets batches from
    % the current outer loop.
    parfor i = ii:ii+iter
        prevWhiskerSize = 0;
        close all
        merge_x = [];merge_y = [];merge_z = [];
        DS = minDS;
        [merge_x,merge_y,merge_z]= Merge3D_JAEv1(f(i).x,f(i).y,t(i).x,t(i).y,i,calib,'wm_opts',{'DS',DS,'N',N});
        
        % The while loop steps DS down until whisker stops increasing by 5 nodes in
        % node size
        while length(merge_x)>prevWhiskerSize+5
            prevWhiskerSize = length(merge_x);
            DS = DS-.1;
            [merge_x,merge_y,merge_z]= Merge3D_JAEv1(f(i).x,f(i).y,t(i).x,t(i).y,i,calib,'wm_opts',{'DS',DS,'N',N});
            if DS<.1
                break
            end
        end% end while
        % Save into workspace
        tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
        tracked_3D(i).time = f(i).time;
    end
    save(tracked_3d_flieName,'tracked_3D')
end
timer = toc;
fprintf('It took %.1f seconds to merge %i frames \n',timer,length(tracked_3D));


