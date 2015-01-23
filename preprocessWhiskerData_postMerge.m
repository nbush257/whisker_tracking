function [whiskerData,xBase,yBase] = preprocessWhiskerData_postMerge(whiskerData,PT,useX,basepointSmaller,xTol,yTol)
% function [whiskerData,xBase,yBase] = preprocessWhiskerData(whiskerData,manipData,useX,basepointSmaller,xTol,yTol)
%
% This routine runs the whiskerData (from .whiskers file) through various
% pre-processing stages to clean up the data prior to 3D merging.m
%
% John Sheppard, 29 October 2014

%%  Declare vars
percent_base = 15;
%   Butterworth options
sampleRate = 250; lowCut = 0; highCut = 15;
%   Interp nodes
numNodes = 200;

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

% Add more points to whisker
 
for count = 1:length(whiskerData)
    xi = linspace(min(whiskerData(count).x),max(whiskerData(count).x),numNodes);
    yi = interp1(whiskerData(count).x,whiskerData(count).y,xi);
    whiskerData(count).xRaw = whiskerData(count).x;
    whiskerData(count).yRaw = whiskerData(count).y;
    whiskerData(count).x = xi;
    whiskerData(count).y = yi;
end

%{
% Remove duplicate frames from whisker data.
whiskerData = removeDuplicateFrames(whiskerData,'whisker');

if ~isempty(manipData)
% Remove duplicate frames from manipulator data.
manipData = removeDuplicateFrames(manipData,'manipulator');
end
%}

% Do an initial sort on x,y points of the whisker
for count = 1:length(whiskerData)
    
    %   JAE addition 141212
    %   replaces bad NaN whiskers with the previous whisker and flags them
    %   for removal
    if isnan(whiskerData(count).x(1))
        whiskerData(count).x=whiskerData(count-1).x;
        whiskerData(count).y=whiskerData(count-1).y;
        whiskerData(count).remvove=true;
    end
    
    [whiskerData(count).x,whiskerData(count).y] = sortWhisker(whiskerData(count).x,whiskerData(count).y,useX,basepointSmaller);
end


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

% whiskerData = trimWhiskerToBasepoint(whiskerData,xBase,yBase,tol,useX,basepointSmaller);

% Re-establish the median basepoint after trimming
%[whiskerData,xBase,yBase] = establishBasepoints(whiskerData,useX,basepointSmaller);

% Filter the basepoints to determine initial invalid frames.
whiskerData = filterBasepoints(whiskerData,xBase,yBase,xTol,yTol,useX,basepointSmaller);

% Smooth the basepoints to minimize tracking noise.
whiskerData = smoothBasepoints(whiskerData,useX,250,0,15);

% Recenter the whiskers to the smoothed basepoints.
for count = 1:length(whiskerData)
    [whiskerData(count).x,whiskerData(count).y] = sortWhisker(whiskerData(count).x,whiskerData(count).y,useX,basepointSmaller);
    xNudge = whiskerData(count).xBaseSmoothed - whiskerData(count).x(1);
    yNudge = whiskerData(count).yBaseSmoothed - whiskerData(count).y(1);
    
    whiskerData(count).x = double(whiskerData(count).x + xNudge);
    whiskerData(count).y = double(whiskerData(count).y + yNudge);
end
    
% Compute the slope of the whisker via linear regression of first 20 points from basepoint.
% slopeIndexes = 1:20; % use first 30 pts from basepoint to compute slope
% slopeIndexes = 1:40; % use first 30 pts from basepoint to compute slope
for count = 1:length(whiskerData)
    slopeIndexes = 1:floor(length(whiskerData(count).x)/(100/percent_base)); % use first XX percent from basepoint to compute slope
    if useX
        x = whiskerData(count).x; %thisBaseX = whiskerData(count).x(1);
        y = whiskerData(count).y; %thisBaseY = whiskerData(count).y(1);
    else % new x = - old y, new y = old x
        x = -whiskerData(count).y; %thisBaseX = -whiskerData(count).y(1);
        y = whiskerData(count).x; %thisBaseY = whiskerData(count).x(1);
    end
    betas = polyfit(x(slopeIndexes),y(slopeIndexes),1);
    whiskerData(count).whiskerSlopeRaw = betas(1);
    %     whiskerData(count).whiskerAngleRaw = atan(betas(1));
    
    TH(count) = get_TH(whiskerData(count).x,whiskerData(count).y,PT);
    whiskerData(count).whiskerAngleRaw = TH(count);
end

%% Process TH (from Process_BP_TH_v5.m)
TH_raw = TH;

% Look for outliers in TH --> Correct BP as well
% tmp = TH_raw;
% wrap TH about median
medth = median(TH);
thup = TH>(medth + 180);
TH(thup) = TH(thup) - 360;
thdn = TH<(medth - 180);
TH(thdn) = TH(thdn) + 360;


% remove NaN holes - still necessary?
warning('off', 'MATLAB:chckxy:IgnoreNaN');
TH_no_nan = spline(1:length(TH),TH,1:length(TH));
warning('on','MATLAB:chckxy:IgnoreNaN');

for ii = 1:length(TH)
    if isnan(TH(ii))
        TH(ii) = TH_no_nan(ii);
    end
end

% Smooth TH
TH_filt = bwfilt(TH,sampleRate,lowCut,highCut);

%%  Smooth the initial whisker segment angles temporally to reduce tracking noise.
whiskerAngles = [whiskerData.whiskerAngleRaw];
%whiskerAnglesSmoothed = bpfft(whiskerAngles,sampleRate,lowCut,highCut);
% whiskerAnglesSmoothed = bwfilt(double(whiskerAngles(:)),sampleRate,lowCut,highCut);

for count = 1:numel(whiskerData)
    whiskerData(count).whiskerAngleTarget = TH_filt(count);
end

% Rotate the whiskers based on the smoothed initial whisker segment slopes.
for count = 1:numel(whiskerData)
    
        x = whiskerData(count).x; thisBaseX = whiskerData(count).x(1);
        y = whiskerData(count).y; thisBaseY = whiskerData(count).y(1);

   % Subtract x(1) and y(1) from x/y vectors so that basepoint becomes the
   % origin of coordinate system.
   whiskerX = x - thisBaseX; %whiskerData(count).x(1); 
   whiskerY = y - thisBaseY; %whiskerData(count).y(1);
   
   angleNudge = (whiskerData(count).whiskerAngleTarget - whiskerData(count).whiskerAngleRaw)*(pi/180);    % in radians
   rotWhiskerXY = brotate([whiskerX(:),whiskerY(:)],-angleNudge);
   
   whiskerData(count).xRaw = whiskerData(count).x;
   whiskerData(count).yRaw = whiskerData(count).y;
 
   %% Add basepoints back on after rotation.
   whiskerData(count).x = double(rotWhiskerXY(:,1) + whiskerData(count).x(1));
   whiskerData(count).y = double(rotWhiskerXY(:,2) + whiskerData(count).y(1)); 

end

% THIS IS FOR CHECKING THAT WE SUCCESFULLY SMOOTEHD THE WHISKERS
for count = 1:numel(whiskerData)
    TH_adjusted(count) = get_TH(whiskerData(count).x,whiskerData(count).y,PT);
    whiskerData(count).whiskerAngleAdj = TH_adjusted(count);
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

%{
if ~isempty(manipData)
% Fit line segments to manipulator tracing data
manipData = fitManipLine(manipData);

% Find contact points between manipulator and whisker.
whiskerData = findContactPoints(whiskerData,manipData);
end
%}

end % EOF
