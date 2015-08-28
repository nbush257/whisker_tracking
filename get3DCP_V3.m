function CP = get3DCP_V3(smoothed,fW,tW,C,useFront,useTop,calib)
plotTGL = 0;

CP = nan(length(smoothed),3);
CPidx = nan(length(smoothed),1);

% h = waitbar(0,'Finding CP')
fprintf('Finding CP...')
warning('off','all')
misLength = CPidx;
n = CPidx;
noFrontOrTop =CPidx;
parfor ii = 1:length(smoothed)
    warning('off','all')
    if ~C(ii)
        continue
    end
    if isempty(smoothed(ii).x) | length(smoothed(ii).x)<2
        continue
    end
    %        waitbar(ii/numFrames,h)
    
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
            misLength(ii) = 1;
            continue
        end
        [CPx,CPy,tempCPidx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px',py');
        if isempty(tempCPidx)
            xyfit = polyfit(smoothed(ii).x,smoothed(ii).y,3);
            xzfit = polyfit(smoothed(ii).x,smoothed(ii).z,3);
            [CPx,CPy,tempCPidx,smoothed(ii)] = LOCAL_extend_one_Seg(smoothed(ii),xyfit,xzfit,px,py,calib(5:8),calib(1:4),calib(9:10),1);
            
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
        
        if length(px)~=length(py) | length(px)<2
            misLength(ii) = 1;
            continue
        end
        [CPx,CPy,tempCPidx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px',py');
        
        if isempty(tempCPidx)
            
            xyfit = polyfit(smoothed(ii).x,smoothed(ii).y,3);
            xzfit = polyfit(smoothed(ii).x,smoothed(ii).z,3);
            [CPx,CPy,tempCPidx,smoothed(ii)] = LOCAL_extend_one_Seg(smoothed(ii),xyfit,xzfit,whfitA,whfitB,px,py,calib(5:8),calib(1:4),calib(9:10),0);
            
        end
        
    else
        fprintf('Contact occurred but no manipulator specified at frame %d\n',ii)
        noFrontOrTop(ii)=1;
        
    end
    if plotTGL
        clf
        if useFront(ii) | useTop(ii)
            plot(mx,my,'g.')
            ho
            plot(px,py,'go');
        end
        if useFront(ii)
            [wskrFront,~] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
            
            plot(wskrFront(:,1),wskrFront(:,2),'o')
            plot(CPx,CPy,'r*')
        elseif useTop(ii)
            [~,wskrTop] = BackProject3D(smoothed(ii),calib(5:8),calib(1:4),calib(9:10));
            
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
end


function [CPx,CPy,tempCPidx,wskr3D] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,px,py,A_camera,B_camera,A2B_transform,useFront)
if useFront
    [wskr,~] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
else
    [~,wskr] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
end

[CPx,CPy,tempCPidx,~] = intersections(wskr(:,1),wskr(:,2),px,py);

if tempCPidx+10<length(wskr(:,1))
    return
    
else
    nodespacing = median(diff(wskr3D.x));
    if size (wskr3D.x,1) == 1
        wskr3D.x = [wskr3D.x,wskr3D.x(end)+nodespacing];
        wskr3D.y = [wskr3D.y,polyval(whfitA,wskr3D.x(end))];
        wskr3D.z = [wskr3D.z,polyval(whfitB,wskr3D.x(end))];
    else
        wskr3D.x = [wskr3D.x;wskr3D.x(end)+nodespacing];
        wskr3D.y = [wskr3D.y;polyval(whfitA,wskr3D.x(end))];
        wskr3D.z = [wskr3D.z;polyval(whfitB,wskr3D.x(end))];
    end
    [CPx,CPy,tempCPidx,wskr3D] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,px,py,A_camera,B_camera,A2B_transform,useFront);
    
end


end % function LOCAL_extend_one_Seg


