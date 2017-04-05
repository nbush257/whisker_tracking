%% batch_whisk2merge
% this script runs through all the files in the directory and does
% preprocess smoothing on them prior to the merge. This gets run after the
% batchgetBPandMask function
%%
clear
% get all the tracked files in the directory
d = dir('*tracked.mat');
d_names = {d.name};
unfinished = false(length(d),1);
for ii = 1:length(d)
    try
    load(d(ii).name,'*W','frame_size','mask_struct')

    whisk2merge(tW,fW,frame_size,mask_struct,[d(ii).name(1:27) 'toMerge.mat']);
    catch
        warning('Error on file %s. Skipping',d(ii).name)
        unfinished(ii)=1;
    end
    
    clear mask_struct *W frame_size mask_struct
    save('unfinished_trials.mat','d','unfinished')
end

