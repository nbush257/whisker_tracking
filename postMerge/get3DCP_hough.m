function [CP,CPidx,tracked3D] = get3DCP_hough(manip,tracked3D,calibInfo,C)
%% function CP = get3DCP_hough(Y0,Y1,tracked3D,calibInfo,C)
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
%               space. Units are in the same units as tracked3D (should be mm)
%           CPidx = [numFrames x 1] vector indicating the node index which is
%               closest to the 3D contact point.
%           tracked3D = structure of 3D whisker points; will have extended
%               shapes in it.
% =========================================================================
%% Unpack inputs
Y0_f = manip.Y0_f;
Y0_t = manip.Y0_t;

Y1_f = manip.Y1_f;
Y1_t = manip.Y1_t;

%% Initialize variables
plotTGL = 1;
CP = nan(length(tracked3D),3);
CPidx = nan(length(tracked3D),1);
l_thresh = 10; % fewest number of points allowed in the whisker for CP calculation
num_nodes = 1; % nodes used in splinefit
ext_pct = .05; % length of the whisker that we want to extend beyond the CP.
%% loop over every frame
for ii = 1:length(tracked3D)
    % Prevent intersections from being annoying
    warning('off')
    
    %% skip frames with no contact, no whisker, short whiskers, or whiskers
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
    %% Backproject
    % backproject the 3D whisker into the appropriate view based on which
    % view the manipulator was tracked in and finds where the whisker intersects the manipulator.
    % If both views have a tracked manipulator, defaults to top, as that is generally better tracked.
    
    % if top is tracked
    if ~isnan(Y0_t(ii))
        useTop = 1;
        useFront = 0;
        px = [0;640];
        py = [Y0_t(ii);Y1_t(ii)];
        [~,wskrTop] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [~,~,idx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px,py);
        idx(isnan(idx)) = [];
        
        % else if front is tracked
    elseif ~isnan(Y0_f(ii))
        
        useTop = 0;
        useFront = 1;
        
        px = [0;640];
        py = [Y0_f(ii);Y1_f(ii)];
        [wskrFront,~] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [~,~,idx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px,py);
        idx(isnan(idx)) = [];
        
        % Skip CP if no manipulator is tracked in this frame.
    else
        continue
    end
    
    %% Extend whisker if needed
    % Run this section if contact was indicated and a manipulator was tracked, but the whisker and manipulator do not intersect
    
    if isempty(idx) || (idx(1)+length(tracked3D(ii).x)*ext_pct)>=(length(tracked3D(ii).x))
        
        count = 1;
        tempTracked = tracked3D(ii);
        while isempty(idx) || (idx(1)+length(tempTracked.x)*ext_pct)>=(length(tempTracked.x))
%             fprintf('Extending iteration %i on frame %i\n',count,ii)
            [tempTracked,idx] = LOCAL_extend(tempTracked,num_nodes,calibInfo,px,py,useFront);
            count = count+1;
            if count>2
                break
            end
            
        end
        
        
        %         plot is always turned off during normal code running. These lines
        % are here to remind you what to plot
        if plotTGL
            close all
            [wskrFront,wskrTop] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
            [wskrFrontext,wskrTopext] = BackProject3D(tempTracked,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
            plot(px,py,'r')
            ho
            if ~isnan(Y0_t(ii))
                plotv(wskrTop,'.');
                plotv(wskrTopext,'go');
                
            else
                plotv(wskrFront,'.');
                plotv(wskrFrontext,'go');
            end
            figure
            plot3(tracked3D(ii).x,tracked3D(ii).y,tracked3D(ii).z,'.')
            ho
            plot3(tempTracked.x,tempTracked.y,tempTracked.z,'go')
            title(['Frame: ' num2str(ii)])
            axis equal
            grid on
            pause
            close all
            pause(.01)
        end
        tracked3D(ii).x = tempTracked.x;
        tracked3D(ii).y = tempTracked.y;
        tracked3D(ii).z = tempTracked.z;
    end
    
    %% outputs
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
    
    
    
    warning('on')
end
end

function [wskr3D,idx] = LOCAL_extend(tracked3D,num_nodes,calibInfo,px,py,useFront)
%% Splinefit to extend

% extend the whisker by 10%
extPts = round(length(tracked3D.x)*0.1);

%
node_spacing = median(diff(tracked3D.x));

segment_length = 0.3;
mode = 'full';
% splinefit
switch mode
    case 'full'
        PP = splinefit(tracked3D.x,tracked3D.y,num_nodes,'r');
        
        
        xx = [tracked3D.x(1:end-1);[tracked3D.x(end):node_spacing:(tracked3D.x(end)+node_spacing*extPts)]'];
        yy = ppval(PP,xx);
        
        
        PP = splinefit(tracked3D.x,tracked3D.z,num_nodes,'r');
        zz = ppval(PP,xx);
        wskr3D.x = xx;
        wskr3D.y = yy;
        wskr3D.z = zz;

    case 'segment'
        segment = round(length(tracked3D.x)*(1-segment_length)):length(tracked3D.x)-1;
        PP = splinefit(tracked3D.x(segment),tracked3D.y(segment),num_nodes,'r');
        
        
        xx = [tracked3D.x(1:end-1);[tracked3D.x(end):node_spacing:(tracked3D.x(end)+node_spacing*extPts)]'];
        yy = ppval(PP,xx);
        
        
        PP = splinefit(tracked3D.x(segment),tracked3D.z(segment),num_nodes,'r');
        zz = ppval(PP,xx);
        
        wskr3D.x = [tracked3D.x; xx(length(tracked3D.x+1):end)];
        wskr3D.y = [tracked3D.y; yy(length(tracked3D.y+1):end)];
        wskr3D.z = [tracked3D.z; zz(length(tracked3D.z+1):end)];
end


if useFront
    [wskr,~] = BackProject3D(wskr3D,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
else
    [~,wskr] = BackProject3D(wskr3D,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
end

[~,~,idx,~] = intersections(wskr(:,1),wskr(:,2),px,py);


end



