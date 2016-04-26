function CP = get3DCP_hough(Y0_f,Y1_f,Y0_t,Y1_t,tracked3D,calibInfo,C)
%% function CP = get3DCP_hough(Y0,Y1,tracked3D,calibInfo)
% Calculates the 3D contact point by backprojecting the tracked 3D whisker
% into 2D and finding the intersection.
% ======================================
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

CP = nan(length(tracked3D),3);
CPidx = nan(length(tracked3D),1);
l_thresh = 10; % fewest number of points allowed in the whisker for CP calculation
missingMan = logical(zeros(length(C),1));
for ii = 1:length(tracked3D)
    if ~C(ii)
        continue
    end
    if isempty(tracked3D(ii).x) || length(tracked3D(ii).x)<l_thresh
        continue
    end
    
    if ~isnan(Y0_t(ii))
        px = [0;640];
        py = [Y0_t(ii);Y1_t(ii)];
        [~,wskrTop] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [x1,y1,idx,~] = intersections(wskrTop(:,1),wskrTop(:,2),px,py);        
        
    elseif ~isnan(Y0_f(ii))
        px = [0;640];
        py = [Y0_f(ii);Y1_f(ii)];
        [wskrFront,~] = BackProject3D(tracked3D(ii),calibInfo(5:8),calibInfo(1:4),calibInfo(9:10));
        [x1,y1,idx,~] = intersections(wskrFront(:,1),wskrFront(:,2),px,py);
    else
        missingMan(ii) = 1;
    end
    
    
    
    %% EVERYTHING BELOW HERE IS NOT FINISHED
    
    counter =0;
        while isempty(idx) | idx>=(length(tracked3D(ii).x)+10)
            counter = counter+1;
            
            xyfit = polyfit(tracked3D(ii).x,tracked3D(ii).y,3);
            xzfit = polyfit(tracked3D(ii).x,tracked3D(ii).z,3);
            [CPx,CPy,tempCPidx,tempTracked] = LOCAL_extend_one_Seg(tracked3D(ii),xyfit,xzfit,px,py,calibInfo(5:8),calibInfo(1:4),calibInfo(9:10),1);
            tracked3D(ii) = tempTracked;
            
            if counter>100
                        [wskrTop,wskrFront] = BackProject3D(tracked3D(ii),calib(5:8),calibInfo(1:4),calibInfo(9:10));  
                        figure(123)
                plot(wskrFront(:,1),wskrFront(:,2),'.')
                ho
                plot(px,py,'o')
                break
            end
                
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
    try
        [CPx,CPy,tempCPidx,wskr3D] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,px,py,A_camera,B_camera,A2B_transform,useFront);
    catch
        fprintf('Probable recursion error. If this happens a lot we have a serious problem\n')
        return
    end
end


end % function LOCAL_extend_one_Seg




