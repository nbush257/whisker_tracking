function [whiskerData, xBase, yBase] = establishBasepoints(whiskerData,useX,basepointSmaller)
% function [whiskerData, xBase, yBase] = establishBasepoints(whiskerData,useX,basepointSmaller)
%
% This function takes a .whiskers file as input, and computes the median
% basepoint for the tracked whisker across all frames (xBase, yBase).
%
% Inputs:
% whiskerData -- whisker struct loaded from the .whiskers file
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

if nargin < 2
    warning('useX not specified!');
    useX = 1;
end

if nargin < 3
    warning('basepointSmaller not specified!');
    basepointSmaller = 0;
end

for count = 1:length(whiskerData)
% Sorting the whisker indexes is not necessary for this routine.
%   [whiskerData(count).x, whiskerData(count).y] = LOCAL_sortWhisker(whiskerData(count).x,whiskerData(count).y,useX);
    [whiskerData(count).xBase,whiskerData(count).yBase] = LOCAL_getBasepoint(whiskerData(count).x,whiskerData(count).y,useX,basepointSmaller);
end

xBase = nanmedian( [whiskerData.xBase] );
yBase = nanmedian( [whiskerData.yBase] );

end % EOF

function [x,y] = LOCAL_sortWhisker(x,y,useX)

if useX
    [x,indexes] = sort(x);
    y = y(indexes);
else
    [y,indexes] = sort(y);
    x = x(indexes);
end

end % EOF

function [xBase,yBase] = LOCAL_getBasepoint(x,y,useX,basepointSmaller)

if useX
    if basepointSmaller
        [xBase,baseIndex] = nanmin(x);
    else
        [xBase,baseIndex] = nanmax(x);
    end
    yBase = y(baseIndex);
else
    if basepointSmaller
        [yBase,baseIndex] = nanmin(y);
    else
        [yBase,baseIndex] = nanmax(y);
    end
    xBase = x(baseIndex);
end

end % EOF