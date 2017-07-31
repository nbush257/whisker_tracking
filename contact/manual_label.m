function [label_out,last_tracked] = manual_label(X,label_in,varargin)
%% function label = manual_label(X,C,[start],[win])
% =========================================================================
% this function takes in either a boolean C vector or an integer label
% vector in order to manually clean up contact. It allows you to label as
% either: contact(1), noncontact(-1), or uncertain(0). We will try to use
% the uncertain data to look back at the video if needed.
% =========================================================================
% NEB 20170731
%% input handling and window init
if length(varargin)==2
    win = varargin{2};
    starts = varargin{1}
elseif length(varargin)==1
    starts = varargin{1};
    win=5000;
else
    starts = 1;
    win=5000;
end
stops = starts + win-1;

%% init outputs
last_tracked=starts;
if isempty(label_in)
    label_in = false(size(X,1),1);
end

% '0' means unlablled, -1 means non-contact, 1 means contact
if islogical(label_in)
    label_out = int8(zeros(size(label_in)));
    label_out(~label_in) = -1;
    label_out(label_in) = 1;
else
    label_out = label_in;
end

%% init ui key mappings
add_to_contact = uint8(['a']);
remove_from_contact = uint8(['s']);
uncertain = uint8(['d']);
skip = uint8(['q']); % Need to depricate

%% init figure
close all
f = figure('units','normalized','outerposition',[0 0 1 1]);
mTextBox = uicontrol('style','text');
set(mTextBox,'units','normalized','Position',[.01 .5 .1 .1]);
mTextBox.BackgroundColor = 'w';
mTextBox.HorizontalAlignment = 'left';
s_legend = sprintf('Space = advance with labelling\na = contact\ns = not contact\nd = label as unknown');
set(mTextBox,'String',s_legend);

%% Start UI tracking
try
    while stops<=length(label_in) % Loop over windows
        last_tracked = starts-1;
        x = 0;
        % Loop UI over contact intervals
        while ~isempty(x)
            cla
            x = [];
            but_press = [];
            plot(X(starts:stops,:));
            
            % use temp var booleans for shading
            tempC = label_out==1;
            tempUnknown = label_out==0;
            
            shadeVector(tempC(starts:stops),'k');
            shadeVector(tempUnknown(starts:stops),'r');
            
            title_string = sprintf('Frames: %i  to  %i',starts,stops);
            title(title_string)
            
            % get first UI
            [x_tmp,~,but_press_tmp] = ginput(1);
            if isempty(but_press_tmp) || isempty(x_tmp)
                break
            else
                but_press(1) = but_press_tmp;
                x(1) = x_tmp;
            end
            
            
            % if UI is skip, then skip the labelling of this window
            if ismember(but_press,skip)
                break
            end
            
            % check for spacebar or enter to continue to next frame
            if but_press(1) == 32 || isempty(x)
                break
            end
            % get second UI
            [x(2),~,but_press(2)] = ginput(1);
            
            x = sort(x);
            
            % boundaries
            x(x<1)=0;
            x(x>win)=win;
            
            x = floor(x);
            % align to global vector position
            x = x+starts;
            
            % spacebar or enter advances the frames
            if any(but_press == 32) || isempty(x)
                break
            end
            
            
            % reloop if not the same button
            if but_press(1) ~= but_press(2)
                continue
            else
                % collapse button press ID
                but_press=but_press(1);
            end
            
            
            % If left click or desired strings, add the region to contact.
            % If right click or desired strings,remove the region from contact
            
            if but_press == 1 || ismember(but_press,add_to_contact)
                label_out(x(1):x(2)) = 1;
            elseif but_press==3 || ismember(but_press,remove_from_contact)
                label_out(x(1):x(2)) = -1;
            elseif ismember(but_press,uncertain)
                label_out(x(1):x(2)) = 0;
            end
        end
        
        % advance window
        starts =stops+1;
        stops = starts+win-1;

    end
catch
    warning('caught an error, returning...')
    return
end
