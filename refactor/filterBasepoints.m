function [whiskerData] = filterBasepoints(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller)
% function filterBasepoints(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller)
%
% This function filters the frames of a .whiskers file by enforcing a
% spatial threshold on the input data. Whisker frames in which the whisker's
% basepoint is spatially offset beyond an x- or y- distance threshold from
% the median basepoint across all frames are filtered out of the data to be
% analyzed.
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
% John Sheppard, 27 October 2014.

if nargin < 4
    xTol = 5;
end

if nargin < 5
    yTol = 5;
end

if nargin < 6
    warning('useX not specified!');
    useX = 1;
end

if nargin < 7
    warning('basepointSmaller not specified!');
    basepointSmaller = 0;
end

for count = 1:length(whiskerData) 
   % Indicates unstable basepoint.
   if ~isempty(whiskerData(count).x) && ...
        ((abs(whiskerData(count).xBase - xBase) > xTol) || ...
           (abs(whiskerData(count).yBase - yBase) > yTol))
        whiskerData(count).stableBasepoint = 0;
   elseif ~isempty(whiskerData(count).x)
        whiskerData(count).stableBasepoint = 1; 
   else
       whiskerData(count).stableBasepoint = 0;
   end
   
end



end % EOF