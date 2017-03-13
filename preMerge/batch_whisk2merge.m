%% batch_whisk2merge
% this script runs through all the files in the directory and does
% preprocess smoothing on them prior to the merge. This gets run after the
% batchgetBPandMask function
%%
clear
% get all the tracked files in the directory
d = dir('*tracked.mat');
d_names = {d.name};

for ii = 1:length(d)
    load(d(ii).name)
    whisk2merge(tW,fW,avi_top,avi_front,[d(ii).name(1:27) 'toMerge.mat'],mask_struct);
    clear mask_struct *W avi_* 
end

