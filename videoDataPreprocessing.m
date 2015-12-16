% create a lot of avis from one any number of seqs
function videoDataPreprocessing()
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
    aviPath = uigetdir('C:/','Choose a path to save all avis.');
end
if trackTGL
    whiskerPath = uigetdir('C:/','Choose a path to save all .whiskers.');
end
%% Get bp and fol
if trackTGL
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
    
    bp = nan(numSeqs,2);
    fol = nan(numSeqs,1);
    for jj = 1:numSeqs
        
        
        V = seqIo([seqPath '\' d(jj).name],'r');
        V.seek(10000);
        img = V.getframe();
        imshow(img);ho
        title('Click on the center of the pad')
        bp(jj,:) = ginput(1);
        plotv(bp(jj,:),'g*');
        title('Click on the rightmost line that limits the follicle position')
        [fol(jj),~] = ginput(1);
        clf
    end
    ca
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
if convertTGL
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
    
    mkdir LQ
    parfor ii = 1:numSeqs
        %% Iterate through all the .SEQs in the directory
        % get the info for the current .SEQ
        v = seqIo([seqPath '\' d(ii).name],'r');
        info = v.getinfo();
        numFrames = info.numFrames;
        numClips = ceil(numFrames/step);
        fprintf('Working on seq %s: \t %i of %i \n',d(ii).name(1:end-4),ii,numSeqs)
        v.seek(0);
        lastFrame = 0;
        %% Iterate over each sub clip in a parallel loop
        for jj = 1:numClips
            % Prevents errors on the end of the .SEQ
            firstFrame = lastFrame+1;
            lastFrame = firstFrame+step-1;
            if lastFrame>numFrames
                lastFrame = numFrames;
            end
            
            fileOutName = sprintf([d(ii).name(1:end-4) '_F%06iF%06i.avi'],firstFrame,lastFrame);
            outName = [aviPath '\' fileOutName];
            wd = pwd;
            w = VideoWriter(outName,'Grayscale AVI');
            w.open;
            %% write each frame to the avi.
            % I don't think this can be a parallel loop because frame order
            % matters
            waiter = waitbar(0,['Converting clip ' num2str(jj) ' of ' num2str(numClips)]);
            for kk = firstFrame:lastFrame
                v.seek(kk-1);
                I = v.getframe();
                %                 I = imadjust(I);
                writeVideo(w,I);
            end % End frame writing
            w.close;
            close all force
        end % End clip Writing
    end % End full .SEQ loop
end

%% Run ffmppeg compression
if convertTGL
    avis = dir([aviPath '\*.avi']);
    cd(aviPath)
    for ii = 1:length(avis)
        ffString = sprintf(['ffmpeg -i ' avis(ii).name ' -c:v h263p -b:v 10000000 ' [avis(ii).name(1:end-4) '.mp4']]);
        system(ffString)
    end
end

%% Extract unique tags (i.e. from same expt regardless of frame number)
avis = dir([aviPath '\*.avi']);
aviNames = {avis.name};
TAGidx = regexp(aviNames,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(aviNames)
    TAG{ii} = aviNames{ii}(1:TAGidx{ii}-1);
end
[TAGu,first] = unique(TAG);

if trackTGL
    %% Choose the basepoints and follicle
    
    
    
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


