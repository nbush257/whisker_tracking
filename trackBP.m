function [wStruct,xBaseMedian,yBaseMedian] = trackBP(vidFileName,wStruct,varargin)
%% function [wStruct,xBaseMedian,yBaseMedian] = trackBP(vidFileName,wStruct,varargin)
% -------------------------------------------------------------------------
% Finds the basepoint by gettin user input as to where the basepoint is,
% finding the nearest point on the 'whisk' tracked whisker, and cutting it
% off there. 
% -----------------------------------------------------------------------
% INPUTS: 
%   vidFileName = string of video file to grab the first frame. Can be a .see or .avi 
%   wStruct = 2D tracked whisker structure.
%   varargin:
%       {1}: startFrame - if you want to use a particular frame for the
%       user input, specify it here. Defaults to 1
% OUTPUTS: 
%   wstruct = 'whisk-like' structure with bpx and bpy fields appended [n]
%       [n] length struct with x and y fields of whisker coordinates
%
%   xBaseMedian = median x position of the basepoint
%   yBaseMedian = median y position of the basepoint


%% Input handling
% check for start frame
if length(varargin) == 1
    startFrame = varargin{1};
elseif length(varargin)>1
    warning(['Too many input arguments, taking the start frame to be ' num2str(varargin{1})])
    startFrame = varargin{1};
else
    startFrame = 1;
end
% check for video file format
if strcmp(vidFileName(end-2:end),'avi')
    v = VideoReader(vidFileName);
    I = read(v,startFrame);
elseif strcmp(vidFileName(end-2:end),'seq')
    v = seqIo(vidFileName,'r');
    v.seek(startFrame-1);
    I = v.getframe();
else
    error('Incompatible video format. Must be an .AVI or .SEQ')
end

%% User input Basepoint
imshow(I);
zoom on; title('zoom to the basepoint');pause;
title('click on the basepoint')
bp(1,:) = ginput(1);

%% Trim the tracked whisker in each frame to the basepoint. 
% Sequentially finds the nearest tracked whisker node to the most recent
% basepoint.
for ii = 1:length(wStruct);
    
    % if this is the first frame, use the user defined basepoint
    if ii == 1
        d = sqrt((wStruct(ii).x-bp(1,1)).^2 + (wStruct(ii).y-bp(1,2)).^2);
        
    else % If this is not the first frame, find the nearest node to the last basepoint.
        d = sqrt((wStruct(ii).x-bp(ii-1,1)).^2 + (wStruct(ii).y-bp(ii-1,2)).^2);
    end
    [~,bpIdx(ii)] = (min(d));%find the index of the node closest to the last basepoint.
    
    %get the basepoint value based on the index found previously
    bp(ii,1) = wStruct(ii).x(bpIdx(ii));
    bp(ii,2) = wStruct(ii).y(bpIdx(ii));
    % if this isn't the first frame, make sure the basepoint hasn't moved
    % more than 5 pixels from the last time.
    if ii~=1
        bp_movement = sqrt((bp(ii,1)-bp(ii-1,1)).^2 + (bp(ii,2)-bp(ii-1,2)).^2);
        
        if bp_movement>5 %If it has moved more than 5 pixels, use the previous basepoint as the current basepoint.
            %and set the first node on the whisker equal to the last
            %basepoint.
            bpIdx(ii) = 1;
            wStruct(ii).x(1) = bp(ii-1,1);
            wStruct(ii).y(1) = bp(ii-1,2);
            
            %I should do some smoothing here.
            bp(ii,1) = bp(ii-1,1);
            bp(ii,2) = bp(ii-1,2);
        end
    end
end

%% Output 
for ii =1:length(wStruct)
    wStruct(ii).x = wStruct(ii).x(bpIdx(ii):end);
    wStruct(ii).y = wStruct(ii).y(bpIdx(ii):end);
    wStruct(ii).xBase = bp(ii,1);
    wStruct(ii).yBase = bp(ii,2);
end
xBaseMedian = nanmedian([wStruct.xBase]);
yBaseMedian = nanmedian([wStruct.yBase]);
