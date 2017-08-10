function wOut = labelWhisker(w,frame_num,varargin)
%% function labelWhisker(w,frame_num,varargin)
% tries to find a consistent whisker
if length(varargin)==1
    img = varargin{1};
end
if exist('img','var')
    imshow(img);hold on;
end

w_sub = w([w.time]==frame_num);
hold on
for ii = 1:length(w_sub)
    plot(w_sub(ii).x,w_sub(ii).y,'.-')
end
title('click on the whisker');
uIn = ginput(1);

for ii = 1:length(w_sub)
    d(ii) = min(pdist2(uIn,[w_sub(ii).x w_sub(ii).y]));
end
[~,id] = min(d);

BP = [w_sub(id).x(1) w_sub(id).y(1)];
for ii = 0:max([w.time])
    w_sub = w([w.time]==ii);
    BP_sub = [];
    for jj = 1:length(w_sub)
        BP_sub(jj,:) = [w_sub(jj).x(1) w_sub(jj).y(1)];
    end
    d_BP = pdist2(BP,BP_sub);
    [~,id] = min(d_BP);
    BP = BP_sub(id,:);
    wOut(ii+1) = w_sub(id);
end


