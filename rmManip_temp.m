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



thresh = 15;% set the size of the ROI around the manipulator to exclude points from the whisker
fitSurround = 15;% Number of points around the manipulator to use for the fit.
% init CP
CP = nan(length(wStruct),2);

% reduce manip struct to relevant struct.
manip = manip(startFrame:endFrame);

for ii = 1:length(wStruct)
    
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
            
            
            %
            %         if nearbyX(1)>nearbyX(end) & nearbyY(1)>nearbyY(end)
            %             nearbyX = flipud(nearbyX);
            %             nearbyY = flipud(nearbyY);
            %             newX = flipud(newX);
            %         elseif nearbyX(1)>nearbyX(end) | nearbyY(1)>nearbyY(end)
            %             warning(['Non monotonic in one direction. Probably Going to error at frame ' num2str(time)])
            %         end
            
            newY = interp1(nearbyX,nearbyY,newX);
            
            x(idx) = newX;
            y(idx) = newY;
        end
    end
    
    CP(ii,1) = x(CP_idx);
    CP(ii,2) = y(CP_idx);
    wStructOut(ii).x = double(x);
    wStructOut(ii).y = double(y);
    wStructOut(ii).time = double(time);
end


