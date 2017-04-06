function whisk2merge_wrapper(fname)
addpath(genpath('/home/neb415/proc'));
cd /projects/p30054/tracked_2D
load(fname,'*W','frame_size','mask_struct');
whisk2merge(tW,fW,frame_size,mask_struct,[fname(1:end-11) 'toMerge.mat']);
end


