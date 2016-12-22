%% videoDataPreprocessing_v3
% Run this file at the end of the day after recording whisker videos. This
% will copy all the seqs on D:\, E:\ and F:\ into a chosen path. Then chops
% them up into avis of a certain size [Default = 20000 frames]. Then traces the avi
% files and saves the .whiskers files. It then tryies to find the whisker
% using measure and reclassify (via batchMeasureTraces).
% ========================================================
% Split into chunks as compared to v2. Unstable as of 2016_08_10
step = 20000;


copyTGL = 0;convertTGL = 0; trackTGL = 0;
copyTGL = input('Do you want to copy the seqs somewhere? Will copy all seqs from D:,E:, and F:  (1/0)');
convertTGL = input('Do you want to convert Seqs into avis? (1/0)');
trackTGL = input('Do you want to track the whisker?');

% Get the files to convert
seqPath = uigetdir('C:/','Choose a path to backup all seqs.');

if convertTGL | trackTGL
    aviPath = uigetdir(seqPath,'Choose a path to save all avis and .whiskers');
end

if trackTGL
    whiskerPath = aviPath;
end
%% Copy files to External
if copyTGL
    dRaw = dir('D:\*.seq');
    eRaw = dir('E:\*.seq');
    fRaw = dir('F:\*.seq');
    
    for ii = 1:length(dRaw)
        fprintf('Copying %s to %s \n',['D:\' dRaw(ii).name],[seqPath '\' dRaw(ii).name])
        copyfile(['D:\' dRaw(ii).name],[seqPath '\' dRaw(ii).name]);
        
    end
    for ii = 1:length(eRaw)
        fprintf('Copying %s to %s \n',['E:\' eRaw(ii).name],[seqPath '\' eRaw(ii).name])
        copyfile(['E:\' eRaw(ii).name],[seqPath '\' eRaw(ii).name]);
        
    end
    for ii = 1:length(fRaw)
        fprintf('Copying %s to %s \n',['F:\' fRaw(ii).name],[seqPath '\' fRaw(ii).name])
        copyfile(['F:\' fRaw(ii).name],[seqPath '\' fRaw(ii).name]);
        
    end
end
%% convert full length seq to avi
if converTGL
    d = dir([seqPath '\*.seq']);
    numSeqs = length(d);
    
    for ii = 1:numSeqs
        [~,aviName] = fileparts(d(ii).name);
        aviName = [aviName '.avi'];
        clestring = sprintf('clexport -i %s -f avi -cv 0 -tos 0 -o %s -of %s &',[seqPath '\' d(ii).name],aviPath,aviName);
        system(clestring)
    end
end
%% Split full length into clips

% get list of full length avis without calibrations
dAvi = dir([aviPath '\*.avi'])
idx = [];
for ii = 1:length(dAvi)
    if strfind(dAvi(ii).name,'calib')
        idx = [idx ii];
    end
end
dAvi(idx) = [];

splitAvi2Clips(dAvi);
%% compress full length avis
if convertTGL
    compressClips(dAvi);
end
%% trace clips
if trackTGL
    TAGu = traceClips(aviPath);
end
%% Compress clips
if convertTGL
    avis = dir([aviPath '\*F*F*.avi']);
    compressClips(avis);
end
%% Measure
if trackTGL
    measureClips(avis,TAGu);
end
%% Combine outputs
cd(aviPath)
tops = dir('*Top*F000001*.whiskers');
fronts = dir('*Front*F000001*.whiskers');
for ii = 1:length(tops)
    [tW,tM] = combineWhiskers(tops(ii).name,0);
    [fW,fM] = combineWhiskers(fronts(ii).name,0);
    outFileName = regexp(tops(ii).name,'Top','split');
    outFileName = [outFileName{1} 'tracked.mat'];
    save(outFileName,'tW','fW','tM','fM')
end



