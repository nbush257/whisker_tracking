function whisk2merge_wrapper(fname)
addpath(genpath('/home/neb415/proc'));
cd /projects/p30054/motor/
load(fname,'*W','frame_size','mask_struct');

try
whisk2merge(tW,fW,frame_size,mask_struct,[fname(1:end-11) 'toMerge.mat']);

catch err
fprintf('failure on file %s\n',fname)
rethrow(err)
end

end


