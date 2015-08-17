% merge to E3D
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
useFront = logical(zeros(numFrames,1));
fFrames = [fmm.fid];
fFrames([fmm.label]~=0)=[];
useFront(fFrames) = 1;


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
for ii = 1:numFrames
    %     if ~C(ii)
    %         continue
    %     end
    if isempty(smoothed(ii).x)
        continue
    end
    if useFront(ii)
        ID = fmm([fmm.label]==0 & [fmm.fid]==ii).wid;
        man = fmw([fmw.time]==ii & [fmw.id]==ID);
        mx = man.x;
        my = man.y;
        if range(mx)>3
            p = polyfit(mx,my,1);
            px = [0:.3:640];
            py = polyval(p,px);
            rm = py>640 | py<1;
            py(rm) = [];
            px(rm) = [];
        else
            p = polyfit(my,mx,1);
            py = [0:.3:640];
            px = polyval(p,px);
            rm = py>640 | py<1;
            py(rm) = [];
            px(rm) = [];
        end
        [wskrFront,~] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
        [~,d] = dsearchn([px' py'],wskrFront);
        CPidx = find(d==min(d));
        
        
    elseif useTop(ii)
        ID = tmm.wid([tmm.label]==0 && [tmm.fid]==ii);
        man = tmw([tmw.time]==ii && [tmm.id]==ID);
        mx = man.x;
        my = man.y;
        if range(mx)>3
            p = polyfit(mx,my,1);
            px = [0:.3:640];
            py = polyval(p,px);
            rm = py>480 | py<1;
            py(rm) = [];
            px(rm) = [];
        else
            p = polyfit(my,mx,1);
            py = [0:.3:640];
            px = polyval(p,px);
            rm = py>480 | py<1;
            py(rm) = [];
            px(rm) = [];
        end
        [~,wskrTop] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
        [~,d] = dsearchn([px' py'],wskrTop);
        CPidx = find(min(d));
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
            plot(wskrFront(CPidx,1),wskrFront(CPidx,2),'r*')
        elseif useTop(ii)
            plot(wskrTop(:,1),wskrTop(:,2),'o')
            plot(wskrTop(CPidx,1),wskrTop(CPidx,2),'r*')
            
        end
        drawnow
        
    end
end