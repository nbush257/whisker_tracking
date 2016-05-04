function w = sort3Dwhisker(w)
% Sorts the whisker based on the x value, and makes all vectors column
% vectors.
parfor ii = 1:length(w)
    if isempty(w(ii).x)
        continue
    end
    if isrow(w(ii).x)
        [w(ii).x,idx] = sort(w(ii).x');
        w(ii).y = w(ii).y(idx)';
        w(ii).z = w(ii).z(idx)';
    else
        
        [w(ii).x,idx] = sort(w(ii).x);
        w(ii).y = w(ii).y(idx);
        w(ii).z = w(ii).z(idx);
    end
    
end
