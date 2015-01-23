function [whiskerData,manipData,xBase,yBase] = preprocessWhiskerData_NoSlopeSmooth(whiskerData,manipData,useX,basepointSmaller,xTol,yTol)
% function [whiskerData,xBase,yBase] = preprocessWhiskerData(whiskerData,manipData,useX,basepointSmaller,xTol,yTol)
%
% This routine runs the whiskerData (from .whiskers file) through various
% pre-processing stages to clean up the data prior to 3D merging.
%
% John Sheppard, 29 October 2014

%%  Declare vars
percent_base = 15;
%   Butterworth options
sampleRate = 250; lowCut = 0; highCut = 15;
%   Interp nodes
numNodes = 800;
%%
if nargin < 3
    useX = 1;
end

if nargin < 4
    basepointSmaller = 0;
end

if nargin < 5
    xTol = 5;
end

if nargin < 6
    yTol = 10;
end

% Remove duplicate frames from whisker data.
% whiskerData = removeDuplicateFrames(whiskerData,'whisker');

% if ~isempty(manipData)
% Remove duplicate frames from manipulator data.
% manipData = removeDuplicateFrames(manipData,'manipulator');
% end

% Do an initial sort of the x,y points in whisker
% for count = 1:length(whiskerData)
%     [whiskerData(count).x,whiskerData(count).y] = sortWhisker(whiskerData(count).x,whiskerData(count).y,useX,basepointSmaller);
% end

% Extend/trim basepoints as needed by visual inspection of the front and top camera
% views. Modified code by James Ellis for this.
whiskerData = extendAndTrimBasepoints(whiskerData,useX,basepointSmaller);

% Then establish the basepoints.
[whiskerData,xBase,yBase] = establishBasepoints(whiskerData,useX,basepointSmaller);

% NOT CURRENTLY WORKING, Oct-29-2014,jps
% Extend whisker to the basepoint in cases where it does not extend far
% enough.
%whiskerData = extendWhiskerToBasepoint(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller);

% Trim whisker to the basepoint in cases where it extends too far.
if useX
    tol = xTol;
else
    tol = yTol;
end

%whiskerData = trimWhiskerToBasepoint(whiskerData,xBase,yBase,tol,useX,basepointSmaller);

% Re-establish the median basepoint after trimming
% [whiskerData,xBase,yBase] = establishBasepoints(whiskerData,useX,basepointSmaller);

% Filter the basepoints to determine initial invalid frames.
whiskerData = filterBasepoints(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller);

% Smooth the basepoints to minimize tracking noise.
whiskerData = smoothBasepoints(whiskerData,useX,250,0,15);

% Recenter the whiskers to the smoothed basepoints.
for count = 1:length(whiskerData)
    
    whiskerData(count).xRaw = whiskerData(count).x;
    whiskerData(count).yRaw = whiskerData(count).y;
    
    [whiskerData(count).x,whiskerData(count).y] = sortWhisker(whiskerData(count).x,whiskerData(count).y,useX,basepointSmaller);
    xNudge = whiskerData(count).xBaseSmoothed - whiskerData(count).x(1);
    yNudge = whiskerData(count).yBaseSmoothed - whiskerData(count).y(1);
    
    whiskerData(count).x = double(whiskerData(count).x + xNudge);
    whiskerData(count).y = double(whiskerData(count).y + yNudge);
end
    
% Compute the slope of the whisker via linear regression of first 20 points from basepoint.
% slopeIndexes = 1:20; % use first 30 pts from basepoint to compute slope
for count = 1:length(whiskerData)
    slopeIndexes = 1:floor(length(whiskerData(count).x)/(100/percent_base)); % use first XX percent from basepoint to compute slope
    if useX
        x = whiskerData(count).x; %thisBaseX = whiskerData(count).x(1);
        y = whiskerData(count).y; %thisBaseY = whiskerData(count).y(1);
    else % WILL THIS WORK??? new x = - old y, new y = old x
        x = -whiskerData(count).y; %thisBaseX = -whiskerData(count).y(1);
        y = whiskerData(count).x; %thisBaseY = whiskerData(count).x(1);
    end
    betas = polyfit(x(slopeIndexes),y(slopeIndexes),1);
    whiskerData(count).whiskerSlopeRaw = betas(1);
    whiskerData(count).whiskerAngleRaw = atan(betas(1));
end

% Smooth the initial whisker segment angles temporally to reduce tracking noise.
whiskerAngles = [whiskerData.whiskerAngleRaw];
sampleRate = 250; lowCut = 0; highCut = 15;
%whiskerAnglesSmoothed = bpfft(whiskerAngles,sampleRate,lowCut,highCut);
whiskerAnglesSmoothed = bwfilt(double(whiskerAngles(:)),sampleRate,lowCut,highCut);

for count = 1:numel(whiskerData)
    whiskerData(count).whiskerAngle = whiskerAnglesSmoothed(count);
end

% Rotate the whiskers based on the smoothed initial whisker segment slopes.
for count = 1:numel(whiskerData)
    
        x = whiskerData(count).x; thisBaseX = whiskerData(count).x(1);
        y = whiskerData(count).y; thisBaseY = whiskerData(count).y(1);

   % Subtract x(1) and y(1) from x/y vectors so that basepoint becomes the
   % origin of coordinate system.
   whiskerX = x - thisBaseX; %whiskerData(count).x(1); 
   whiskerY = y - thisBaseY; %whiskerData(count).y(1);
   
   angleNudge = whiskerData(count).whiskerAngle - whiskerData(count).whiskerAngleRaw;
   rotWhiskerXY = brotate([whiskerX(:),whiskerY(:)],-angleNudge);
   
   % Add basepoints back on after rotation.

%   whiskerData(count).x = double(rotWhiskerXY(:,1) + whiskerData(count).x(1));
%   whiskerData(count).y = double(rotWhiskerXY(:,2) + whiskerData(count).y(1)); 

end

% THIS IS FOR CHECKING THAT WE SUCCESFULLY SMOOTEHD THE WHISKERS
for count = 1:numel(whiskerData)
    slopeIndexes = 1:floor(length(whiskerData(count).x)/(100/percent_base)); % use first XX percent from basepoint to compute slope
    if useX
        x = whiskerData(count).x; %thisBaseX = whiskerData(count).x(1);
        y = whiskerData(count).y; %thisBaseY = whiskerData(count).y(1);
    else % WILL THIS WORK??? new x = - old y, new y = old x
        x = -whiskerData(count).y; %thisBaseX = -whiskerData(count).y(1);
        y = whiskerData(count).x; %thisBaseY = whiskerData(count).x(1);
    end
    betas = polyfit(x(slopeIndexes),y(slopeIndexes),1);
    whiskerData(count).whiskerSlopeAdj = betas(1);
    whiskerData(count).whiskerAngleAdj = atan(betas(1));
end


% Fit polynomial (a1x^4 + a2x^3 + a3x^2) to the whiskers.
for count = 1:numel(whiskerData)
    
    % Rotate clockwise by whiskerAngle + pi.
        x = whiskerData(count).x - whiskerData(count).x(1);
        y = whiskerData(count).y - whiskerData(count).y(1);

  if useX
    xyRot = brotate([x(:),y(:)],whiskerData(count).whiskerAngle + pi);
  else
    xyRot = brotate([x(:),y(:)],whiskerData(count).whiskerAngle + pi/2);  
  end
    
    xRot = xyRot(:,1);
    yRot = xyRot(:,2);
    
    % Another small nudge is required to get the whisker perfectly
    % horizontal along x-axis (I'm not sure why).
    slopeIndexes = 1:floor(length(whiskerData(count).x)/(100/percent_base)); % use first XX percent from basepoint to compute slope
    betas = polyfit(xRot(slopeIndexes),yRot(slopeIndexes),1);
    
    finalAngleNudge = betas(1);
    whiskerData(count).finalAngleNudge = finalAngleNudge;
    
    xyRot = brotate(xyRot,finalAngleNudge);
    xRot = xyRot(:,1);
    yRot = xyRot(:,2);

    A = fitPolyWhisker(xRot,yRot);
    
    whiskerData(count).whiskerFitBetas = A;
    
    % Now reconstruct the whisker using the polynomial fit.
    % Use 100 nodes for the whisker reconstruction.
    xPolyFit = linspace(xRot(1),xRot(end),100);
    yPolyFit = A(1)*xPolyFit.^4 + A(2)*xPolyFit.^3 + A(3)*xPolyFit.^2;
    
    % Now rotate the polyfit whisker back to the original whisker
    % orientation
    if useX
    xyPolyFitRot = brotate([xPolyFit(:),yPolyFit(:)],-finalAngleNudge -pi -whiskerData(count).whiskerAngle);
    else
    xyPolyFitRot = brotate([xPolyFit(:),yPolyFit(:)],-finalAngleNudge -pi/2 -whiskerData(count).whiskerAngle);
    end    
    
    whiskerData(count).xPolyFit = double(xyPolyFitRot(:,1) + whiskerData(count).xBaseSmoothed);
    whiskerData(count).yPolyFit = double(xyPolyFitRot(:,2) + whiskerData(count).yBaseSmoothed);
    
    
end 

% Filter the basepoints for discontinuities in whisker length.
% Use threshold of 20% change in length.
tol = 0.2;
whiskerData = flagDiscontigFrames(whiskerData,tol);

% Filter the basepoints for erroneous whisker tracking by finding frames in
% which whisker is substantially longer than the extended whisker in
% "baseline" frame (i.e. first image in seq file).
tol = 0.2;
baseWhiskerX = whiskerData(1).x; baseWhiskerY = whiskerData(1).y;
whiskerData = flagWhiskerLengthViolationFrames(whiskerData,baseWhiskerX,baseWhiskerY,tol);

if ~isempty(manipData)
% Fit line segments to manipulator tracing data
manipData = fitManipLine(manipData);

% Find contact points between manipulator and whisker.
whiskerData = findContactPoints(whiskerData,manipData);
end

end % EOF
