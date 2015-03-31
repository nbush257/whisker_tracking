function [wStructOut,CP] = rmManip(wStruct,manip,startFrame,endFrame)
%% function [wStructOut,CP] = rmManip(wStruct,manip,startFrame,endFrame)
% --------------------------------------------------------------
% Interpolates the tracked whisker near the position of the manipulator
% --------------------------------------------------------------
% INPUTS:
%   wStruct: Tracked whisker structure containing x,y, and time fields.
%   manip: Tracked manipulator structure containing x,y, and time fields.
%   startFrame: Index of the manipulator struct to start at.
%   endFrame: Index of the manipulator struct to end at.
% OUTPUTS:
%   wStructOut = Tracked whisker containing the interpolated x,y fields,
%       and time
%   CP = Contact point is an N x 2 matrix of x,y points where the
%       manipulator intersects the whisker
% -----------------------------------------------------------------
% NOTES: Contact point is putative. Should only exist if there is contact.
%           Serious concerns about referencing frames. Probably should
%           reference by timestamp, not struct index. Probably only minor
%           off by one errors, but needs to be fixed ASAP.
% ----------------------------------------------------------------
% Nick Bush
% 2015_03_30
%%
warning('Manipulator Structures are referenced to the entire seq, whereas whisker structs are referenced to zero. High probability of off by one errors. Nick needs to fix this immediately')
plotFlag = 0;
order = 2;% flag to set the order of the fit.


thresh = 15;% set the size of the ROI around the manipulator to exclude points from the whisker
fitSurround = 30;% Number of points around the manipulator to use for the fit.
% init CP
CP = nan(length(wStruct),2);

% reduce manip struct to relevant struct.
manip = manip(startFrame:endFrame);

CP = nan(length(wStruct),2);

parfor ii = 1:length(wStruct)
    
    % Get coords
    x = double(wStruct(ii).x);
    y = double(wStruct(ii).y);
    time = double(wStruct(ii).time);
    
    % idx is the index of points that will eventually be removed.
    idx=[];
    
    % Skip the loop if there is no manipulator
    if isempty(manip(ii).x)
        continue
    end
    % get Manip coords and reshape if needed
    mX = manip(ii).x;
    mY = manip(ii).y;
    if isrow(mX)
        mX = mX';
        mY = mY';
    end
    % find points within a thresholded distance of the manipulator
    [~,d] = dsearchn([mX mY],[x y]);
    idx = find(d<thresh);
    [~,CP_idx] = min(d);
    
    %Uncomment to just remove the points near the manipulator
    %     x(idx) = NaN;
    %     y(idx) = NaN;
    
    %% Interpolate between the two end points of the removed section
    if length(idx)>1
        newX = linspace(x(idx(1)),x(idx(end)),length(idx))';
        if newX(1)>newX(end)
            newX = flipud(newX);
        end
        if idx(end)+fitSurround >length(x) | idx(1)-fitSurround<1
            %do a linear fit to the idx vals
            p = polyfit(x(idx),y(idx),1);
            y(idx) = polyval(p,x(idx));
            
        else
            % get nearby points used in the fit
            preX = x(idx(1)-fitSurround:(idx(1)-1));
            postX = x(idx(end)+1:(idx(end)+fitSurround));
            preY = y(idx(1)-fitSurround:(idx(1)-1));
            postY = y(idx(end)+1:(idx(end)+fitSurround));
            nearbyX = [preX;postX];
            nearbyY = [preY;postY];
            [nearbyX,kept,~] = unique(nearbyX);
            nearbyY = nearbyY(kept);
            
            
            % interpolate over the break.
            if var(nearbyX)>var(nearbyY)% If statement prevents failures when there is no variance over x.
                
                newX = linspace(x(idx(1)),x(idx(end)),length(idx))';
                if newX(1)>newX(end)
                    newX = flipud(newX);
                end
                
                p = polyfit(nearbyX,nearbyY,order);
                
                newY = polyval(p,newX);
            else
                
                newY = linspace(y(idx(1)),y(idx(end)),length(idx))';
                if newY(1)>newY(end)
                    newY = flipud(newY);
                end
                p = polyfit(nearbyY,nearbyX,order);
                newX = polyval(p,newY);
            end 
            
            %% set output
            x(idx) = newX;
            y(idx) = newY;
            %% plot
            if plotFlag
                plot(x,y,'.')
                hold on
                %plot(newX,newY,'r.')
                plot(newX,newY,'g.')
                %legend({'original','Linear','7th'})
                axis([0 640 0 480])
                pause(.01)
                cla
            end
            
            
        end % end if we are not near the basepoint or tip
    end% end if the manipulator is close enough to at least one whisker node.
    %% Outputs
    % necesarry for the parfor.
    CPx = x(CP_idx);
    CPy = y(CP_idx);
    CP(ii,:) = [CPx CPy];
    
    wStructOut(ii).x = double(x);
    wStructOut(ii).y = double(y);
    wStructOut(ii).time = double(time);
end


