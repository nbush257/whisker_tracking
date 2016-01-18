function smoothed = smooth2D_whisker(wStruct)
%% function smoothed = smooth2D_whisker(wStruct)
% Apply robust loess smoothing to each 2D whisker.
smoothed = wStruct;
% h = waitbar(0,'Smoothing 2D whisker');
parfor ii = 1:length(wStruct)
%     waitbar(ii/length(wStruct),h,'Smoothing 2D whisker')
    if isempty(wStruct(ii).x)
        continue
    end
    smoothed(ii).x = wStruct(ii).x;
    smoothed(ii).y = smooth(wStruct(ii).x,wStruct(ii).y,'loess');
end
% close all force