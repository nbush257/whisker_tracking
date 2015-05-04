tT = LoadWhiskers('L:\working\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_noClass.whiskers');
tM = LoadMeasurements('L:\working\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_whisker.measurements');
fT = LoadWhiskers('L:\working\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_noClass.whiskers');
fM = LoadMeasurements('L:\working\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_whiskers.measurements');
fV = 'L:\working\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000.avi';
tV = 'L:\working\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000.avi';
stereo_c = 'L:\working\rat2015_08_APR09_VG_C1_t01_stereo_calib.mat';
tracked_3D_fileName = 'C:\Users\guru\Documents\hartmann_lab\data\2015_08\rat2015_08_APR09_VG_C1_t01\rat2015_08_APR09_VG_C1_t01_F000001F020000_tracked_3D.mat';
tTManip = LoadWhiskers('L:\working\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_noClass.whiskers');
tMManip = LoadMeasurements('L:\working\rat2015_08_APR09_VG_C1_t01_Top_F000001F020000_manip.measurements');
fTManip = LoadWhiskers('L:\working\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_manip.whiskers');
fMManip = LoadMeasurements('L:\working\rat2015_08_APR09_VG_C1_t01_Front_F000001F020000_manip.measurements');


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

f([f.time]+1) = f;
t([t.time]+1) = t;
if length(f)~= numFrames | length(t)~= numFrames
    error('the number of frames in the front tracking or top tracking are not equal to the total number of frames.')
end
frontMeasure([frontMeasure.fid]+1) = frontMeasure;
topMeasure([topMeasure.fid]+1) = topMeasure;

%% Get Contact Still should edit this to check within windows as regards to findin peaks pos or neg.
% front
figure
frontFrames = [frontMeasure.fid];
[sortedFrontFrame,sortFront] = sort(frontFrames);

frontCind = sqrt([frontMeasure.tip_x].^2 + [frontMeasure.tip_y].^2);
frontCind(sortFront) = frontCind;
frontCind = tsmovavg(frontCind,'s',10);
%frontCind = bwfilt(frontCind,300,1,150);
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
frontA(frontA<1)=1;
frontB(frontB<1)=1;
frontA(frontA>length(f))=length(f);
frontB(frontB>length(f))=length(f);

scatter(frontA,frontCind(frontA));
scatter(frontB,frontCind(frontB));

% top
figure
topFrames = [topMeasure.fid];
[sortedTopFrames,sortTop] = sort(topFrames);

topCind = sqrt([topMeasure.tip_x].^2 + [topMeasure.tip_y].^2);
topCind(sortTop) = topCind;
topCind = tsmovavg(topCind,'s',10);
topCind(isnan(topCind)) =  0;
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
for ii = 1:step:numFrames
    % Makes sure we don't try to access a frame past the last frame.
    if (ii+step-1)>length(f)
        iter = length(f)-ii;
    else
        iter = step-1;
    end
    
    
    % Parallel for loop which does the actual merging. Gets batches from
    % the current outer loop.
    parfor i = ii:ii+iter
        merge_x = [];merge_y = [];merge_z = [];last_merge_x = []; last_merge_y = []; last_merge_z = [];
        if ~mergeFlags(i)
            tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
            tracked_3D(i).time = i;
            continue
        end

        if isempty(t(ii)) | isempty(f(ii))
            tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
            tracked_3D(i).time = i;
            continue
        end
        if isempty(t(ii).x) | isempty(currentFront.x)
            tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
            tracked_3D(i).time = i;
            continue
        end
        prevWhiskerSize = 0;
        close all
        
        DS = minDS;
        %         if ~mergeFlags(i)% skips merging if not within several frames of contact
        %
        %             tracked_3D(i).x = merge_x; tracked_3D(i).y = merge_y; tracked_3D(i).z = merge_z;
        %             tracked_3D(i).time = f(i).time;
        %             continue
        %         end
        
        [merge_x,merge_y,merge_z]= Merge3D_JAEv1(currentFront.x,currentFront.y,currentTop.x,currentTop.y,i,calib,'wm_opts',{'DS',DS,'N',N});
        
        % The while loop steps DS down until whisker stops increasing by 5 nodes in
        % node size
        while length(merge_x)>prevWhiskerSize+5
            prevWhiskerSize = length(merge_x);
            last_merge_x = merge_x;
            last_merge_y = merge_y;
            last_merge_z = merge_z;
            
            DS = DS-.1;
            [merge_x,merge_y,merge_z]= Merge3D_JAEv1(currentFront.x,currentFront.y,currentTop.x,currentTop.y,i,calib,'wm_opts',{'DS',DS,'N',N});
            if DS<.1
                break
            end
        end% end while
        % Save into workspace
        tracked_3D(i).x = last_merge_x; tracked_3D(i).y = last_merge_y; tracked_3D(i).z = last_merge_z;
        tracked_3D(i).time = currentFront.time;tracked_3D(i).frontTime = currentFront.time;tracked_3D(i).topTime = currentTop.time;
    end
    save([tracked_3D_fileName(1:end-4) '_iter_' num2str(ii) ],'tracked_3D')
end
timer = toc;
fprintf('It took %.1f seconds to merge %i frames \n',timer,length(tracked_3D));

%% Get 3D CP
get3dCP_v2;



