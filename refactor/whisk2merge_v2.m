function [tws,fws,C] = whisk2merge_v2(tw,twM,fw,fwM,tVidName,fVidName,outfilename)
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
error('Nick thinks this needs to be refactored badly. We probably want to calculate contact after the merge.2016_07_06')

close all
% start parallel pool if not running
gcp;
tVid = VideoReader(tVidName);
fVid = VideoReader(fVidName);

%% Trim to the basepoint
tws = BP_lineMatch(tw,tVid);
fws = BP_lineMatch(fw,fVid);
save(outfilename,'tws','fws');
% 
% tw = trackBP(tVidName,tw);
% fw = trackBP(fVidName,fw);
ca
%% Smooth basepoint
[fBP,fws] = cleanBP(fws);
[tBP,tws] = cleanBP(tws);
save(outfilename,'tws','fws','fwM','twM');


%% Smooth whisker shape
% this step takes forever
fprintf('Smoothing the top whisker...\n')
tic
tws = smooth2D_whisker(tws);
toc
fprintf('Smoothing the front whisker...\n')
tic
fws = smooth2D_whisker(fws);
toc
save(outfilename,'tws','fws','fwM','twM');

%% view to verify the basepoint tracking

sample = randi(length(tws),length(tws),1);

subplot(121)
v = VideoReader(fVidName);
imshow(read(v,5000));hold on

subplot(122)
v = VideoReader(tVidName);
imshow(read(v,5000));hold on

for ii = 1:500
    subplot(121)
    if isempty(fws(sample(ii)).x) ||  isempty(tw(sample(ii)).x)
        continue
    end
    
    plot(fws(sample(ii)).x,fws(sample(ii)).y,'k')
    ho
    plot(fws(sample(ii)).x(1),fws(sample(ii)).y(1),'r*')
    ho
%         plot(fw(sample(ii)).x,fw(sample(ii)).y,'b')
    
    title('Front')
    subplot(122)
    plot(tws(sample(ii)).x,tws(sample(ii)).y,'k')
    ho
    plot(tws(sample(ii)).x(1),tws(sample(ii)).y(1),'r*')
    title('Top')
end
%% Get auto contact estimation
C = logical(zeros(length(tw),1));
k = [];
k2 = [];
k(:,1) = LULU([twM.curvature],3);
k(:,2) = LULU([fwM.curvature],3);
k(isnan(k)) = 0;
k2(1,:) = smoothts(k(:,1)','g',length(k(:,1)),10);
k2(2,:) = smoothts(k(:,2)','g',length(k(:,1)),10);
k2 = k2';
k3 = sum(abs(zscore(k2)),2);
[p,l,w] = findpeaks(k3,'minpeakprominence',std(k3)/3,'minpeakwidth',4);

cStart = round(l-w);cEnd = round(l+w);
cStart(cStart<1) = 1;
cEnd(cEnd>length(C)) = length(C);
C = logical(zeros(length(k2),1));
for ii = 1:length(cStart)
    C(cStart(ii):cEnd(ii)) = 1;
end
%% manually fix contacts
starts = 1;
winsize = 5000;
stops = winsize+starts;
longfig
while starts<length(C)
    x = 0;
    if stops>length(C)
        stops = length(C);
    end
    while ~isempty(x)
        clf
    plot(scale(k3(starts:stops)),'k');ln2;
        shadeVector(C(starts:stops))
        
        [x,~,but] = ginput(2);
        x = sort(x);
        x(x<1)=1;
        x = round(x);
        x = x+starts;
        if but ==1
            C(x(1):x(2)) = 1;
        elseif but==3
            C(x(1):x(2)) = 0;
        end
    end
    hold off
    starts = stops;
    stops = starts+winsize;
end
ca
plot(C)
ho
plot(scale(k3))
save(outfilename,'tws','fws','fwM','twM','C');

%% Output




