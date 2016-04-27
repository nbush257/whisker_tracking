function wOut = smooth3DWhisker(wIn)
%% function wStruct_3DOut = smooth3DWhisker(wStruct_3D)
% ========================================
% takes a 3D whisker structure and smooths it using lowess smoothing. Should
% smooth out the basepoint and kinks.
% =======================================
% INPUTS:
%           wIn - a 3D whisker structure.
% OUTPUTS:
%           wOut - a 3D whisker structure that has been smoothed
% =======================================
% NB 2016_04_27
% Issue with row or column vectors. need to rewrite some other code to get
% the 3d struct back as a  column.
wOut = wIn;
fprintf('Smoothing')
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
    try
        wOut(ii).y = smooth(wIn(ii).x,wIn(ii).y,'rlowess',.3);
        wOut(ii).z = smooth(wIn(ii).x,wIn(ii).z,'rlowess',.3);
    catch
        disp('error')
    end
    
    %% verbosity
    if mod(ii,round(length(wIn)/100)) == 0
        fprintf('.')
    end
    if mod(ii,round(length(wIn)/10)) ==0
        fprintf('\n')
    end
    
end % end parfor over frames

end

