function [wOut,PP] = smooth3DWhisker(wIn,varargin)
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
%               the whisker by 10%. Default is 0.1
% OUTPUTS:
%           wOut - a 3D whisker structure that has been smoothed
% =======================================
% NB 2016_04_27
% Issue with row or column vectors. need to rewrite some other code to get
% the 3d struct back as a  column.
%% Input handling

numvargs = length(varargin);
% set defaults
optargs = {'spline', 4, 0.1};
% overwrite user supplied args
optargs(1:numvargs) = varargin;
[mode,numNodes,extend] = optargs{:};

wOut = wIn;
fprintf('Smoothing')
%% Loop over frames
parfor ii = 1:length(wIn)
    % skip empty entries
    if isempty(wIn(ii).x)|| isempty(wIn(ii).y) || isempty(wIn(ii).z)
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
                wOut(ii).y = smooth(wIn(ii).x,wIn(ii).y,'rlowess',.3);
                wOut(ii).z = smooth(wIn(ii).x,wIn(ii).z,'rlowess',.3);
            catch
                disp('error')
            end
            
        % implement splinefit smoothing
        case 'spline'     
            % prevent splinefit from being annoying
            warning('off')
            % make pts into row vectors for splinefit
            if iscolumn(wIn(ii).x)
                wIn(ii).x = wIn(ii).x';
                wIn(ii).y = wIn(ii).y';
                wIn(ii).z = wIn(ii).z';
            end
            PP(ii) = splinefit(wIn(ii).x,[wIn(ii).y;wIn(ii).z],numNodes,'r');
            xx = min(wIn(ii).x):.1:(max(wIn(ii).x))+abs(extend*max(wIn(ii).x));
            pts = ppval(PP,xx);
            wOut(ii).x = xx; 
            wOut(ii).y = pts(1,:);
            wOut(ii).y = pts(2,:);
            
            warning('on')
    end
    
    
    %% verbosity
    if mod(ii,round(length(wIn)/100)) == 0
        fprintf('.')
    end
    if mod(ii,round(length(wIn)/10)) == 0
        fprintf('\n')
    end
    
end % end parfor over frames

end

