function [tws,fws] = whisk2merge(tw,twM,fw,fwM,tVidName,fVidName,outfilename)
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
tVid = VideoReader(tVidName);
fVid = VideoReader(fVidName);
It = read(tVid,20000);
If = read(fVid,20000);
%% Trim to the basepoint
fprintf('Trimming top basepoint...')
[tBP,tws] = extendBP(tw,It);
fprintf('done.\n')
fprintf('Trimming Front basepoint...')
[fBP,fws] = extendBP(fw,If);
fprintf('done.\n')
fprintf('saving...\n')
lastFinishedStep = 'bptrim';
save(outfilename,'tws','fws','twM','fwM','lastFinishedStep');
close all
%% Smooth basepoint
fprintf('Smooth basepoint...\n')
[fBP,fws] = cleanBP(fws);
[tBP,tws] = cleanBP(tws);
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
save(outfilename,'-append','tws','fws','lastFinishedStep');
