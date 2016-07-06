function smoothed = smooth2Dwhisker(wStruct,varargin)
%% function smoothed = smooth2D_whisker(wStruct,[method],[extend])
% =============================================
% Smooths each frame of a 2D whisker struct. Can use either splinefit or
% robust lowess smoothing.
% =============================================
% INPUTS:
%           wStruct - a whisker structure that comes from Clack's "whisk"
%               software
%           [method] - chooses which type of smoothing to use. Defaults to
%               "splinefit". Paramters of the smoothing are hardcoded currenly, but
%               should be made to be driven by arguments. Valid arguments
%               are:
%                   -splinefit
%                   -linear
%
%           [extend] - how much should the whisker be extended if we use
%              splinefit. (e.g. 0.1 means a 10% extension) Defaults to 0 (no
%              extension)
% OUTPUTS:
%           smoothed - a whisker structure of same size/length as the input
%               wStruct, but the xy points have been smoothed
% ==============================================
% NEB 2016. Commented and refactored 2016_07_06
%% Input handling

narginchk(1,3)
numvargs = length(varargin);
optargs = {'splinefit',0};
optargs(1:numvargs) = varargin;
[method,extend] = optargs{:};
%% Init ouptut
smoothed = wStruct;

%% smooth in a parallel loop over each frame.
parfor ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    end
    
    switch method
        case 'linear'
            smoothed(ii).x = wStruct(ii).x(1):wStruct(ii).x(end);
            smoothed(ii).y = smooth(wStruct(ii).x,wStruct(ii).y,'lowess',15);
        case 'splinefit'
            PP = splinefit(double(wStruct(ii).x),double(wStruct(ii).y),6,'r');
            xx = min(wStruct(ii).x):.1:(max(wStruct(ii).x))+abs(extend*max(wStruct(ii).x));
            yy = ppval(PP,xx);
            smoothed(ii).x = xx;
            smoothed(ii).y = yy;
        otherwise
            error('Not a valid smoothing mode')
    end
    
end