function wStruct = rmOutlierPts(wStruct)
for ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    end
    d = sqrt(cdiff(wStruct(ii).x).^2 + cdiff(wStruct(ii).y).^2);
    d = d-mean(d);
    toRm = d>4*std(d) | d<-4*std(d);
    wStruct(ii).x(toRm) = [];
    wStruct(ii).y(toRm) = [];
end