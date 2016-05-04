function [CP,CPidx,tracked3D,C] = get3DCP_hough(Y0_f,Y1_f,Y0_t,Y1_t,tracked3D,calibInfo,C)
%% function CP = get3DCP_hough(Y0,Y1,tracked3D,calibInfo)
% Calculates the 3D contact point by backprojecting the tracked 3D whisker
% into 2D and finding the intersection. Will change C from 1 to 0 if no
% manipulator is tracked when contact is indicated
% ========================================================================
% INPUTS:
%           Y0_f = front Y0 from python hough code
%           Y1_f = front Y1 from python hough code
%           Y0_t = top Y0 from python hough code
%           Y0_t = top Y1 from python hough code
%           tracked3D = structure of 3D whisker points as found by the 3D merge
%           calibInfo = 10 element cell array that is the result of stereo
%                  calibration followed by 'calib_stuffz'
%           C = contact binary
% OUTPUTS:
%           CP = [numFrames x 3] matrix of the contact point in tracked 3D
%           space. Units are in the same units as tracked3D(should be mm)
% =========================================================================
%%
% Initialize variables
CP = nan(length(tracked3D),3);
CPidx = nan(length(tracked3D),1);
l_thresh = 10; % fewest number of points allowed in the whisker for CP calculation

parfor ii = 1:length(tracked3D) % loop over every frame
    % Prevent intersections from being annoying
    warning('off')
    
    % skip frames with no contact, no whisker, short whiskers, or whiskers
    % with nans
    if ~C(ii)
        continue
    end
    if isempty(tracked3D(ii).x) || length(tracked3D(ii).x)<l_thresh
        continue
    end
    
    if any(isnan(tracked3D(ii).x)) || any(isnan(tracked3D(ii).y))|| any(isnan(tracked3D(ii).z))
        fprintf('NaNs in frame %i',ii)
        continue
    end
    
    % backproject the 3D whisker into the appropriate view based on which
    % view the manipulator was tracked in and finds where the whisker intersects the manipulator. 
    % If both views have a tracked manipulator, defaults to top, as that is generally better tracked.
   
    if ~isnan(Y0_t(ii))
        px = [0;640];
        py = [Y0_t(ii);Y1_t(ii)];
        [~,wskrTop] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [~,~,idx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px,py);
        idx(isnan(idx)) = [];
    elseif ~isnan(Y0_f(ii))
        px = [0;640];
        py = [Y0_f(ii);Y1_f(ii)];
        [wskrFront,~] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [~,~,idx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px,py);
        idx(isnan(idx)) = [];
    else
        C(ii) = 0; % call contact 0 if no manipulator is tracked here.
        continue
    end
    
    
    %% Extend whisker if needed 
    % Run this section if contact was indicated and a manipulator was tracked, but the whisker and manipulator do not intersect
    
    if isempty(idx) || (idx(1)+length(tracked3D(ii).x)*.05)>=(length(tracked3D(ii).x))
        
        % Fit second-order polynomial to the last 25% of the whisker. Use
        % this to extrapolate for the extension
        
        num2fit = round(length(tracked3D(ii).x)*.25);
        xyfit = polyfit(tracked3D(ii).x(end-num2fit:end),tracked3D(ii).y(end-num2fit:end),2);
        xzfit = polyfit(tracked3D(ii).x(end-num2fit:end),tracked3D(ii).z(end-num2fit:end),2);
        
        % Run a local function to extend the whisker 
        [~,~,idx,tempTracked] = LOCAL_extend_one_Seg(tracked3D(ii),xyfit,xzfit,px,py,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10),isnan(Y0_t(ii)));
        idx(isnan(idx)) = [];
        
        % plot is always turned off during normal code running. These lines
        % are here to remind you what to plot
        plotTGL = 0;
        if plotTGL
            close all
            [wskrFront,wskrTop] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
            [wskrFrontext,wskrTopext] = BackProject3D(tempTracked,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
            plot(px,py,'r')
            ho
            if ~isnan(Y0_t(ii))
                plotv(wskrTop,'.')
                plotv(wskrTopext,'go')
                
            else
                plotv(wskrFront,'.')
                plotv(wskrFrontext,'go')
            end
            figure
            plot3(tracked3D(ii).x,tracked3D(ii).y,tracked3D(ii).z,'.')
            ho
            plot3(tempTracked.x,tempTracked.y,tempTracked.z,'go')
            pause
        end
        tracked3D(ii) = tempTracked;
        
    end
    % outputs
    if ~isempty(idx)
        CPidx(ii) = idx(1);
        ridx = round(idx(1));
        if ~isnan(ridx)
            CP(ii,:) = [tracked3D(ii).x(ridx) tracked3D(ii).y(ridx) tracked3D(ii).z(ridx)];
        else
            fprintf('NaN CP idx at frame %i',ii)
            continue
        end
        
    end
    
    %% Verbosity
    if mod(ii,1000) == 0
        fprintf('Getting CP on frame: \t%i\n',ii)
    end
    
    
end
warning('on')
end

function [CPx,CPy,tempCPidx,wskr3D] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,px,py,A_camera,B_camera,A2B_transform,useFront)
counter = 1;
if useFront
    [wskr,~] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
else
    [~,wskr] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
end
numExtend = round(length(wskr(:,1))/20);
[CPx,CPy,tempCPidx,~] = intersections(wskr(:,1),wskr(:,2),px,py);
tempCPidx(isnan(tempCPidx)) = [];
if ~isempty(tempCPidx)
    tempCPidx = tempCPidx(1);
end

while counter <= 5 && (isempty(tempCPidx) || (tempCPidx+length(wskr(:,1))*.05)>length(wskr(:,1)) )
    
    if useFront
        [wskr,~] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
    else
        [~,wskr] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
    end
    
    numExtend = round(length(wskr)/20);
    [CPx,CPy,tempCPidx,~] = intersections(wskr(:,1),wskr(:,2),px,py);
    tempCPidx(isnan(tempCPidx)) = [];
    if ~isempty(tempCPidx)
        tempCPidx = tempCPidx(1);
    end
    
    nodespacing = median(diff(wskr3D.x));
    if size (wskr3D.x,1) == 1
        wskr3D.x = [wskr3D.x,wskr3D.x(end)+nodespacing];
        wskr3D.y = [wskr3D.y,polyval(whfitA,wskr3D.x(end))];
        wskr3D.z = [wskr3D.z,polyval(whfitB,wskr3D.x(end))];
    else
        wskr3D.x = [wskr3D.x;linspace(wskr3D.x(end),wskr3D.x(end)+(nodespacing*numExtend),numExtend)'];
        wskr3D.y = [wskr3D.y;polyval(whfitA,wskr3D.x(end-numExtend+1:end))];
        wskr3D.z = [wskr3D.z;polyval(whfitB,wskr3D.x(end-numExtend+1:end))];
    end
    counter = counter+1;
    
end


end % function LOCAL_extend_one_Seg




