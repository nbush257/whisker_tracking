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
clear sample
% zoom on;pause;
% [fol,~] = ginput(2);
% for ii = 1:length(topW)
%     if ~isempty(frontW(ii).x)
%         toRM = frontW(ii).x<fol(1);
%         frontW(ii).x(toRM) = [];
%         frontW(ii).y(toRM) = [];
%     end
%     if ~isempty(topW(ii).x)
%         toRM = topW(ii).x<fol(2);
%
%         topW(ii).x(toRM) = [];
%         topW(ii).y(toRM) = [];
%     end
% end
pause
ca
%% get TH


TH_linear_top = nan(length(tw),1);
TH_linear_front = nan(length(tw),1);
tic
for ii = 1:length(tw)
    x1 = [];y1 = [];ye = []; xe = [];
    if ~isempty(tw(ii).x)
                l = length(tw(ii).x);

        x1 = tw(ii).x(ceil(l/1.5));
        y1 = tw(ii).y(ceil(l/1.5));
        ye = tw(ii).y(ceil(l/1.2));
        xe = tw(ii).x(ceil(l/1.2));
        TH_linear_top(ii) = atan2(ye-y1,xe-x1)*180/pi;
    end
    x1 = [];y1 = [];ye = []; xe = [];
    if ~isempty(fw(ii).x)
                l = length(fw(ii).x);

        x1 = fw(ii).x(ceil(l/1.5));
        y1 = fw(ii).y(ceil(l/1.5));
        ye = fw(ii).y(ceil(l/1.2));
        xe = fw(ii).x(ceil(l/1.2));
        TH_linear_front(ii) = atan2(ye-y1,xe-x1)*180/pi;
    end
    
end
toc
% wrap theta
TH_linear_top(TH_linear_top>nanmean(TH_linear_top)+180) = TH_linear_top(TH_linear_top>nanmean(TH_linear_top)+180)-360;
TH_linear_top(TH_linear_top<nanmean(TH_linear_top)-180) = TH_linear_top(TH_linear_top<nanmean(TH_linear_top)-180)+360;
TH_linear_top = double(TH_linear_top);


TH_linear_front(TH_linear_front>nanmean(TH_linear_front)+180) = TH_linear_front(TH_linear_front>nanmean(TH_linear_front)+180)-360;
TH_linear_front(TH_linear_front<nanmean(TH_linear_front)-180) = TH_linear_front(TH_linear_front<nanmean(TH_linear_front)-180)+360;
TH_linear_front = double(TH_linear_front);



%% get contact vector
plot(TH_linear_front)
[~,yval] = ginput(1);
TH_linear_front = abs(TH_linear_front-yval);

plot(TH_linear_top)
[~,yval] = ginput(1);
TH_linear_top = abs(TH_linear_top-yval);

indicator = medfilt1(TH_linear_top+TH_linear_front);
[~,locs,wid] = findpeaks(indicator,'MinPeakProminence',10,'MinPeakWidth',3);
%plot(indicator);
ho
%plot(locs,indicator(locs),'*')
C = zeros(size(TH_linear_front));
for ii = 1:length(locs)
    
    C(round(locs(ii)-wid(ii)):round(locs(ii)+wid(ii))) = 1;
end
plot(scale(indicator))
ho
plot(C)

starts = 1;
winsize = 10000;
stops = winsize+starts;
longfig
while starts<length(C)
    x = 0;
    if stops>length(C)
        stops = length(C);
    end
    plot(scale(indicator(starts:stops)));
    ho
    plot(C(starts:stops))
    while ~isempty(x)
        [x,~,but] = ginput(2);
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
plot(scale(indicator))

