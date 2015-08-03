%% load in data
clear
ca
load('rat2015_15_JUN11_VG_C2_t01_Front_traced.mat')
frontM = allM;
frontW = allW;
load('rat2015_15_JUN11_VG_C2_t01_Top_traced.mat')
topM = allM;
topW = allW;
clear m w
topWRaw = topW;
topMRaw = topM;
frontMRaw = frontM;
frontWRaw = frontW;
%% Trim to the basepoint
topW = trackBP('rat2015_15_JUN11_VG_C2_t01_Top_F040001F060000.avi',topW);
frontW = trackBP('rat2015_15_JUN11_VG_C2_t01_Front_F040001F060000.avi',frontW);


topW = rmOutlierPts(topW);
frontW = rmOutlierPts(frontW);

topW = fill2Dgap(topW);
frontW = fill2Dgap(frontW);


%% view to verify the basepoint tracking

sample = randi(length(topW),length(topW),1);
for ii = 1:800
    subplot(121)
    if isempty(frontW(sample(ii)).x) ||  isempty(topW(sample(ii)).x)
        continue
    end
    
    plot(frontW(sample(ii)).x,frontW(sample(ii)).y,'k')
    ho
    plot(frontW(sample(ii)).x(1),frontW(sample(ii)).y(1),'r*')
    
    subplot(122)
    plot(topW(sample(ii)).x,topW(sample(ii)).y,'k')
    ho
    plot(topW(sample(ii)).x(1),topW(sample(ii)).y(1),'r*')
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


%% get TH


TH_linear_top = nan(length(topW),1);
TH_linear_front = nan(length(topW),1);
tic
for ii = 1:length(topW)
    x1 = [];y1 = [];ye = []; xe = [];
    if ~isempty(topW(ii).x)
                l = length(topW(ii).x);

        x1 = topW(ii).x(ceil(l/1.5));
        y1 = topW(ii).y(ceil(l/1.5));
        ye = topW(ii).y(ceil(l/1.2));
        xe = topW(ii).x(ceil(l/1.2));
        TH_linear_top(ii) = atan2(ye-y1,xe-x1)*180/pi;
    end
    x1 = [];y1 = [];ye = []; xe = [];
    if ~isempty(frontW(ii).x)
                l = length(frontW(ii).x);

        x1 = frontW(ii).x(ceil(l/1.5));
        y1 = frontW(ii).y(ceil(l/1.5));
        ye = frontW(ii).y(ceil(l/1.2));
        xe = frontW(ii).x(ceil(l/1.2));
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

