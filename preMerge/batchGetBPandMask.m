function batchGetBPandMask()
%% function batchGetBPandMask()
% ======================================
% this function iterates through a directory and does a UI to grab the mask
% and BP for all the tracked files in the directory. This will allow you to
% run the whisk2merge batch step without UI on an entire directory.
% ======================================
% NEB 20170313
%%

d = dir('*tracked.mat');

for ii = 1:length(d)
    %% extract the name of the first avi in the trial
    fprintf('Working on %s\n',d(ii).name)
    avi_name_front = [d(ii).name(1:end-11) '*Front*.avi'];
    avi_name_top = [d(ii).name(1:end-11) '*Top*.avi'];
    
    d_avi_front = dir(avi_name_front);
    d_avi_top = dir(avi_name_top);
    
    front_avi = d_avi_front(1).name;
    top_avi = d_avi_top(1).name;
    
    %% get a frame to use as an example
    v_f = VideoReader(front_avi);
    v_t = VideoReader(top_avi);
    
    If = read(v_f,round(v_f.numberOfFrames/2));
    It = read(v_t,round(v_t.numberOfFrames/2));
    
    %% run the UI functions
    warning('off')
    vars= load(d(ii).name,'mask_struct');
    warning('on')
    if isempty(fieldnames(vars))
        [mask_f,BP_f] = getMaskAndBP(If);
        [mask_t,BP_t] = getMaskAndBP(It);
        
        % put vars into a struct
        mask_struct.front = mask_f;
        mask_struct.top = mask_t;
        
        mask_struct.BP_f = BP_f;
        mask_struct.BP_t = BP_t;
    else
        mask_struct = vars.mask_struct;
        warning('Mask and BP already found in file %s',d(ii).name)
    end
    %% get the framesize
    clear frame_size
    frame_size.top = size(It);
    frame_size.front = size(If);

    
    %% save the outputs
    
    save(d(ii).name,'-append','mask_struct','front_avi','top_avi','frame_size')
end
