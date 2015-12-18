% merge to E3D
clear fM tM
gcp;
outName = 'rat2015_15_JUN11_VG_D4_t01_toE3D_2.mat';
plotTGL = 0;
plotTGL_sanity = 0;
fprintf('Loading data...\n')
%% Load in tracked_3D
% load('rat2015_15_JUN11_VG__t01_Calib_stereo.mat')
load('rat2015_15_JUN11_VG_D4_t01_tracked_3D_iter_20.mat')
load('rat2015_15_JUN11_VG_D4_t01_toMerge.mat','C','calib')

%% Load in manipulators
tmw = LoadWhiskers('F:\raw\2015_15\rat2015_15_JUN11_VG_D4_t01_Top_manip.whiskers');
fmw = LoadWhiskers('F:\raw\2015_15\rat2015_15_JUN11_VG_D4_t01_Front_manip.whiskers');
tmm = LoadMeasurements('F:\raw\2015_15\rat2015_15_JUN11_VG_D4_t01_Top_manip.measurements');
fmm = LoadMeasurements('F:\raw\2015_15\rat2015_15_JUN11_VG_D4_t01_Front_manip.measurements');

%% Smooth the whiskers
[~,tracked3D] = clean3D_BP(tracked_3D);
smoothed = tracked_3D;
%% getting 2D whiskers and manipulators? Why don't we just load these in from the data sent to the merge?

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
%% 
figure
CP = get3DCP_V3(smoothed,fW,tW,C,useFront,useTop,calib);
plot(CP,':');hold on
CP = cleanCP(CP);
plot(CP);
drawnow;pause
%% interpolate

for ii = 1:length(smoothed)
    if ~C(ii)
        continue
    end
    if length(smoothed(ii).x)<10
        smoothed(ii).x = [];
        smoothed(ii).y = [];
        smoothed(ii).z = [];
        C(ii) = 1;
    elseif nn(smoothed(ii).x)==0
        smoothed(ii) = interp_3D_wstruct(smoothed(ii));
    end
end



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
        plot3(smoothed(s(ii)).x,smoothed(s(ii)).y,smoothed(s(ii)).z,'b:');
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
% 
% fprintf('Smoothing Whisker...\n')
% smoothed = kalman_whisker(tracked_3D,.005);
 save(outName,'xw3d','yw3d','zw3d','C','CP','REF');


