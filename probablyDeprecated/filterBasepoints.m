function badBP = filterBasepoints(BP,xTol,yTol,useX,basepointSmaller)
% function filterBasepoints(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller)
%
% This function filters the frames of a basepoint by enforcing a
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
%%

warning('This function has been significantly altered from John Shppard''s original code. It is a first order approach which I think has been improved in later code. (NEB 2016_07_07)')


    xTol = 10;


    yTol = 10;

    useX = 1;
    basepointSmaller = 0;

medBP = nanmedian(BP);

badBP = (abs(BP(:,1)-medBP(1)) > xTol) ...
    || (abs(BP(:,2) - medBP(2))>yTol);




end % EOF