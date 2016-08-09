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
% % remove calibration seqs from consideration
% idx = [];
% for ii = 1:length(d)
%     if strfind(d(ii).name,'calib')
%         idx = [idx ii];
%     end
% end
% d(idx) = [];
numSeqs = length(d);

for ii = 1:numSeqs
    [~,aviName] = fileparts(d(ii).name);
    aviName = [aviName '.avi'];
    clestring = sprintf('clexport -i %s -f avi -cv 0 -tos 0 -o %s -of %s &',[seqPath '\' d(ii).name],aviPath,aviName);
    system(clestring)
end
%% Split full into clips
dAvi = dir([aviPath '\*.avi'])
for ii = 1:length(dAvi)
    cd(aviPath)
    numFrames = V.numberOfFrames;
    bds = [1:step:numFrames numFrames];
    numClips = length(bds)-1;
    parfor jj = 1:numClips
        V = VideoReader(dAvi(ii).name);

        startFrame = bds(jj);
        endFrame = bds(jj+1)-1;
        if jj==numClips
            endFrame = endFrame+1;
        end
        fileOutName = sprintf([dAvi(ii).name(1:end-4) '_F%06iF%06i.avi'],startFrame,endFrame);
        outName = [aviPath '\' fileOutName];
        W = VideoWriter(outName,'Grayscale AVI');
        W.open;
        for kk = startFrame:endFrame
            if mod(kk,500)==0
                fprintf('Frame %06d of %06d on clip %d',kk,numFrames,numClips)
            end
            I = read(V,kk);
            writeVideo(W,I);
        end
        W.close;
        close all force
    end
end
%% Run ffmppeg compression to reduce size of full length AVI which is no longer needed
if convertTGL
    cd(aviPath)
    parfor ii = 1:length(dAvi)
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
avis = dir([aviPath '\*F*F*.avi']);
aviNames = {avis.name};
TAGidx = regexp(aviNames,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(aviNames)
    TAG{ii} = aviNames{ii}(1:TAGidx{ii}-1);
end
[TAGu,first] = unique(TAG);

if trackTGL
    cd(aviPath)
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
end
%% Compress clips

for ii = 1:length(avis)
    outName  = [avis(ii).name(1:end-4) '_c.avi'];
    ffString = sprintf(['ffmpeg -i ' avis(ii).name ' -c:v  wmv2 -q 2  ' outName]);
    system(ffString)
    delete(avis(ii).name)
end
newAvis = dir('*_c.avi');
for ii = 1:length(newAvis)
    newOutname = newAvis(ii).name([1:end-6 end-3:end]);
    java.io.File(newAvis(ii).name).renameTo(java.io.File(newOutname));
end
%% 
%% get BP and Fol
if trackTGL
    for jj = 1:dAvi
        V = VideoReader(dAvi(ii).name)
        img = read(V,100000);
        imshow(img);hold on
        title('Click on the center of the pad')
        bp(jj,:) = ginput(1);
        plotv(bp(jj,:),'g*');
        title('Click on the rightmost line that limits the follicle position')
        [fol(jj),~] = ginput(1);
        clf
    end
    
    for ii = 1:length(TAGu)
        batchMeasureTraces(TAGu{ii},bp(ii,:),fol(ii),'v');
    end
    
end
%% Combine whiskers
tops = dir('*Top*F000001*.whiskers');
fronts = dir('*Front*F000001*.whiskers');
for ii = 1:length(tops)
    [tW,tM] = combineWhiskers(tops(ii).name,0);
    [fW,fM] = combineWhiskers(fronts(ii).name,0);
    outFileName = regexp(tops(ii).name,'Top','split');
    outFileName = [outFileName{1} 'tracked.mat'];
    save(outFileName,'tW','fW','tM','fM')
end

    
    
        


