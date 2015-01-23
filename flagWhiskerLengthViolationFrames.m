function whiskerData = flagWhiskerLengthViolationFrames(whiskerData,baseWhiskerX,baseWhiskerY,tol)
% function whiskerData = flagWhiskerLengthViolationFrames(whiskerData,baseWhiskerX,baseWhiskerY,tol)
%
% This function flags frames where the whisker length is too long compared
% to the whisker length on a "baseline" frame (i.e. first image in seq
% file) where the whisker is fully extended. Frames where the whisker
% exceeds this baseline length substantially are likely erroneous due to
% the whisker becoming contiguous with the manipulator.
%
% Inputs:
% whiskerData -- structure from .whiskers file
%
% baseWhiskerX/Y -- x and y vectors of whisker from baseline image (first
% image in seq file)
%
% tol -- percentage by which baseline length is allowed to be exceeded by
% (default = 0.2 = 20% extension)
%
% John Sheppard, 31 October 2014

if nargin < 4
    tol = 0.2;
end

baseLength = getWhiskerLength(baseWhiskerX,baseWhiskerY);

for count = 1:length(whiskerData)
    
    thisLength = getWhiskerLength(whiskerData(count).x,whiskerData(count).y);
    
    relMag = thisLength/baseLength;
    
    if relMag > (1 + tol)
        whiskerData(count).validLength = 0;
    else
        whiskerData(count).validLength = 1;
    end
    
end

end % EOF

function whiskerLength = getWhiskerLength(x,y)
% function whiskerLength = getWhiskerLength(x,y)
%
% This function computes the length of the whisker for a given frame.
%
% John Sheppard, 29 October 2014

xSqDiffs = diff(x).^2;
ySqDiffs = diff(y).^2;

whiskerLength = sum( (xSqDiffs + ySqDiffs).^0.5 );

end % EOF