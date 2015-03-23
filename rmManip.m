function wStructOut = rmManip(wStruct,manip,startFrame,endFrame);

manip = manip(startFrame:endFrame);
thresh = 15;
parfor ii = 1:length(wStruct)
    
    %     if mod(round(ii/length(wStruct)*100),10)==0
    %         fprintf('. \n')
    %     end
    x = wStruct(ii).x;
    y = wStruct(ii).y;
    time = wStruct(ii).time;
    idx=[];
    for jj = 1:length(x)
        if isempty(manip(ii))
            continue
        end
        d = sqrt((manip(ii).x-x(jj)).^2+(manip(ii).y-y(jj)).^2);
        [~,CP] = min(d)
        if any(d<=thresh)
            idx = [idx jj];
        end
        %         plot(d);
        %         pause(.01)
        %         cla
    end
    
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
    wStructOut(ii).x = double(x);
    wStructOut(ii).y = double(y);
    wStructOut(ii).time = double(time);
end


