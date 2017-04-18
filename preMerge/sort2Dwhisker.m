function w = sort2Dwhisker(w,direction)
%% function w = sort3Dwhisker(w)
% Sorts the whisker based on the x value, and makes all vectors column
% vectors.
% NEB
% direction is either 'x' or 'y'
%%
parfor ii = 1:length(w)
    if isempty(w(ii).x)
        continue
    end
    % make them column vectors
    w(ii).x = w(ii).x(:);
    w(ii).y = w(ii).y(:);
    
    switch direction
        case 'x'
            [w(ii).x,idx] = sort(w(ii).x);
            w(ii).y = w(ii).y(idx);
            
        case 'y'
            [w(ii).y,idx] = sort(w(ii).y);
            w(ii).x = w(ii).x(idx);
    end
end
