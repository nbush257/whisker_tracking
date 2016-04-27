function wOut = smooth3DWhisker(wIn)
%% function wStruct_3DOut = smooth3DWhisker(wStruct_3D)
% takes a 3D whisker structure and smooths itusing loess smoothing. Should
% smooth out the basepoint and kinks.
% NB 2016_01_25
% Issue with row or column vectors. need to rewrite some other code to get
% the 3d struct back asa  column.
warning('This function has not been properly tested. Sanity checks are strongly encouraged')
wOut = wIn;

parfor ii = 1:length(wIn)
    % skip empty entries
    if isempty(wIn(ii).x)|isempty(wIn(ii).y)|isempty(wIn(ii).z)
        continue
    end
    % skip whiskers that are too short
    if length(wIn(ii).x)<10
        continue
    end
    if isrow(wIn(ii).x)
        try
            wOut(ii).y = smooth(wIn(ii).x,wIn(ii).y,'rlowess',.3);
            wOut(ii).z = smooth(wIn(ii).x,wIn(ii).z,'rlowess',.3);
%             f = fit([wIn(ii).x' wOut(ii).y],wIn(ii).z','lowess','Robust','LAR');
%             wOut(ii).z = feval(f,wIn(ii).x,wIn(ii).y)';
        catch
            disp('error')
        end
    else
        % removing the Robust option may speed it up, but may also be
        % ssusceptible to basepoint errors.
        try
            f = fit([wIn(ii).x wIn(ii).y],wIn(ii).z,'poly22');
            wOut(ii).z = feval(f,wIn(ii).x,wIn(ii).y);
        end
    end
    
    if mod(ii,1000) ==0
        fprintf('Frame\t%i\n',ii)
    end
    
end

