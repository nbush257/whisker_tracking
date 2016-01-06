function whisk2merge_v2()
frontVidName = '';
topVidName = '';
frontTracked = '.mat'
topTracked = '.mat'
%% load in data
error('This is code is being refactored')
% Nick Bush 2015_11_23
% load front data
load(frontTracked)
fw = w;
fwM = wM;
fm = m;
fmM = mM;
clear w wM m mM
% load top data
load(topTracked)
tw = w;
twM = wM;
tm = m;
tmM = mM;
clear m w mM wM
%% Trim to the basepoint
tw = trackBP(tVidName,tw);
fw = trackBP(fVidName,fw);
ca
%% Smooth basepoint
[fBP,fws] = cleanBP(fw);
[tBP,tws] = cleanBP(tw);

%% Smooth whisker shape
% this step takes forever
tic
tws = smooth2D_whisker(tws(1:10));
toc
tic
fws = smooth2D_whisker(fws);
toc
%% view to verify the basepoint tracking

sample = randi(length(tws),length(tws),1);

subplot(121)
v = VideoReader(fVidName);
imshow(read(v,5000));hold on

subplot(122)
v = VideoReader(tVidName);
imshow(read(v,5000));hold on

for ii = 1:100
    subplot(121)
    if isempty(fws(sample(ii)).x) ||  isempty(tw(sample(ii)).x)
        continue
    end
    
    plot(fws(sample(ii)).x,fws(sample(ii)).y,'k')
    ho
    plot(fws(sample(ii)).x(1),fws(sample(ii)).y(1),'r*')
    ho
    %     plot(fw(sample(ii)).x,fw(sample(ii)).y,'b')
    
    title('Front')
    subplot(122)
    plot(tws(sample(ii)).x,tws(sample(ii)).y,'k')
    ho
    plot(tws(sample(ii)).x(1),tws(sample(ii)).y(1),'r*')
    title('Top')
end
%% Get contact
% get theta for contact estimation
TH_top = nan(length(tws),1);
for ii = 1:length(tws)
    if isempty(tws(ii).x)
        continue
    end
    x1 = tws(ii).x(1);
    y1 = tws(ii).y(1);
    l = length(tws(ii).x);
    ye = tws(ii).y(ceil(l/5));
    xe = tws(ii).x(ceil(l/5));
    TH_top(ii) = atan2(ye-y1,xe-x1)*180/pi;
end

% wrap theta
TH_top(TH_top>nanmean(TH_top)+180) = TH_top(TH_top>nanmean(TH_top)+180)-360;
TH_top(TH_top<nanmean(TH_top)-180) = TH_top(TH_top<nanmean(TH_top)-180)+360;
TH_top = double(TH_top);

% get theta front
TH_front = nan(length(fws),1);
for ii = 1:length(fws)
    if isempty(fws(ii).x)
        continue
    end
    x1 = fws(ii).x(1);
    y1 = fws(ii).y(1);
    l = length(fws(ii).x);
    ye = fws(ii).y(ceil(l/5));
    xe = fws(ii).x(ceil(l/5));
    TH_front(ii) = atan2(ye-y1,xe-x1)*180/pi;
end

% wrap theta
TH_front(TH_front>nanmean(TH_front)+180) = TH_front(TH_front>nanmean(TH_front)+180)-360;
TH_front(TH_front<nanmean(TH_front)-180) = TH_front(TH_front<nanmean(TH_front)-180)+360;
TH_front = double(TH_front);



%% Still needs work!!!
k = [];
k2 = [];
k(:,1) = LULU([twM.curvature],3);
k(:,2) = LULU([fwM.curvature],3);
k(isnan(k)) = 0;
k2(1,:) = smoothts(k(:,1)','g',length(k(:,1)),10);
k2(2,:) = smoothts(k(:,2)','g',length(k(:,1)),10);
k2 = k2';

plot(k(:,1))
ho
toFlip = [];
ret = 1;
while ~isempty(ret)
    title('Zoom then enter');zoom on; pause
    [x,~,ret] = ginput(2);
    if ~isempty(ret)
        
        fill([x(1) x(1) x(2) x(2)],[min(k(:,1)) max(k(:,1)) max(k(:,1)) min(k(:,1))],'k','facealpha',.2)
        toFlip = [toFlip;x']
    end
end

k2 =[];
toFlip = round(toFlip);
ca
k2 = k(:,1);
for ii = 1:size(toFlip(:,1))
    k2(toFlip(ii,1):toFlip(ii,2),1) = -k2(toFlip(ii,1):toFlip(ii,2),1)+k2(toFlip(ii,1),1);
end

plot(k(:,2))
ho
toFlip = [];
ret = 1;
while ~isempty(ret)
    title('Zoom then enter');zoom on; pause
    [x,~,ret] = ginput(2);
    if ~isempty(ret)
        fill([x(1) x(1) x(2) x(2)],[min(k(:,1)) max(k(:,1)) max(k(:,1)) min(k(:,1))],'k','facealpha',.2)
        
        toFlip = [toFlip;x'];
    end
end
toFlip = round(toFlip);
k2(:,2) = k(:,2);
for ii = 1:size(toFlip(:,1))
    k2(toFlip(ii,1):toFlip(ii,2),2) = -k2(toFlip(ii,1):toFlip(ii,2),2)+k2(toFlip(ii,1),2);
end
ca
k3 = sum(zscore(k2),2);
[p,l,w] = findpeaks(k3,'minpeakprominence',std(k3)/2);

cStart = round(l-w);cEnd = round(l+w);
cStart(cStart<1) = 1;
cEnd(cEnd>length(C)) = length(C);
C = logical(zeros(length(k2),1));
for ii = 1:length(cStart)
    C(cStart(ii):cEnd(ii)) = 1;
end
plot(find(C),k3(C))
ho
plot(find(~C),k3(~C),'.')




