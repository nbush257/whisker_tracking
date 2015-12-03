function wStruct = sortWhisker(wStruct)
%% wStruct = sortWhisker(wStruct)
warning('I don''t think this is good code. Sanity checks are needed')   
% This function sorts the whisker points by ascending x value.
% I think this can be improved.
for ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    end
    [~,i] = sort(wStruct(ii).x);
    wStruct(ii).x = wStruct(ii).x(i);
    wStruct(ii).y = wStruct(ii).y(i);
end

