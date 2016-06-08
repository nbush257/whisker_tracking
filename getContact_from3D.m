%%
function C = getContact_from3D(w,varargin)
%% function C = getContact_from3D(w,[C],[winsize])
% takes a 3D whisker structure as input and asks the user to manually find
% contact periods based on a PCA decomposition of the tip location.
% INPUTS:   w - a 3D whisker struct

%           [C] - a [length(w) by 1] contact logical. This is used if you have found part of
%           the C variable, but not all of it. If a C variable is input,
%           the user inputting starts at the last True value of C.
%       
%           [winsize] - how much of the tip position to view at a time.

% OUTPUTS:  C - a [length(w) x 1] contact logical 
% NEB 2016_06_08
%% varargin handling
narginchk(1,3)
numvargs = length(varargin);
optargs = {false(length(w)),5000;};
optargs(1:numvargs) = varargin;
[C,winsize] = optargs{:};

%%
close all

%get a smoothed estimate of tip position
tip_clean = clean3D_tip(w);

% decompose the tip location into a 1D vector.
[~,b] = pca(featureScaling(tip_clean));
bb = b(:,1);
plot(bb)

% this might need fixing. It is a workaround to make everythin positive
[~,y] = ginput(1);
bb = abs(b(:,1)-y);
%% Manual input
close all

% init windowing
starts = 1;
if numvargs >= 1 && sum(C)>0
    starts = find(C,1,'last');
end

stops = winsize+starts;
longfig

% set window in which to look for the minimum value of abs(bb). This makes
% it easier to click quickly.
slop = 10;
%try statement so that you don't lose all your work if something stupid
%happens
try
    while starts<length(C)
        % x is the ginput x positions. Init to allow for a while loop in a
        % few lines
        x = 0;
        
        % prevent indexing past the length of the trace
        if stops>length(C)
            stops = length(C);
        end
        
        % stay on this window until no inputs.
        while ~isempty(x)
            clf
            plot(scale(bb(starts:stops)),'k');ln2;
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
            
            % find the minimum within a window the size of slop for the contact onset. May want
            % to switch to a local min somehow.
            [~,t1] = min(bb(x(1)-slop:x(1)+slop));
            xy(1) = x(1)-slop-1+t1;
            xy(2) = x(2);
            
            % If left click, add the region to contact. If right click,
            % remove the region from contact
            if but ==1
                C(xy(1):xy(2)) = 1;
            elseif but==3
                C(xy(1):xy(2)) = 0;
            end
        end
        
        hold off
        % get the next window
        starts = stops;
        stops = starts+winsize;
    end
catch
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    return
end