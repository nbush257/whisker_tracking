% create a lot of avis from one any number of seqs
function batchAviWriter()
%% function batchAviWriter()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------
% chops a seq up into a set of uncompressed avis of a length determined by
% the variable step [Default = 10,000]. Also applies an adapt histeq
% -------------------------------------------------
% INPUTS: None, UI selects a directory and loads in all seqs in that
% directory.
%
% OUTPUTS: Saves Uncompressed AVIs in the directory where the source seq
% was found.
% --------------------------------------------------
% Nick Bush 2015_04_17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step = 20000; % number of frames to save to each avi
loadPreference = input('load all seqs in a folder, or just one?[default=one] (one/all)','s')
% Get the files to convert
if strcmp(loadPreference,'all')
    pName = uigetdir('C:/','Where are the .seqs located?');
    d = dir([pName '\*.seq']);
else
    [fName,pName] = uigetfile('*.seq','Whish seq do you want to load?');
    d = dir([pName fName]);
end
numSeqs = length(d);


for ii = 1:numSeqs
    %% Iterate through all the .SEQs in the directory
    % get the info for the current .SEQ
    v = seqIo([pName '\' d(ii).name],'r');
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
        outName = [pName '\' fileOutName];
        w = VideoWriter(outName,'Motion JPEG AVI');
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
            I = adapthisteq(I);
            writeVideo(w,I);
        end % End frame writing
        w.close;
        delete waiter
    end % End clip Writing
end % End full .SEQ loop

