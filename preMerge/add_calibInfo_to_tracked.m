cd  /projects/p30054/tracked_2D
calib_folder = '/projects/p30054/calib';
d = dir('*2017_09*C4*toMerge.mat');
c_dir = dir([calib_folder '/*.mat']);
c_names = {c_dir.name};
for ii = 1:length(d)
    disp(d(ii).name)
    clear calibInfo
    try
        splits = regexp(d(ii).name,'_t\d\d_toMerge.mat','split');
        tag = splits{1};
        %     tag = d(ii).name(1:end-16);
        cal_idx = find(~cellfun(@isempty,(strfind(c_names,tag))));
        assert(~isempty(cal_idx),'No match in calib')
        load([calib_folder '/' c_dir(cal_idx).name]);
        save(d(ii).name,'-append','calibInfo')
    catch
        warning('error on %s',d(ii).name)
    end
    
    
end


