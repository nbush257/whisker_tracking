function [tws,fws] = whisk2merge(tw,fw,tVidName,fVidName,outfilename)
%% function [tws,fws] = whisk2merge_v2(tw,fw,tVidName,fVidName,outfilename)
% takes relevant whisker and measurement file information to prepare the
% data for merging.
% ===========================================================
% INPUTS:
%       tw - the top tracked whisker struct
%       fw - the front tracked whisker struct
%       tVidName - the full file name of an avi from the top video. Used to
%          get the basepoint position so you can use any video from the set
%       fVidName - same as tVidName, but front
%       outfilename - filename where the ready to merge data goes.
%
% OUTPUTS:
%       tws - a smoothed version of the top whisker struct
%       fws - a smoothed version of the front whisker struct
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

frame_size_top = size(It);
frame_size_front = size(If);

assert(all(frame_size_top == frame_size_front),'Videos from Front camera and Top camera do not have the same frame size');
frame_size = frame_size_top;

%% Trim to the basepoint

[mask_t,BP_t] = getMaskAndBP(It);
close all force
[mask_f,BP_f] = getMaskAndBP(If);

fprintf('Trimming top basepoint...')
tws = applyMaskToWhisker(tw,mask_t);
[~,tws] = extendBP(tws,BP_t);
clear tW
fprintf('done.\n')
fprintf('Trimming Front basepoint...')
fws = applyMaskToWhisker(fw,mask_f);
[~,fws] = extendBP(fws,BP_f);
clear fW
fprintf('done.\n')
fprintf('saving...\n')
lastFinishedStep = 'bptrim';
% save(outfilename,'tws','fws','lastFinishedStep','frame_size');
close all
%% Smooth basepoint
fprintf('Smooth basepoint...\n')
warning('off')
[~,fws] = cleanBP(fws);
[~,tws] = cleanBP(tws);
warning('on')
fprintf('saving...\n')
lastFinishedStep = 'bpsmooth';
% save(outfilename,'-append','tws','fws','lastFinishedStep');

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
save(outfilename,'-v7.3','tws','fws','lastFinishedStep','frame_size');
fprintf('whisk2merge complete!\n')