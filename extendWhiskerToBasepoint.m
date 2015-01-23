function [whiskerData] = extendWhiskerToBasepoint(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller)
% function [whiskerData] = extendWhiskerToBasepoint(whiskerData,useX,basepointSmaller)
%
% This function extends a whisker to the basepoint in cases where the base
% of the whisker is outside of the tolerated distance to the whisker.
%
% Inputs:
% whiskerData -- whisker structure loaded from .whiskers file
%
% xBase, yBase = x- and y- coordinates of the median basepoint across
% frames.
%
% xTol, yTol -- Deviations allowed from medianBasepoint in x- and
% y-directions (units of pixels).
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
% WARNING: CURRENTLY THIS FUNCTION ONLY WORKS FOR basepointSmaller = 0
% 
% John Sheppard, 28 October 2014.

% Loop for every frame in whisker struct
for count = 1:length(whiskerData)
    
    % Step 1: Determine if the whisker does not extend to the basepoint within
    % tolerance.
    if (abs(whiskerData(count).xBase - xBase) > xTol) || ...
            (abs(whiskerData(count).yBase - yBase) > yTol)
        stableBasepoint = 0;
    else
        stableBasepoint = 1;
    end
    
    % Step 2: If whisker does not extend to basepoint, see if the whisker can
    % be extended to basepoint.
    if ~stableBasepoint
        
        % Set coordinate system so that whisker axis aligns with x-axis
        if useX % (front view)
            xPoints = whiskerData(count).x;
            yPoints = whiskerData(count).y;
            thisBasepointSmaller = basepointSmaller;
            xBaseAdj = xBase;
            yBaseAdj = yBase;
        else % Rotate coordinate system by 90deg if ~useX
            xPoints = whiskerData(count).y;
            yPoints = whiskerData(count).x;
            xBaseAdj = yBase;
            yBaseAdj = xBase;
            thisBasepointSmaller = ~basepointSmaller; % This changes signs if we switch coordinate systems.
        end
        
        % Re-zero the coordinate system.
        if thisBasepointSmaller
            [basepointX,basepointIndex] = nanmin(whiskerData(count).x);
        else
            [basepointX,basepointIndex] = nanmax(whiskerData(count).x);
        end
        
        xPoints = whiskerData(count).x - basepointX;
        yPoints = whiskerData(count).y - whiskerData(count).y(basepointIndex);
        xBaseAdj = xBaseAdj - basepointX;
        yBaseAdj = yBaseAdj - whiskerData(count).y(basepointIndex);
        
        % Sort xPoints and yPoints in ascending order of xPoints
        [xPoints,sortedIndexes] = sort(xPoints);
        yPoints = yPoints(sortedIndexes);
        
        % Fit cubic polynomial
        betas = polyfit(xPoints,yPoints,3);
        
        % Find extent of "linear" portion of the whisker based on fitted
        % cubic function. (i.e. X s.t. |(A+BX)| > 0.9 * |(CX^2 + DX^3)|
        linMags = abs(betas(4) + betas(3)*xPoints);
        nonlinMags = abs(betas(2)*xPoints.^2 + betas(1).*xPoints.^3);
        relLinMags = linMags./nonlinMags;
        lastLinIndex = max( find( relLinMags > 9) );
        
        linXPoints = xPoints(1:lastLinIndex);
        linYPoints = yPoints(1:lastLinIndex);
        
        % Skip and warn user if we do not detect any quasi-linear segment of the whisker
        if isempty(xPoints)
            continue;
            warning(['No quasi-linear whisker segment detected for frame #' num2str(count) '!']);
        end
        
        % Fit line to quasi-linear portion of whisker
        betas = polyfit(linXPoints,linYPoints,1);
        
        extraXPoints = 0.25:0.25:50;
        extraYPoints = polyval(betas,extraXPoints);
        
        closePointIndexes = find( abs(extraXPoints - xBaseAdj) < xTol & abs(extraYPoints - yBaseAdj) < yTol );
        
        % Skip and warn user if we do not detect any quasi-linear segment of the whisker
        if isempty(closePointIndexes)
            continue;
            warning(['Whisker segment extension unsucessful for frame #' num2str(count) '!']);
        end
        
        endXPoints = extraXPoints(closePointIndexes);
        endYPoints = extraYPoints(closePointIndexes);
        
        [junk,endPointIndex] = min( xBaseAdj - endXPoints );
        endXPoint = endXPoints(endPointIndex);
        
        [junk,extraXPointIndex] = find( min( abs( extraXPoints - endXPoint) ) );
        
        extraXPoints = extraXPoints(1:extraXPointIndex);
        extraYPoints = extraYPoints(1:extraXPointIndex);
        
        xPoints = [xPoints(:)', extraXPoints];
        yPoints = [yPoints(:)', extraYPoints];
        
        % Now, transform the extended points back to original coordinate
        % system.
        xPoints = whiskerData(count).x + basepointX;
        yPoints = whiskerData(count).y + whiskerData(count).y(basepointIndex);
        
        % Remember the rotation if ~useX
        if useX
            whiskerData(count).x = xPoints;
            whiskerData(count).y = yPoints;
        else
            whiskerData(count).x = yPoints;
            whiskerData(count).y = xPoints;
        end
        
        whiskerData(count).stableBasepoint = 1;
        
    end % if ~stableBasepoint
    
end % for count

end % EOF
