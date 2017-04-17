function [C_out,tip] = semisupervisedContact_2D(fws,tws,varargin)
if length(varargin)>0
    C_man = varargin{1};
else
    C_man = nan(length(fws),1);
end
C_out = C_man;
%% get tip
tip = nan(length(fws),4);
for ii = 1:length(fws)
    if isempty(fws(ii).x) | isempty(tws(ii).x)
        continue
    end
    tip(ii,:) = [fws(ii).x(end) fws(ii).y(end) tws(ii).x(end) tws(ii).y(end)];
end

t = medfilt1(tip);
for ii = 1:size(t,2)
    t(:,ii) = InterpolateOverNans(t(:,ii),50);
end
t = featureScaling(t);
%%
% bsStim = basisFactory.makeNonlinearRaisedCos(3,1,[0 5],1);
% X = basisFactory.convBasis(t,bsStim);
% X = featureScaling(X);
% t_vec = linspace(0,1,size(t,1));
% t = [t t_vec'];
%% unsupervised initial classification
gm = fitgmdist(t,2);
C_gm = cluster(gm,t);
C_gm = C_gm-1;

%% 
close all
C_out = C_man;
winsize = 500;
% get first point

if any(isfinite(C_out))
    xInit = find(isfinite(C_out),1,'last')-100;
    starts = round(xInit);
    stops = winsize+starts;
else
    bigfig;
    plot(t)
    zoom on
    title('click on first contact frame')
    pause
    [xInit,~] = ginput(1);
    starts = round(xInit);
    stops = winsize+starts;
    C_out(1:xInit) = 0;
end
bigfig
plot(t(starts:stops,:));
shadeVector(C_gm(starts:stops))
title('Flip the contact vector?')
flip = input('Do we need to flip the contact binary? ([0]/1)');
if flip
    C_gm = -1*(C_gm-1);
end


while starts<length(C_gm)
    % x is the ginput x positions. Init to allow for a while loop in a
    % few lines
    x = 0;
    
    % prevent indexing past the length of the trace
    if stops>length(C_gm)
        stops = length(C_gm);
    end
    
    % stay on this window until no inputs.
    no_click = true;
    try
        while ~isempty(x)
            clf
            plot(t(starts:stops,:));
            shadeVector(C_gm(starts:stops))
            title_caption = sprintf('Frames %i to %i \t %.1f%s done',starts,stops,starts/length(C_gm)*100,'%');
            title(title_caption)
            % get user inputs
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x(x>winsize) = winsize;
            x = round(x);
            x = x+starts;
            if isempty(x)
                continue
            end
            
            
            % If left click, add the region to contact. If right click,
            % remove the region from contact
            if but ==1
                C_gm(x(1):x(2)) = 1;
                no_click = false;
            elseif but==3
                C_gm(x(1):x(2)) = 0;
                no_click = false;
            end
        end
        C_out(starts:stops) = C_gm(starts:stops);
        hold off
        % get the next window (add a little from the previous window)
        starts = stops-50;
        stops = starts+winsize;
    catch

        fprintf(repmat('=',20,1))
        fprintf('\nFunction errored out. Returning C variable\n')
        return
    end
end