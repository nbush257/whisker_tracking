X = featureScaling(PP);
[a,b,c] = pca(X);
%%
b1 = b(:,1);
b1(isnan(b1)) = nanmean(b1);
b1 = bwfilt(b1,300,0,10);
plot(diff(b1))
%%
for ii = 1:size(X,2)
    subplot(6,6,ii)
    plot(X(:,ii))
end

%%
tip = nan(length(w),3);

for ii = 1:length(w)
    if isempty(w(ii).x)
        continue
    end
    
    tip(ii,:) = [w(ii).x(end) w(ii).y(end) w(ii).z(end)];
end
%%
tip_clean = clean3D_tip(w);
%%
[~,b] = pca(featureScaling(tip_clean));
bb = b(:,1);
plot(bb)
[~,y] = ginput(1);
bb = abs(b(:,1)-y);
%%
% [p,l,w] = findpeaks(bb,'minpeakprominence',nanstd(bb)/3,'minpeakwidth',4);

% 
% cStart = round(l-w);cEnd = round(l+w);
% cStart(cStart<1) = 1;
% cEnd(cEnd>length(C)) = length(C);
C = false(size(bb));
% for ii = 1:length(cStart)
%     C(cStart(ii):cEnd(ii)) = 1;
% end


starts = 1;
winsize = 5000;
stops = winsize+starts;
longfig
slop = 10;
while starts<length(C)
    x = 0;
    if stops>length(C)
        stops = length(C);
    end
    while ~isempty(x)
        clf
        plot(scale(bb(starts:stops)),'k');ln2;
        shadeVector(C(starts:stops))
        
        [x,~,but] = ginput(2);
        x = sort(x);
        x(x<1)=1;
        x = round(x);
        x = x+starts;
        if isempty(x)
            continue
        end
        
        [~,t1] = min(bb(x(1)-slop:x(1)+slop));
        
        
        xy(1) = x(1)-slop-1+t1;
        xy(2) = x(2)
        
        if but ==1
            C(xy(1):xy(2)) = 1;
        elseif but==3
            C(xy(1):xy(2)) = 0;
        end
    end
    hold off
    starts = stops;
    stops = starts+winsize;
end
ca
plot(C)