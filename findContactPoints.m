function whiskerData = findContactPoints(whiskerData,manipData)
% function whiskerData = findContactPoints(whiskerData,manipData)
%
% This function attempts to find contact points between the manipulator
% and the whisker based on intersections between segments of the whisker
% with the manipulator line segment of best fit.
%
% John Sheppard, 29 October 2014

for count = 1:length(whiskerData)
    disp(['Processing frame ' num2str(count) ' of ' num2str(length(whiskerData)) ' frames.']);
    frame = whiskerData(count).time;
  
    % Initialize variables for contact point
    contactPointX = NaN; contactPointY = NaN;
    
    manipIndex = find ( [manipData.time] == frame);
    if ~isempty(manipIndex)
    % We assume there is only one manipulator entry per time point.
    manipIndex = manipIndex(1);
    else
        continue
    end
    
    %if ~isempty(manipIndex)
        
        whiskerX = whiskerData(count).x;
        whiskerY = whiskerData(count).y;
        
        manipX = manipData(manipIndex).manipX;
        manipY = manipData(manipIndex).manipY;
        
        % Find theoretical intersection point between the manipulator line and a
        % segment in the whisker.
        
        % Slope of manip
        manipBetas(1) = diff(manipY)/diff(manipX);
        % Y-intercept of manip
        manipBetas(2) = manipY(1) - manipBetas(1)*manipX(1);
        
        validIntersectX = [];
        validIntersectY = [];
        
        for index = 1:length(whiskerX)-1
            
            % Slope of whisker seg
            whiskSegBetas(1) = diff(whiskerY(index:index+1))/diff(whiskerX(index:index+1));
            % Y-intercept of seg
            whiskSegBetas(2) = whiskerY(index) - whiskSegBetas(1)*whiskerX(index);
            
            % Assemble matrix for system of equations.
            A = [-manipBetas(1), 1; -whiskSegBetas(1), 1];
            b = [manipBetas(2); whiskSegBetas(2)];
            
            X = A\b;
            
            intX = X(1); intY = X(2);
            
            % Does intX fall within bounds of manipulator?
            if intX > min(manipX) && intX < max(manipX)
                % Does intX fall within bounds of whisker segment?
                if intX > min(whiskerX(index:index+1)) && intX < max(whiskerX(index:index+1))
                    % Does intY fall within bounds of manipulator?
                    if intY > min(manipY) && intY < max(manipY)
                        % Does intY fall within bounds of whisker segment?
                        if intY > min(whiskerY(index:index+1)) && intY < max(whiskerY(index:index+1))
                            validIntersectX = [validIntersectX, intX];
                            validIntersectY = [validIntersectY, intY];
                        end
                    end
                end
            end

        end
        
        if length(validIntersectX) == 1
            contactPointX = validIntersectX;
            contactPointY = validIntersectY;
        end
    %end
    
    whiskerData(count).contactPointX = contactPointX;
    whiskerData(count).contactPointY = contactPointY;
    
end

end % EOF

