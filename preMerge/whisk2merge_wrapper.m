function whisk2merge_wrapper(fname)
load(fname,'*W','frame_size','mask_struct')
whisk2merge(tW,fW,frame_size,mask_struct,[d(ii).name(1:27) 'toMerge.mat']);
end


