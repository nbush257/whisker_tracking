function [tws,fws] = whisk2merge_motor(tw,fw,frame_size,mask_struct,outfilename)
%%
fprintf('Trimming top basepoint...')
tws = applyMaskToWhisker(tw,mask_struct.top);
tws = sort2Dwhisker(tws,'y');

[~,tws] = extendBP(tws,mask_struct.BP_t,'v');
clear tw
fprintf('done.\n')

fprintf('Trimming Front basepoint...')
fws = applyMaskToWhisker(fw,mask_struct.front);
[~,fws] = extendBP(fws,mask_struct.BP_f);
clear fw
fprintf('done.\n')
%%
tws = sort2Dwhisker(tws,'y');
fws = sort2Dwhisker(fws,'x');

%%
% fprintf('Smooth basepoint...\n')
% warning('off')
% [~,fws] = cleanBP(fws);
% [~,tws] = cleanBP(tws);
% warning('on')

%% Smooth whisker shape
% this step takes forever
fprintf('Smoothing the top whisker...\n')
tws = smooth2Dwhisker(tws,'linear','v');

fprintf('Smoothing the front whisker...\n')
fws = smooth2Dwhisker(fws);
%%
fprintf('Saving last step...\n')
save(outfilename,'-v7.3','tws','fws','frame_size');
fprintf('whisk2merge complete!\n')