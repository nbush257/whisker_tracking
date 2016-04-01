function wOut = smooth3DWhisker(wIn)
%% function wStruct_3DOut = smooth3DWhisker(wStruct_3D)
% takes a 3D whisker structure and smooths itusing loess smoothing. Should
% smooth out the basepoint and kinks. 
% NB 2016_01_25

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
    
    % removing the Robust option may speed it up, but may also be
    % ssusceptible to basepoint errors.
    f = fit([wIn(ii).x wIn(ii).y],wIn(ii).z,'loess','Robust','LAR');
    wOut(ii).z = feval(f,wIn(ii).x,wIn(ii).y);
end

