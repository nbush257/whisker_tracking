% merge to E3D
clear fM tM
gcp;
outName = 'rat2015_15_JUN11_VG_C2_t01_toE3D_2.mat';
plotTGL = 0;
plotTGL_sanity = 0;
fprintf('Loading data...\n')
%% Load in tracked_3D
%load('rat2015_15_JUN11_VG_B2_t01_Calib_stereo.mat')
load('rat2015_15_JUN11_VG_C2_t01_tracked3D_iter_22.mat')
load('rat2015_15_JUN11_VG_C2_t01_toMerge.mat','C','calib')

%% Load in manipulators
tmw = LoadWhiskers('G:\raw\2015_15\rat2015_15_JUN11_VG_C2_t01_Top_manip.whiskers');
fmw = LoadWhiskers('G:\raw\2015_15\rat2015_15_JUN11_VG_C2_t01_Front_manip.whiskers');
tmm = LoadMeasurements('G:\raw\2015_15\rat2015_15_JUN11_VG_C2_t01_Top_manip.measurements');
fmm = LoadMeasurements('G:\raw\2015_15\rat2015_15_JUN11_VG_C2_t01_Front_manip.measurements');

%% Smooth the whiskers
fprintf('Smoothing Whisker...\n')
smoothed = kalman_whisker(tracked_3D,.005);

%%

numFrames = max([fmm.fid]);
fM(numFrames) = fmm(end);
tM(numFrames) = tmm(end);

keepF = fmm([fmm.label]==0);
ID = [[keepF.fid];[keepF.wid]]';
traceID = [[fmw.time];[fmw.id]]';
traceIDX = ismember(traceID,ID,'rows');
fW = fmw(traceIDX);
clear tempfW
tempfW(numFrames) = fW(end);
tempfW([fW.time]+1) = fW;
fW = tempfW;
clear tempfW;


keepT = tmm([tmm.label]==0);
ID = [[keepT.fid];[keepT.wid]]';
traceID = [[tmw.time];[tmw.id]]';
traceIDX = ismember(traceID,ID,'rows');
tW = tmw(traceIDX);

clear temptW;
temptW(numFrames) = tW(end);
temptW([tW.time]+1) = tW;
tW = temptW;
clear temptW


useFront = logical(zeros(numFrames,1));
fFrames = [fmm.fid];
fFrames([fmm.label]~=0)=[];
useFront(fFrames) = 1;
fM([fmm.fid]+1) = fmm;
tM([tmm.fid]+1) = tmm;



useTop = logical(zeros(numFrames,1));
tFrames = [tmm.fid];
tFrames([tmm.label]~=0)=[];
useTop(tFrames) = 1;


if any(useFront & useTop)
    useFront(useFront & useTop)=0;
end

noMan = ~useFront & ~useTop;
C(noMan)=0;
%% interpolate

for ii = 1:length(smoothed)
    if ~C(ii)
        continue
    end
    if length(smoothed(ii).x)<10
        smoothed(ii).x = [];
        smoothed(ii).y = [];
        smoothed(ii).z = [];
    elseif nn(smoothed(ii).x)==0
        smoothed(ii) = interp_3D_wstruct(smoothed(ii));
    end
end

%% 
CP = get3DCP_V3(smoothed,fW,tW,C,useFront,useTop,calib);

%%
xw3d = {smoothed.x};
yw3d = {smoothed.y};
zw3d = {smoothed.z};
C = logical(C);
REF = [];
while isempty(REF)
    R = input('Which Frame to use as reference?');
    if length(xw3d{R})>2
        REF = ones(size(C))*R;
    end
end

if plotTGL_sanity
    s = randsample(find(C),500);
    fig
    ho
    
    for ii = 1:length(s)
        plot3(smoothed(s(ii)).x,smoothed(s(ii)).y,smoothed(s(ii)).z,'b.');
        plot3(CP(s(ii),1),CP(s(ii),2),CP(s(ii),3),'r*')
    end
end

newC = C;
for ii = 1:length(C)
    if C(ii)
        if any(isnan(xw3d{ii}))
            newC(ii) = 0;
        end
        if length(xw3d{ii})<21
            newC(ii) = 0;
        end
        if any(isnan(CP(ii,:)))
            newC(ii) = 0;
        end
    end
end
lostContacts = sum(C~=newC)
pause
% save(outName,'xw3d','yw3d','zw3d','C','CP','REF');


