function [tws,fws] = whisk2merge_v2(tw,twM,fw,fwM,tVidName,fVidName,outfilename)
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

close all
% start parallel pool if not running
gcp;
tVid = VideoReader(tVidName);
fVid = VideoReader(fVidName);
It = read(tVid,20000);
If = read(fVid,20000);
%% Trim to the basepoint
[tBP,tws] = extendBP(tw,It);
[fBP,fws] = extendBP(fw,If);
save(outfilename,'tws','fws','twM','fwM');
close all
%% Smooth basepoint
[fBP,fws] = cleanBP(fws);
[tBP,tws] = cleanBP(tws);
save(outfilename,'-append','tws','fws');

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
save(outfilename,'-append','tws','fws');

%% view to verify the basepoint tracking

% sample = randi(length(tws),length(tws),1);
% 
% subplot(121)
% v = VideoReader(fVidName);
% imshow(read(v,5000));hold on
% 
% subplot(122)
% v = VideoReader(tVidName);
% imshow(read(v,5000));hold on
% 
% for ii = 1:500
%     subplot(121)
%     if isempty(fws(sample(ii)).x) ||  isempty(tw(sample(ii)).x)
%         continue
%     end
%     
%     plot(fws(sample(ii)).x,fws(sample(ii)).y,'k')
%     ho
%     plot(fws(sample(ii)).x(1),fws(sample(ii)).y(1),'r*')
%     ho
% %         plot(fw(sample(ii)).x,fw(sample(ii)).y,'b')
%     
%     title('Front')
%     subplot(122)
%     plot(tws(sample(ii)).x,tws(sample(ii)).y,'k')
%     ho
%     plot(tws(sample(ii)).x(1),tws(sample(ii)).y(1),'r*')
%     title('Top')
% end
%% Output




