function [fws,tws] = whisk2merge(fw,tw,frame_size,mask_struct,outfilename)
%% function [tws,fws] = whisk2merge_v2(fw,tw,tVidName,fVidName,mask_struct,outfilename)
% takes relevant whisker and measurement file information to prepare the
% data for merging.
% ===========================================================
% INPUTS:
%       tw - the top tracked whisker struct
%       fw - the front tracked whisker struct
%       frame_size - size of the video
%       mask_struct - contains the information about the mask and BP for both views
%           fields: mask_f, mask_t, BP_f, BP_t
%       outfilename - filename where the ready to merge data goes.
%
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
%% Trim to the basepoint

fprintf('Trimming top basepoint...')
tws = applyMaskToWhisker(tw,mask_struct.top);
[~,tws] = extendBP(tws,mask_struct.BP_t);
clear tw
fprintf('done.\n')

fprintf('Trimming Front basepoint...')
fws = applyMaskToWhisker(fw,mask_struct.front);
[~,fws] = extendBP(fws,mask_struct.BP_f);
clear fw
fprintf('done.\n')

close all
%% Smooth basepoint
fprintf('Smooth basepoint...\n')
warning('off')
[~,fws] = cleanBP(fws);
[~,tws] = cleanBP(tws);
warning('on')

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