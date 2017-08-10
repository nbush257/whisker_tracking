function wOut = labelWhisker(w,BP_in,x_limit,y_limit)
%% function labelWhisker(w,BP)
% tries to find a consistent whisker
x_limit = sort(x_limit);
y_limit = sort(y_limit);
BP = BP_in;
for ii = 0:max([w.time])
    if mod(ii,1000)==0
        fprintf('Frame %i of %i\n',ii,max([w.time]))
    end
    w_sub = w([w.time]==ii);
    BP_sub = inf(length(w_sub),2);
    rm  =[];
    for jj = 1:length(w_sub)
        
        % if for some reason the whisker is empty, remove
        if isempty(w_sub(jj).x)
            rm = [rm jj];
            continue
        end
        % remove short whiskers from consideration
        if length(w_sub(jj).x)<30
            rm = [rm jj];
            continue
        end
        if w_sub(jj).x(1)<x_limit(1) || w_sub(jj).x(1)>x_limit(2)
            rm = [rm jj];
        end
        
        if w_sub(jj).y(1)<y_limit(1) || w_sub(jj).y(1)>y_limit(2)
            rm = [rm jj];
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


