function [smoothed,PP] = smooth2Dwhisker(wStruct,varargin)
%% function smoothed = smooth2D_whisker(wStruct,[method],[direction],[extend])
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
%           [direction] - use 'v' if the whisker is mainly vertical.
%           Otherwise defaults to horizontal
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
optargs = {'linear','h',0};
optargs(1:numvargs) = varargin;
[method,direction,extend] = optargs{:};

if strcmp(method,'splinefit')
    warning('Splinefit will tend to mis-track the basepoint. Proceed at own risk')
end


% Minimum number of nodes that the whisker has. Cannot smooth with less
% than a certain number. Removes all tracked points from this frame
lenThresh = 10;
%% Init ouptut
smoothed = wStruct;
PP(length(wStruct)+1) = splinefit(1:10,1:10,6,'r');
% PP = PP(length(wStruct));

%% smooth in a parallel loop over each frame.
parfor ii = 1:length(wStruct)
    if isempty(wStruct(ii).x) || length(wStruct(ii).x)<lenThresh
        smoothed(ii).x = [];
        smoothed(ii).y = [];
        continue
    end
    
    switch method
        case 'linear'
            switch direction
                case 'v'
                    smoothed(ii).y = wStruct(ii).y;
                    smoothed(ii).x = single(smooth(wStruct(ii).y,wStruct(ii).x,'lowess',15));
                    smoothed(ii).y = smoothed(ii).y(:);
                    smoothed(ii).x = smoothed(ii).x(:);
                otherwise
                    smoothed(ii).x = wStruct(ii).x;
                    smoothed(ii).y = single(smooth(wStruct(ii).x,wStruct(ii).y,'lowess',15));
                    smoothed(ii).x = smoothed(ii).x(:);
                    smoothed(ii).y = smoothed(ii).y(:);
            end
        case 'splinefit'
            PP(ii) = splinefit(double(wStruct(ii).x),double(wStruct(ii).y),6,'r');
            xx = min(wStruct(ii).x):.5:(max(wStruct(ii).x))+abs(extend*max(wStruct(ii).x));
            yy = ppval(PP(ii),xx);
            smoothed(ii).x = xx;
            smoothed(ii).y = yy;
        otherwise
            error('Not a valid smoothing mode')
    end
    
end
