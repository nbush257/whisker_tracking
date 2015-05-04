clear
d = dir('C:\Users\guru\Documents\data\*preMerge*.mat')
for file = 1:length(d)
    
    load(['C:\Users\guru\Documents\data\' d(file).name]);
    tracked_3D_fileName = ['D:\data\' d(file).name(1:end-13) '_tracked_3D.mat'];
    mergeLoop
    clear
end
