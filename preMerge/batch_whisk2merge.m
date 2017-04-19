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
    if exist([d(ii).name(1:29) 'toMerge.mat'],'file')
       continue
    end
    load(d(ii).name)
    whisk2merge_motor(tw,fw,frame_size,mask_struct,[d(ii).name(1:29) 'toMerge.mat']);
    clear mask_struct *W avi_* 
end

