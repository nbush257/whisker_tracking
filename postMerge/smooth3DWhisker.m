function [wOut,coefs] = smooth3DWhisker(wIn,varargin)
%% function wStruct_3DOut = smooth3DWhisker(wStruct_3D,[mode],[numNodes],[extend])
% ========================================
% takes a 3D whisker structure and smooths it. Should
% smooth out the basepoint and kinks. Can operate in either splinefit mode
% or lowess mode.
%
% Splinefit mode offers advantages of being faster, and being able to extend
% and interpolate the whisker. However, it assumes that x points are
% sorted as ascending in the x coordinate. If this is not true, then it
% will extend the basepoint.
%
% Lowess is slower, but also doesn't compensate the whisker shape as easily
% as splinefit.
%
% =======================================
% INPUTS:
%           wIn - a 3D whisker structure.

%           [mode] - a string either 'spline' or 'linear'. Default is
%           'spline'

%           [numNodes] - optional number for spline input. Gets ignored if
%               mode is linear. Default is 4

%           [extend] - Tells splinefit how much to extend the whisker by
%               (as a percentage of the x coordinate extent). e.g. .1 extends
%               the whisker by 10%. Default is 0.0
% OUTPUTS:
%           wOut - a 3D whisker structure that has been smoothed
% =======================================
% NB 2016_04_27
% Issue with row or column vectors. need to rewrite some other code to get
% the 3d struct back as a  column.
gcp;
%% Input handling
numvargs = length(varargin);
% set defaults
optargs = {'spline', 4, 0.0};
% overwrite user supplied args
optargs(1:numvargs) = varargin;
[mode,numNodes,extend] = optargs{:};
coefs = nan(length(wIn),2*numNodes^2);
wOut = wIn;
fprintf('Smoothing using method: %s\n',mode)
if strcmp(mode,'spline');fprintf('\t Num Nodes: %i\n',numNodes);end
pause(.1)
%% Loop over frames
parfor ii = 1:length(wIn)
    
    xIn = wIn(ii).x;
    yIn = wIn(ii).y;
    zIn = wIn(ii).z;
    % skip empty entries
    if isempty(xIn)|| isempty(yIn) || isempty(zIn)
        continue
    end
    
    % skip whiskers that are too short
    if length(wIn(ii).x)<10
        continue
    end
    
    % smooth the whisker
    switch mode
        
        % implement robust lowess smoothing
        case 'linear'
            try
                wOut(ii).y = smooth(wIn(ii).x,wIn(ii).y,'rlowess',0.25);
                wOut(ii).z = smooth(wIn(ii).x,wIn(ii).z,'rlowess',0.25);
            catch
                disp('error')
            end
            
            % implement splinefit smoothing
        case 'spline'
            % prevent splinefit from being annoying
            warning('off')
            % make pts into row vectors for splinefit
            if iscolumn(wIn(ii).x)
                xIn = xIn';
                yIn = yIn';
                zIn = zIn';
            end
            PP = splinefit(xIn(1:end-2),[yIn(1:end-2);zIn(1:end-2)],numNodes,.5,'r');
            %             coefs(ii,:) = PP.coefs(:);
            xx = min(wIn(ii).x):.5:(max(wIn(ii).x))+abs(extend*max(wIn(ii).x));
            pts = ppval(PP,xx);
            step = median(diff(xx));
            
            wOut(ii).x = xx;
            wOut(ii).y = pts(1,:);
            wOut(ii).z = pts(2,:);
            
            warning('on')
        otherwise
            error('not a method')
            
    end
    
    
    %% verbosity
    %     if mod(ii,round(length(wIn)/100)) == 0
    %         fprintf('.')
    %     end
    %     if mod(ii,round(length(wIn)/10)) == 0
    %         fprintf('\n')
    %     end
    
end % end parfor over frames

end

