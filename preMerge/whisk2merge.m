function [tws,fws] = whisk2merge(tw,fw,tVidName,fVidName,outfilename)
%% function [tws,fws,C] = whisk2merge_v2(tw,twM,fw,fwM,tVidName,fVidName,outfilename)
% takes relevant whisker and measurement file information to prepare the
% data for merging.
% ===========================================================
% INPUTS:
%       tw - the top tracked whisker struct
%       twM - the top tracked measurement struct
%       fw - the front tracked whisker struct
%       fwM - the front tracked measurement struct
%       tVidName - the full file name of an avi from the top video. Used to
%          get the basepoint position so you can use any video from the set
%       fVidName - same as tVidName, but front
%       outfilename - filename where the ready to merge data goes.
%
% OUTPUTS:
%       tws - a smoothed version of the top whisker struct
%       fws - a smoothed version of the front whisker struct
%       C - a contact biniary
% ==========================================================
% NEB 2016 Commented and refactoring 2016_07_06
%% 
lastFinishedStep = '';
close all
% start parallel pool if not running
gcp;
% get representative images
[~,~,extT] = fileparts(tVidName);
[~,~,extF] = fileparts(fVidName);

assert(strcmp(extT,extF),'Video files are not the same type');

switch extT
    case '.avi'
        tVid = VideoReader(tVidName);
        fVid = VideoReader(fVidName);
        nFramesT = tVid.numberOfFrames;
        nFramesF = fVid.numberOfFrames;
        assert(nFramesT==nFramesF,'Number of frames is inconsistent')
        
        It = read(tVid,round(nFramesT/2));
        If = read(fVid,round(nFramesT/2));
        
    case '.seq'
        tVid = seqIo(tVidName,'r');
        fVid = seqIo(fVidName,'r');
        nFramesT = tVid.numFrames;
        nFramesF = fVid.numFrames;
        assert(nFramesT==nFramesF,'Number of frames is inconsistent')
        tVid.seek(round(nFramesT/2));
        fVid.seek(round(nFramesT/2));
        It = tVid.getframe();
        If = fVid.getframe();
end


%% Trim to the basepoint
fprintf('Trimming top basepoint...')
tws = applyMaskToWhisker(It,tw);
[~,tws] = extendBP(tws,It);
clear tW
fprintf('done.\n')
fprintf('Trimming Front basepoint...')
fws = applyMaskToWhisker(If,fw);
[~,fws] = extendBP(fws,If);
clear fW
fprintf('done.\n')
fprintf('saving...\n')
lastFinishedStep = 'bptrim';
save(outfilename,'tws','fws','lastFinishedStep');
close all
%% Smooth basepoint
fprintf('Smooth basepoint...\n')
warning('off')
[fBP,fws] = cleanBP(fws);
[tBP,tws] = cleanBP(tws);
warning('on')
fprintf('saving...\n')
lastFinishedStep = 'bpsmooth';
save(outfilename,'-append','tws','fws','lastFinishedStep');

%% Smooth whisker shape
% this step takes forever
fprintf('Smoothing the top whisker...\n')
tic
tws = smooth2Dwhisker(tws);
toc
fprintf('Smoothing the front whisker...\n')
tic
fws = smooth2Dwhisker(fws);
toc
lastFinishedStep = 'whisker_smooth';
fprintf('Saving last step...\n')
save(outfilename,'-append','tws','fws','lastFinishedStep');
fprintf('whisk2merge complete!\n')