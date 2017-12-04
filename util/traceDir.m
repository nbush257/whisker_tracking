avi_path = pwd;
whisker_path = avi_path;
d = dir('*proc.avi');
parfor ii = 1:length(d)
    avi_name = d(ii).name;
    whiskers_name = [whisker_path '\' avi_name(1:end-4) '.whiskers'];
    if exist(whiskers_name,'file')
        continue
    end
    
    trace_string = sprintf('trace %s %s ',[avi_path '\' avi_name],whiskers_name);
    system(trace_string);
end

