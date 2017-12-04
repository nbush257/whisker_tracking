function wOut = labelWhisker(w,BP_in,x_limit,y_limit,varargin)
%% function labelWhisker(w,BP)
% tries to find a consistent whisker
if length(varargin)==1
    offset = varargin{1};
else
    offset = 0;
end

x_limit = sort(x_limit);
y_limit = sort(y_limit);
BP = BP_in;
l = zeros(size(w));

BP = nan(length(w),2);
for ii = 1:length(w)
    if ~isempty(w(ii).x)
        l(ii) = length(w(ii).x);
        BP(ii,:) = [w(ii).x(1) w(ii).y(1)];
    end
end
% remove all whiskers that are outside of BP bounds or are too small.
rm = l<30 | BP(:,1)<x_limit(1) | BP(:,1)>x_limit(2) | BP(:,2)<y_limit(1) | BP(:,2)>y_limit(2);
w = w(~rm);
max_time = max([w.time]);
BP = BP_in;
for ii = 0:max_time
    idx = 1;
    
    % end case
    if length(w)==1 & w.time==max_time
        wOut(ii+1) = w;
        continue
    end
    
    while w(idx(end)).time==ii
        idx = [idx idx(end)+1];
        if idx(end)>length(w)
            break
        end
    end
    idx(end) = [];
    
    if isempty(idx)
        BP = BP_in;
        wOut(ii+1).time = ii;
        wOut(ii+1).x = [];
        wOut(ii+1).y = [];
        wOut(ii+1).id = -1;
        wOut(ii+1).thick = [];
        wOut(ii+1).scores = -1;
        continue
    end
    
    w_sub = w(idx);
    w(1:idx(end))=[];
    
    if length(w_sub)==1
        BP = [w_sub.x(1) w_sub.y(1)];
        wOut(ii+1) = w_sub;
        continue
    end
    BP_sub = inf(length(w_sub),2);
    rm  =[];
    for jj = 1:length(w_sub)
        % if for some reason the whisker is empty, remove
        if isempty(w_sub(jj).x)
            rm = [rm jj];
            continue
        end

        BP_sub(jj,:) = [w_sub(jj).x(1) w_sub(jj).y(1)];
    end
    BP_sub(rm,:)=[];
    w_sub(rm)=[];
    % shortcut if there is only one possibility
    if length(w_sub)==1
        BP = BP_sub;
        wOut(ii+1) = w_sub;
        continue
    end
    
    d_BP = pdist2(BP,BP_sub,'euclidean');
    [min_d,id] = min(d_BP);
    if isempty(id) || min_d>40
        BP = BP_in;
        wOut(ii+1).time = ii;
        wOut(ii+1).x = [];
        wOut(ii+1).y = [];
        wOut(ii+1).id = -1;
        wOut(ii+1).thick = [];
        wOut(ii+1).scores = -1;
    else
        BP = BP_sub(id,:);
        wOut(ii+1) = w_sub(id);
    end
end
for ii = 1:length(wOut)
    wOut(ii).time = wOut(ii).time+offset;
end


