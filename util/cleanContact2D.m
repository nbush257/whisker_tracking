function [C,starts] = cleanContact2D(tip_scale,C,varargin)
%% function C = getContact_from3D(tip_scale,C,[start_frame],[win_size])
% takes a 3D whisker structure as input and asks the user to manually find
% contact periods based on a PCA decomposition of the tip location.
% =======================================================
% INPUTS:   tip_scale - A Nx4 matrix of the tip position over time with
%               front view in cols 1 and 2... Should have been scaled
%               before in the python contact finding code.
%
%           C - a [length(w) by 1] contact logical. This is used if you have found part of
%            the C variable, but not all of it. If a C variable is input,
%            the user inputting starts at the last True value of C.
%       
%           [winsize] - how much of the tip position to view at a time.
%
% OUTPUTS:  C - a [length(w) x 1] contact logical 
% =====================================================
% NEB 20170307
%% varargin handling
narginchk(2,4)
numvargs = length(varargin);
optargs = {1,3000;};
optargs(1:numvargs) = varargin;
[starts, winsize] = optargs{:};

%%
close all
C = logical(medfilt1(single(C)));
% get first point
if starts==1
    plot(tip_scale)
    zoom on
    title('click on first contact frame')
    pause
    [xInit,~] = ginput(1);
    starts = round(xInit);
    C(1:starts) = 0;
end
%% Manual input
close all

stops = winsize+starts;


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
            plot(tip_scale(starts:stops,:));
            shadeVector(C(starts:stops));
            title_string = sprintf('Frames: %i  to  %i',starts,stops);
            title(title_string)
            
            % get user inputs
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x = floor(x);
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
        % get the next window
        starts = stops;
        stops = starts+winsize;
    end
catch
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    C = logical(medfilt1(single(C)));
    return
end
C = logical(medfilt1(single(C)));
