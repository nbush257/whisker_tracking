% merge to E3D
clear fM tM
plotTGL = 0;
%% Load in tracked_3D
%% Load in manipulators
tmw = LoadWhiskers('rat2015_15_JUN11_VG_B1_t01_Top.whiskers');
fmw = LoadWhiskers('rat2015_15_JUN11_VG_B1_t01_Front.whiskers');
tmm = LoadMeasurements('rat2015_15_JUN11_VG_B1_t01_Top.measurements');
fmm = LoadMeasurements('rat2015_15_JUN11_VG_B1_t01_Front.measurements');

%% Smooth the whiskers
% smoothed = kalman_whisker(tracked_3D,.1);

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
% C(noMan)=0;
%%
CP = nan(numFrames,2);
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
        [CPx,CPy,tempCPidx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px',py');
        if ~isempty(CPx)
%             CP(ii,:) = [CPx CPy];
            CPidx(ii) = round(tempCPidx);
        end
        
        
        
        
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
        [CPx,CPy,tempCPidx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px',py');
        if ~isempty(CPx)
%             
%             CP(ii,:) = [CPx CPy];
            CPidx(ii) = round(tempCPidx);
        end
        
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
end