function [I,points] = autoExtractCorners(vFnameTop,vFnameFront,numPts,stride,varargin)
%% function[I,points] = autoExtractCorners(vFNameTop,vFNameFront,numPts,stride,[firstFrame],[lastFrame])
% ======================================================
% This function goes through both calibration videos to find the
% calibration image. This function is called by 'fullAutoCalib'. This
% function will write tiff images to the current directory of frames where
% the calibration image is detectable completely in both views. These are
% then used by fullAutoCalib. Standard usage is to not call any outputs
% =====================================================
% INPUTS:
%           vFNameTop   - name of the top calibration video file
%           vFNameFront - name of the front calibration video file
%           numPts      - number of points to look for in the automatic
%                           in the automatic checkerboard detection. The
%                           2mm grid has 42 points.
%           stride      - Number of frames to skip when looking for
%                           checkerboard
%           [firstFrame]- if you want to only use a subset of the frames,
%                           input the first frame to use here
%           [lastFrame] - as above, the last frame. The function will look
%                           at frames between firstFrame and lastFrame.
% OUTPUTS:
%           I           - a structure containing the top and front
%                         corresponding images
%           points      - a structure containing the points that were
%                          detected. This is probably not working well with the caltech
%                          toolbox
% ==================================================================
% NEB 2016 -- Commented and refactored: 2016_07_11
%%
% flags
saving = 1; % save the tiffs to the working directory
plotting = 1; % Show the images as the checkerboard is being detected

% set the number of frames to skip between detecting checkerboard. We dont
% want to detect on every frame because that would be overkill.


% determine the format of the video file
[~,~,extT] = fileparts(vFnameTop);
[~,~,extF] = fileparts(vFnameFront);
assert(strcmp(extT,extF));

% get video files
switch extT
    case '.seq'
        vTop = seqIo(vFnameTop,'r');
        vFront = seqIo(vFnameFront,'r');
        infoT = vTop.getinfo();
        infoF = vFront.getinfo();
        nFramesT = infoT.numFrames;
        nFramesF = infoF.numFrames;
        
    case '.avi'
        vTop = VideoReader(vFnameTop);
        vFront = VideoReader(vFnameFront);
        nFramesT = vTop.numberOfFrames;
        nFramesF = vFront.numberOfFrames;
end

assert(nFramesT == nFramesF,'Number of frames is inconsistent across videos')
numFrames = nFramesT;

% get frame limits
if length(varargin) < 2
    firstFrame = 2;
    lastFrame = numFrames;
elseif length(varargin)>2
    error('improper varargin. Too Many input Args')
else
    firstFrame = varargin{1};
    lastFrame = varargin{2};
end

% init vars
count = 0;
points = struct;
plots = figure;
I = struct;
map = hsv(numPts);

% read video and detect checkerboard
for i = firstFrame:stride:lastFrame
    
    % get the images
    switch extT
        
        case '.seq'
            vTop.seek(i-1);
            Itop = vTop.getframe();
            vFront.seek(i-1);
            Ifront = vFront.getframe();
            
        case '.avi'
            Itop = read(vTop,i-1);
            Ifront = read(vFront,i);
    end
    
    % get the checkerboard points
    tempTop =  detectCheckerboardPoints(Itop);
    tempFront = detectCheckerboardPoints(Ifront);
    
    % Check that we have all the points in both images
    if size(tempTop,1)~=numPts | size(tempFront,1)~=numPts
        continue
    end
    
    % write outputs
    count = count+1;
    points(count).frame = i;
    points(count).top = detectCheckerboardPoints(Itop);
    points(count).front = detectCheckerboardPoints(Ifront);
    I(count).top = Itop;
    I(count).front = Ifront;
    
    % save tiffs to working dir
    if saving
        imwrite(Itop,['top' num2str(count) '.tif']);
        imwrite(Ifront,['front' num2str(count) '.tif']);
    end
    
    % plot
    if plotting
        subplot(121)
        cla
        imshow(Itop)
        colormap('gray')
        hold on
        for j = 1:size(points(count).top,1)
            
            if mod(j,2)
                plot(points(count).top(j,1),points(count).top(j,2),'o','MarkerEdgeColor',map(j,:));
                
            else
                plot(points(count).top(j,1),points(count).top(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
        subplot(122)
        cla
        imshow(Ifront)
        colormap('gray')
        hold on
        
        for j = 1:size(points(count).front,1)
            if mod(j,2)
                plot(points(count).front(j,1),points(count).front(j,2),'o','MarkerEdgeColor',map(j,:));
            else
                plot(points(count).front(j,1),points(count).front(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
    end
    
    drawnow
    
end

close all force;


