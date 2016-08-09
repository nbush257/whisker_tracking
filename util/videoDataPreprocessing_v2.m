function videoDataPreprocessing_v2()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run this file at the end of the day after recording whisker videos. This
% will copy all the seqs on D:\, E:\ and F:\ into a chosen path. Then chops
% them up into avis of a certain size [Default = 20000 frames]. Then traces the avi
% files and saves the .whiskers files. It then tryies to find the whisker
% using measure and reclassify (via batchMeasureTraces).
% -------------------------
% UPDATED:  Nick Bush 2015_12_03
% Written:  Nick Bush 2015_04_22
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step = 20000; % number of frames to save to each avi
% Get the files to convert


copyTGL = 0;convertTGL = 0; trackTGL = 0;
copyTGL = input('Do you want to copy the seqs somewhere? Will copy all seqs from D:,E:, and F:  (1/0)');
convertTGL = input('Do you want to convert Seqs into avis? (1/0)');
trackTGL = input('Do you want to track the whisker?');


step = 20000; % number of frames to save to each avi
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
%% Convert to full length avi

d = dir([seqPath '\*.seq']);
% remove calibration seqs from consideration
idx = [];
for ii = 1:length(d)
    if strfind(d(ii).name,'calib')
        idx = [idx ii];
    end
end
d(idx) = [];
numSeqs = length(d);

for ii = 1:numSeqs
    [~,aviName] = fileparts(d(ii).name);
    aviName = [aviName '.avi'];
    clestring = sprintf('clexport -i %s -f avi -cv 0 -o %s -ofs %s',[seqPath '\' d(ii).name],aviPath,aviName);
    system(clestring)
end
%% Split full into clips
dAvi = dir([aviPath '\*.avi'])
for ii = 1:length(dAvi)
    cd aviPath
    V = VideoReader(dAvi(ii).name);
    numFrames = V.numberOfFrames;
    bds = [1:step:numFrames numFrames];
    numClips = length(bds)-1;
    for jj = 1:numClips
        startFrame = bds(jj);
        endFrame = bds(jj+1)-1;
        if jj==numClips
            endFrame = endFrame+1;
        end
        fileOutName = sprintf([dAvi(ii).name(1:end-4) '_F%06iF%06i.avi'],firstFrame,lastFrame);
        outName = [aviPath '\' fileOutName];
        W = VideoWriter(outName,'Grayscale AVI');
        W.open;
        for kk = firstFrame:lastFrame
            I = read(V,kk);
            writeVideo(W,I);
        end
        W.close;
        close all force
    end
end
%% Run ffmppeg compression to reduce size of full length AVI which is no longer needed
if convertTGL
    error('this section needs to be debugged')
    cd(aviPath)
    for ii = 1:length(dAvi)
        outName  = [dAvi(ii).name(1:end-4) '_c.avi'];
        ffString = sprintf(['ffmpeg -i ' dAvi(ii).name ' -c:v  wmv2 -q 2  ' outName]);
        system(ffString)
        delete(dAvi(ii).name)        
    end
    newAvis = dir('*_c.avi');
    for ii = 1:length(newAvis)
        newOutname = newAvis(ii).name([1:end-6 end-3:end]);
        java.io.File(newAvis(ii).name).renameTo(java.io.File(newOutname));
    end
end
%% Trace Clips
avis = dir([aviPath '\*.avi']);
aviNames = {avis.name};
TAGidx = regexp(aviNames,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(aviNames)
    TAG{ii} = aviNames{ii}(1:TAGidx{ii}-1);
end
[TAGu,first] = unique(TAG);

if trackTGL
    %% Track
    ii=1;% initialize with the first whisker file
    
    wName = [whiskerPath '\' avis(ii).name(1:end-4) '.whiskers'];
    fprintf('tracing whiskers on %s',wName)
    system(['trace ' aviPath '\' avis(ii).name ' ' wName ' &']);
    pause(30)
    parfor ii = 2:length(avis)
        wName = [whiskerPath '\' avis(ii).name(1:end-4) '.whiskers'];
        fprintf('tracing whiskers on %s',wName)
        system(['trace ' aviPath '\' avis(ii).name ' ' wName ]);
    end
    %% Measure
    cd(aviPath)
    for ii = 1:length(TAGu)
        batchMeasureTraces(TAGu{ii},bp(ii,:),fol(ii),'v');
    end
end
%% Compress clips

error('this section needs to be debugged')
cd(aviPath)
for ii = 1:length(avis)
    outName  = [avis(ii).name(1:end-4) '_c.avi'];
    ffString = sprintf(['ffmpeg -i ' avis(ii).name ' -c:v  wmv2 -q 2  ' outName]);
    system(ffString)
    delete(avi(ii).name)
end
newAvis = dir('*_c.avi');
for ii = 1:length(newAvis)
    newOutname = newAvis(ii).name([1:end-6 end-3:end]);
    java.io.File(newAvis(ii).name).renameTo(java.io.File(newOutname));
end



