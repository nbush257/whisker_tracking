% paralle whisker tracing
loadPath = uigetdir('C:/','where are the avis to read?');
sPath = uigetdir('C:/','Where do you want to save the whiskers?');

dLoad = dir([loadPath '\*.avi']);
dSave = dir([sPath '\*.whiskers']);
ignore = [];
for ii = 1:length(dLoad)
    saveName = [sPath '\' dLoad(ii).name(1:end-4) '_noClass.whiskers'];
    if exist(saveName,'file')
        ignore =[ignore ii];
    end
end
dLoad(ignore) = [];

ii=1;
saveFullName = [sPath '\' dLoad(ii).name(1:end-4) '_noClass.whiskers'];
system(['trace ' loadPath '\' dLoad(ii).name ' ' saveFullName ' &'])

parfor ii=2:length(dLoad)
    saveFullName = [sPath '\' dLoad(ii).name(1:end-4) '_noClass.whiskers'];
    system(['trace ' loadPath '\' dLoad(ii).name ' ' saveFullName ])
end


