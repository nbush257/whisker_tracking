d= dir('*toMerge.mat')
for jj = 2:length(d)
    load(d(jj).name)
%%
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
TH_top(1) = nanmean(TH_top);
TH_front(1) = nanmean(TH_front);
TH_top(end) = nanmean(TH_top);
TH_front(end) = nanmean(TH_front);


TH_top2 = smooth(medfilt1(naninterp(TH_top),5),'lowess',100);
TH_top2 = TH_top2-mean(TH_top2);

TH_front2 = smooth(medfilt1(naninterp(TH_front),5),'lowess',100);
TH_front2 =TH_front2-mean(TH_front2);
kt3 = abs(zscore(TH_front2))+abs(zscore(TH_top2));
%%
    
    C = logical(zeros(length(tws),1));
    k = [];
    k2 = [];
    k(:,1) = medfilt1([twM.curvature],5);
    k(:,2) = medfilt1([fwM.curvature],5);
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
    % plot(find(C),k3(C),'.')
    % ho
    % plot(find(~C),k3(~C),'.')
    
    %% manually fix contacts
    starts = 1;
    winsize = 4000;
    stops = winsize+starts;
    longfig
    k4 = scale(k3);
    kt4 = scale(kt3);
    while starts<length(C)
        x = 0;
        if stops>length(C)
            stops = length(C);
        end
        while ~isempty(x)
            clf
            plot(k4(starts:stops),'k');ln2;
            ho
            plot(kt4(starts:stops),'r');ln2;
            shadeVector(C(starts:stops))
            
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x = round(x);
            x(x>length(C)) = length(C);
            x = x+starts;
            if length(x)<2
                x(2) = x;
            end
            
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
    % plot(C)
    % ho
    % plot(scale(k3))
    save(d(jj).name,'tws','fws','fwM','twM','C');
end
