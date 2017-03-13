clear
d = dir('*tracked.mat');
d_names = {d.name}

for ii = 1:length(d)
    load(d(ii).name,'*W')
    d_avi_front = dir([d(ii).name(1:27) '*Front*.avi']);
    d_avi_top = dir([d(ii).name(1:27) '*Top*.avi']);
    [tws,fws] = whisk2merge(tW,fW,d_avi_top(1).name,d_avi_front(1).name,[d(ii).name(1:27) 'toMerge.mat'])
    
end

