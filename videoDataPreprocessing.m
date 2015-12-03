% create a lot of avis from one any number of seqs
function videoDataPreprocessing()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run this file at the end of the day after recording whisker videos. This
% will copy all the seqs on D:\, E:\ and F:\ into a chosen path. Then chops
% them up into avis of a certain size [Default = 20000 frames] with some
% image processing. Then traces the avi files and saves the .whiskers files
% using whisk.
% -------------------------
% Nick Bush 2015_04_22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step = 20000; % number of frames to save to each avi
% Get the files to convert

seqPath = uigetdir('C:/','Choose a path to backup all seqs.');
aviPath = uigetdir('C:/','Choose a path to save all avis.');
whiskerPath = uigetdir('C:/','Choose a path to save all .whiskers.');

% Data management post acquisition

dRaw = dir('D:\*.seq');
eRaw = dir('E:\*.seq');
fRaw = dir('F:\*.seq');
% 
% for ii = 1:length(dRaw)
%     fprintf('Copying %s to %s \n',['D:\' dRaw(ii).name],[seqPath '\' dRaw(ii).name])
%     copyfile(['D:\' dRaw(ii).name],[seqPath '\' dRaw(ii).name]);
%     
% end
% for ii = 1:length(eRaw)
%     fprintf('Copying %s to %s \n',['E:\' eRaw(ii).name],[seqPath '\' eRaw(ii).name])
%     copyfile(['E:\' eRaw(ii).name],[seqPath '\' eRaw(ii).name]);
%     
% end
% for ii = 1:length(fRaw)
%     fprintf('Copying %s to %s \n',['F:\' fRaw(ii).name],[seqPath '\' fRaw(ii).name])
%     copyfile(['F:\' fRaw(ii).name],[seqPath '\' fRaw(ii).name]);
%     
% end

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
        w = VideoWriter(outName,'Motion JPEG AVI');
        w.Quality = 95;
        w.open;
        %% write each frame to the avi.
        % I don't think this can be a parallel loop because frame order
        % matters
        waiter = waitbar(0,['Converting clip ' num2str(jj) ' of ' num2str(numClips)]);
        for kk = firstFrame:lastFrame
            progress = ((kk-firstFrame)/(lastFrame-firstFrame));
            waitbar(progress,waiter)
            v.seek(kk-1);
            I = v.getframe();
%             I = imadjust(I);
            writeVideo(w,I);
        end % End frame writing
        w.close;
        close all force
    end % End clip Writing
end % End full .SEQ loop
cd C:\Users\guru\Documents\proc\whiskerTracking

avis = dir([aviPath '\*.avi']);
ii=1;

wName = [whiskerPath '\' avis(ii).name(1:end-4) '.whiskers'];
fprintf('tracing whiskers on %s',wName)
system(['trace ' aviPath '\' avis(ii).name ' ' wName ' &']);
pause(60)
parfor ii = 1:length(avis)
    wName = [whiskerPath '\' avis(ii).name(1:end-4) '.whiskers'];
    fprintf('tracing whiskers on %s',wName)
    system(['trace ' aviPath '\' avis(ii).name ' ' wName]);
end



