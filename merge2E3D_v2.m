% merge to E3D
clear fM tM
gcp;
outName = 'rat2015_15_JUN11_VG_D1_t01_toE3D.mat';
plotTGL = 0;
plotTGL_sanity = 0;
fprintf('Loading data...\n')
%% Load in tracked_3D
%load('rat2015_15_JUN11_VG_B2_t01_Calib_stereo.mat')
load('rat2015_15_JUN11_VG_D1_t01_tracked3D_iter_21.mat')
load('rat2015_15_JUN11_VG_D1_t01_toMerge.mat','C','calib')

%% Load in manipulators
tmw = LoadWhiskers('F:\raw\2015_15\rat2015_15_JUN11_VG_D1_t01_Top_manip.whiskers');
fmw = LoadWhiskers('F:\raw\2015_15\rat2015_15_JUN11_VG_D1_t01_Front_manip.whiskers');
tmm = LoadMeasurements('F:\raw\2015_15\rat2015_15_JUN11_VG_D1_t01_Top_manip.measurements');
fmm = LoadMeasurements('F:\raw\2015_15\rat2015_15_JUN11_VG_D1_t01_Front_manip.measurements');

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
CP = nan(numFrames,3);
CPidx = nan(numFrames,1);

h = waitbar(0,'Finding CP')
for ii = 1:numFrames
   waitbar(ii/numFrames,h)
    %     if ~C(ii)
    %         continue
    %     end

    if isempty(smoothed(ii).x) | length(smoothed(ii).x)<2
        continue
    end
    if useFront(ii)
        man = fW(ii);
        mx = man.x;
        my = man.y;
        if range(mx)>3
            p = polyfit(mx,my,1);
            px = [0:1:640];
            py = polyval(p,px);
            rm = py>640 | py<1;
            py(rm) = [];
            px(rm) = [];
        else
            p = polyfit(my,mx,1);
            py = [0:1:640];
            px = polyval(p,py);
            rm = px>640 | px<1;
            py(rm) = [];
            px(rm) = [];
        end
        [wskrFront,~] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
        if length(px)~=length(py) | length(px)<2
            ii
            continue
        end
        [CPx,CPy,tempCPidx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px',py');
       
    elseif useTop(ii)
        man = tW(ii);
        mx = man.x;
        my = man.y;
        if range(mx)>3
            p = polyfit(mx,my,1);
            px = [0:1:640];
            py = polyval(p,px);
            rm = py>640 | py<1;
            py(rm) = [];
            px(rm) = [];
        else
            p = polyfit(my,mx,1);
            py = [0:1:640];
            px = polyval(p,py);
            rm = px>640 | px<1;
            py(rm) = [];
            px(rm) = [];
        end
        [~,wskrTop] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
        
        if length(px)~=length(py) | length(px)<2
            ii
            continue
        end
        [CPx,CPy,tempCPidx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px',py');
       
        
    end
    if plotTGL
        clf
        if useFront(ii) | useTop(ii)
            plot(mx,my,'g.')
            ho
            plot(px,py,'go');
        end
        if useFront(ii)
            plot(wskrFront(:,1),wskrFront(:,2),'o')
            plot(CPx,CPy,'r*')
        elseif useTop(ii)
            plot(wskrTop(:,1),wskrTop(:,2),'o')
            plot(CPx,CPy,'r*')
            
        end
        drawnow
        
    end
    if ~isempty(tempCPidx)
        
        if length(tempCPidx)>1
            tempCPidx = tempCPidx(1);
        end
        if round(tempCPidx)>length(smoothed(ii).x)
            tempCPidx = tempCidx-1;
        end
        
        CP(ii,:) = [smoothed(ii).x(round(tempCPidx)) smoothed(ii).y(round(tempCPidx)) smoothed(ii).z(round(tempCPidx))];
    end
end
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
save(outName,'xw3d','yw3d','zw3d','C','CP','REF');


