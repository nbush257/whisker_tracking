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