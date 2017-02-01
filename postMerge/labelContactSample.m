%%
function [C,tip] = labelContactSample(w)
%% function [C,tip] = labelContactSample(w)
% takes a 3D whisker structure as input and asks the user to manually find
% a sample of contact periods to be used as labels to a supervised
% clustering algorithm
% =======================================================
% INPUTS:   w - a 3D whisker struct
%          
% OUTPUTS:  C - a [length(w) x 1] contact logical 
% =====================================================
% NEB 2017_01_27
%%
C = nan(length(w),1);
winsize = 1000;

close all
tip = nan(length(w),3);
for ii = 1:length(w)
    if ~isempty(w(ii).x)
        tip(ii,:) = [w(ii).x(end) w(ii).y(end) w(ii).z(end)];
    end
end

    
%get a smoothed estimate of tip position
tip_clean = clean3D_tip(w);

%
for ii = 1:3
    tip_clean(:,ii) = scale(tip_clean(:,ii));
end
%% first guess

bsStim = basisFactory.makeNonlinearRaisedCos(4,1,[0 10],10);
X_c = basisFactory.convBasis(tip_clean,bsStim);
fit_obj = fitgmdist(X_c,2);
guess = cluster(fit_obj,X_c);
guess = guess-1;


%% Manual input
close all
longfig
bds = [1:winsize:length(w) length(w)];
bound_samp = randsample(length(bds)-1, round(length(bds)./10));

%try statement so that you don't lose all your work if something stupid
%happens
% try

starts = bds(bound_samp(1));
stops = bds(bound_samp(1))+winsize;
plot(tip_clean(starts:stops,:))
shadeVector(guess(starts:stops))

flip = input('Do we need to flip the labelling? (1/[0])');
if flip
    guess = (guess.*-1)+1;
end
guess(isnan(guess)) = 0; guess = logical(guess);

    for ii = 1:length(bound_samp)
        % x is the ginput x positions. Init to allow for a while loop in a
        % few lines
        x = 0;
        starts = bds(bound_samp(ii));
        stops = bds(bound_samp(ii))+winsize;
        % prevent indexing past the length of the trace
        if stops>length(C)
            stops = length(C);
        end
        
        % stay on this window until no inputs.
        C(starts:stops) = guess(starts:stops);
        while ~isempty(x)
            clf
            plot(tip_clean(starts:stops,:),'k.-','linewidth',2);
            shadeVector(C(starts:stops))
            
            % get user inputs
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x = round(x);
            x = x+starts;
            if isempty(x)
                continue
            end
            
            % If left click, add the region to contact. If right click,
            % remove the region from contact
            if but ==1
                C(x(1):x(2)) = 1;
            elseif but==3
                C(x(1):x(2)) = 0;
            end
        end
        
        hold off
    end
% catch
%     
%     fprintf(repmat('=',20,1))
%     fprintf('\nFunction errored out. Returning C variable\n')
%     return
% end