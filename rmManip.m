function [wStructOut,CP] = rmManip(wStruct,manip,startFrame,endFrame);
% contact point is putative. Should only exist if there is contact. 
manip = manip(startFrame:endFrame);
thresh = 15;
CP = nan(length(wStruct),2);

for ii = 1:length(wStruct)
    
    %     if mod(round(ii/length(wStruct)*100),10)==0
    %         fprintf('. \n')
    %     end
    x = double(wStruct(ii).x);
    y = double(wStruct(ii).y);
    time = double(wStruct(ii).time);
    
    
    
    
    idx=[];
    if isempty(manip(ii).x)
        continue
    else
        mX = manip(ii).x;
        mY = manip(ii).y;
    end
    
    if isrow(mX)
        mX = mX';
        mY = mY';
    end
    [~,d] = dsearchn([mX mY],[x y]);
    idx = find(d<thresh);
    [~,CP_idx] = min(d);
    
    
    
    %this comment will just remove the points near the manipulator
    %     x(idx) = NaN;
    %     y(idx) = NaN;
    
    % this section interpolates between the two end points of the removed
    % section
    if length(idx)>1
        newX = linspace(x(idx(1)),x(idx(end)),length(idx))';
        if newX(1)>newX(end)
            newX = flipud(newX);
        end
        if idx(end)+15 >length(x) | idx(1)-15<1
            
            %do a linear fit to the idx vals
            p = polyfit(x(idx),y(idx),1);
            y(idx) = polyval(p,x(idx));
            
        else
            
            pre5x = x(idx(1)-15:(idx(1)-1));
            post5x = x(idx(end)+1:(idx(end)+15));
            pre5y = y(idx(1)-15:(idx(1)-1));
            post5y = y(idx(end)+1:(idx(end)+15));
            nearbyX = [pre5x;post5x];
            nearbyY = [pre5y;post5y];
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


