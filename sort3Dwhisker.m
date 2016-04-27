function w = sort3Dwhisker(w)

parfor ii = 1:length(w)
    if isempty(w(ii).x)
        continue
    end
    [w(ii).x,idx] = sort(w(ii).x);
    w(ii).y = w(ii).y(idx);
    w(ii).z = w(ii).z(idx);
end
