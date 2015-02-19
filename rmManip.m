function wStructOut = rmManip(wStruct,manip,startFrame,endFrame);

manip = manip(startFrame:endFrame);
thresh = 5;
for ii = 1:length(wStruct)
    
%     if mod(round(ii/length(wStruct)*100),10)==0
%         fprintf('. \n')
%     end
    x = wStruct(ii).x;
    y = wStruct(ii).y;
    idx=[];
    for jj = 1:length(x)
        if isempty(manip{ii})
            continue
        end
        d = sqrt((manip{ii}(1,:)-x(jj)).^2+(manip{ii}(2,:)-y(jj)).^2);
        if any(d<=thresh)
            idx = [idx jj];
        end
    end
    %this comment will just remove the points near the manipulator
%      x(idx) = [];
%      y(idx) = [];

    % this section interpolates between the two end points of the removed
    % section
    if length(idx)>1
        x(idx) = linspace(x(idx(1)),x(idx(end)),length(idx));
        y(idx) = linspace(y(idx(1)),y(idx(end)),length(idx));
    end
    
        
    
    % add an interpolation function here. 
    wStructOut(ii).x = x;
    wStructOut(ii).y = y;
end

    
    