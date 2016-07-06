function wOut = interp3Dwhisker(wIn,varargin)
%% function wOut = interp3D(wIn,[n])
% ========================================
% Linearly interpolates in between the nodes of a 3D whisker struct
% fairly slow code.
% INPUTS:   wIn = a 3D whisker structure
%           n = number of interpolating points. Default = 10
% OUTPUTS:  wOut = a new 3D whisker structure with interpolated points
% ===========================================
% Nick Bush 2016_04_27
%% varargin handling
if length(varargin)>=1
    n = varargin(1);
else
    n = 10;
end
%% Main Loop
wOut = wIn;
fprintf('Interpolating')
parfor ii = 1:length(wIn) % loop over each frame
    % skip frames where there is no whisker or the whisker is short
    if isempty(wIn(ii).x) || length(wIn(ii).x)<10
        continue
    end
    % skip if a nan is found.
    if any(isnan(wIn(ii).x)) || any(isnan(wIn(ii).y))|| any(isnan(wIn(ii).z))
        continue
    end
    
    try
        x = wIn(ii).x;
        y = wIn(ii).y;
        z = wIn(ii).z;
        % init frame output
        xf_o = zeros((length(x)-1)*n,1);
        yf_o = zeros((length(x)-1)*n,1);
        zf_o = zeros((length(x)-1)*n,1);
        
        for jj = 1:length(x)-1   % loop over each node
            
            % calculate interpolation
            xf = linspace(x(jj),x(jj+1),n);
            yf = interp1([x(jj) x(jj+1)],[y(jj) y(jj+1)],xf);
            zf = interp1([x(jj) x(jj+1)],[z(jj) z(jj+1)],xf);
            
            % append to new vector
            xf_o((jj-1)*n+1:jj*n) = xf';
            yf_o((jj-1)*n+1:jj*n) = yf';
            zf_o((jj-1)*n+1:jj*n) = zf';
        end % end node loop
        
        % write output to structure
        wOut(ii).x = xf_o;
        wOut(ii).y = yf_o;
        wOut(ii).z = zf_o;
    catch 
        fprintf('error at frame %i\n',ii)
    end % end try
    
    %% verbosity
    if mod(ii,round(length(wIn)/100,1,'significant')) == 0
        fprintf('.')
    end
    if mod(ii,round(length(wIn)/10,1,'significant')) ==0
        fprintf('\n')
    end
    
end % end frame loop



