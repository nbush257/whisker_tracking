function toMerge_QC(fname)
load(fname)
disp(fname)
try
    assert(exist('tws'),'tws does not exist');
    assert(exist('fws'),'fws does not exist');
    assert(exist('frame_size'),'frame_size does not exist');
catch
    % delete the toMerge file
end
try 
    t_fields = fieldnames(tws);
    assert(length(t_fields)==6, 'incomplete tws structure');
    
    f_fields = fieldnamed(fws);
    assert(length(f_fields)==6, 'incomplete fws structure');
catch 
    %delete the toMerge file
end

try 
   assert(length(fws)==length(tws),'fws and tws are not the same size');
end


    
    
    