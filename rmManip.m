function wStructOut = rmManip(wStruct,manip,startFrame,endFrame);

manip = manip(startFrame:endFrame);
thresh = 10;
for ii = 1:length(wStruct)
    
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
        newX = linspace(x(idx(1)),x(idx(end)),length(idx));
        pre5x = x(idx(1)-5:(idx(1)-1));
        post5x = x(idx(end)+1:(idx(end)+5));
        pre5y = y(idx(1)-5:(idx(1)-1));
        post5y = y(idx(end)+1:(idx(end)+5));
        newY = interp1([pre5x;post5x],[pre5y;post5y],newX,'spline');
        
        x(idx) = newX;
        y(idx) = newY;
    end
    
    
    
    
    wStructOut(ii).x = double(x);
    wStructOut(ii).y = double(y);
    wStructOut(ii).time = double(time);
end


