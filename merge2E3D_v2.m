% merge to E3D
%% Load in tracked_3D
%% Load in manipulators
tmw = LoadWhiskers('');
fmw = LoadWhiskers('');
tmm = LoadMeasurements('');
fmm = LoadMeasurements('');

%% Smooth the whiskers
smoothed = kalman_whisker(tracked_3D,.1);

%%
useFront = logical(zeros(numFrames,1));
useFront([fmm.label]>=0) = 1;
useTop = logical(zeros(numFrames,1));
useTop([tmm.label]>=0) = 1;

if any(useFront && useTop)
    useTop(useFront && useTop)=0;
end

    
%%
parfor ii = 1:length(smoothed)
    if ~C(ii)
        continue
    end
    if isempty(smoothed(ii).x)
        continue
    end
    if useFront(ii)
        ID = fmm.wid([fmm.label]==0 && [fmm.fid]==ii);
        man = fmw([fmw.time]==ii && [fmm.id]==ID);
        
        [wskrFront,~] = BackProject3D(smoothed(ii),calib{5:8},calib{1:4},calib{9:10});
        dsearchn(wskrFront,
    