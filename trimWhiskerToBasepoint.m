function [whiskerData] = trimWhiskerToBasepoint(whiskerData,xBase,yBase,tol,useX,basepointSmaller)
% function [whiskerData] = trimWhiskerToBasepoint(whiskerData,xBase,yBase,tol,useX,basepointSmaller)
% 
% This function trims a whisker to the basepoint in cases where the base
% of the whisker extends too far beyond the basepoint.
% 
% Inputs:
% whiskerData -- whisker structure loaded from .whiskers file
% 
% xBase, yBase = x- and y- coordinates of the median basepoint across
% frames (computed with establishBasepoint.m)
% 
% tol -- Deviation allowed from medianBasepoint on longitudinal axis of
% whisker (this is either in the x- or y- direction, depending on useX)
% 
% useX -- flag that specifies whether to use x- (1) or y- (0) axis to sort
% the whisker. NOTE: WHEN USING IMAGES, X-AXIS IS VERTICAL AND Y-AXIS IS
% HORIZONTAL. (In general, useX = 1 for "top" camera and 0 for "front"
% camera.)
% 
% basepointSmaller -- flag that specifies if the x- or y- coordinate (see
% useX) of interest is more negative at the basepoint than at the tip of
% the whisker. For instance, if useX = 1 with the basepoint on the right
% side of the image, basepointSmaller = 0 because the x-values are larger
% at the basepoint (right side of image) than whisker tip (left side of
% image).
% 
% John Sheppard, 28 October 2014.

if useX
    if basepointSmaller
        % Loop through all frames in whisker struct.
        
        for count = 1:length(whiskerData)
            % Look for possible points in which whisker extends too far in the relevant
            % direction beyond the basepoint.
            badIndexes = find([whiskerData(count).x] < (xBase + tol));
            whiskerData(count).x(badIndexes) = [];
            whiskerData(count).y(badIndexes) = [];
        end
    else
        
        % Loop through all frames in whisker struct.
        for count = 1:length(whiskerData)
            % Look for possible points in which whisker extends too far in the relevant
            % direction beyond the basepoint.
            badIndexes = find([whiskerData(count).x] > (xBase - tol));
            whiskerData(count).x(badIndexes) = [];
            whiskerData(count).y(badIndexes) = [];
        end
    end
    
else
    if basepointSmaller
       
        % Loop through all frames in whisker struct.
        for count = 1:length(whiskerData)
            % Look for possible points in which whisker extends too far in the relevant
            % direction beyond the basepoint.
            badIndexes = find([whiskerData(count).y] < (yBase + tol));
            whiskerData(count).x(badIndexes) = [];
            whiskerData(count).y(badIndexes) = [];
        end
        
    else
        
        % Loop through all frames in whisker struct.
        for count = 1:length(whiskerData)
            % Look for possible points in which whisker extends too far in the relevant
            % direction beyond the basepoint.
            badIndexes = find([whiskerData(count).y] > (yBase - tol));
            whiskerData(count).x(badIndexes) = [];
            whiskerData(count).y(badIndexes) = [];
        end
    end
end

% Re-filter the basepoints after trimming.
% uses same tol for x and y directions
whiskerData = filterBasepoints(whiskerData,xBase,yBase,tol,tol,useX,basepointSmaller);

end % EOF












