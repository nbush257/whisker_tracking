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
%% Smooth basepoint
fw = cleanBP(fw);
tw = cleanBP(tw);

%% Smooth whisker shape
tw = smooth2D_whisker(tw);
fw = smooth2D_whisker(fw);

%% view to verify the basepoint tracking

sample = randi(length(tw),length(tw),1);
for ii = 1:800
    subplot(121)
    if isempty(fw(sample(ii)).x) ||  isempty(tw(sample(ii)).x)
        continue
    end
    
    plot(fw(sample(ii)).x,fw(sample(ii)).y,'k')
    ho
    plot(fw(sample(ii)).x(1),fw(sample(ii)).y(1),'r*')
    
    subplot(122)
    plot(tw(sample(ii)).x,tw(sample(ii)).y,'k')
    ho
    plot(tw(sample(ii)).x(1),tw(sample(ii)).y(1),'r*')
end
%% Get contact 
% get theta for contact estimation
TH_top = nan(length(tw),1);
for ii = 1:length(tw)
    if isempty(tw(ii).x)
        continue
    end
    x1 = tw(ii).x(1);
    y1 = tw(ii).y(1);
    l = length(tw(ii).x);
    ye = tw(ii).y(ceil(l/5));
    xe = tw(ii).x(ceil(l/5));
    TH_top(ii) = atan2(ye-y1,xe-x1)*180/pi;
end

% wrap theta
TH_top(TH_top>nanmean(TH_top)+180) = TH_top(TH_top>nanmean(TH_top)+180)-360;
TH_top(TH_top<nanmean(TH_top)-180) = TH_top(TH_top<nanmean(TH_top)-180)+360;
TH_top = double(TH_top);

% get theta front
TH_front = nan(length(fw,1));
for ii = 1:length(fw)
    if isempty(fw(ii).x)
        continue
    end
    x1 = fw(ii).x(1);
    y1 = fw(ii).y(1);
    l = length(fw(ii).x);
    ye = fw(ii).y(ceil(l/5));
    xe = fw(ii).x(ceil(l/5));
    TH_front(ii) = atan2(ye-y1,xe-x1)*180/pi;
end

% wrap theta
TH_front(TH_front>nanmean(TH_front)+180) = TH_front(TH_front>nanmean(TH_front)+180)-360;
TH_front(TH_front<nanmean(TH_front)-180) = TH_front(TH_front<nanmean(TH_front)-180)+360;
TH_front = double(TH_front);




k(:,1) = medfilt1([twM.curvature],5);
k(:,2) = medfilt1([fwM.curvature],5);
k(:,3) = medfilt1(TH_top);
k(:,4) = medfilt1(TH_front);


