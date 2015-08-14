function wStruct = sortWhisker(wStruct)
for ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    end
    [~,i] = sort(wStruct(ii).x);
    wStruct(ii).x = wStruct(ii).x(i);
    wStruct(ii).y = wStruct(ii).y(i);
end

