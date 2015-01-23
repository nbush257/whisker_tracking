function playWhiskerTrackingVideo(seqPath,whiskerData,manipData,framesPerSecond,xBase,yBase,startFrame,stopFrame,xTol,yTol)
% function playWhiskerTrackingVideo(seqPath,whiskerData,manipData,framesPerSecond,xBase,yBase,startFrame,stopFrame,xTol,yTol)
%
% This function plays back a video at the specified frameRate
% (framesPerSecond) of the tracked whisker overlaid on the original
% video frames.
%
% Inputs:
% seqPath -- full path to the .seq video file.
%
% whiskerData -- structure from .whiskers file containing the tracked
% whisker data. Frames must be synched to the .seq video.
%
% manipData -- structure for manipulator data
%
% framesPerSecond -- desired speed of playback (e.g. 5 frames/second)
%
% startFrame -- frame to start video playback on (default 0)
%
% endFrame -- frame to end video playback on (default last frame with entry in .whiskers file)
%
% Optional inputs:
% xBase, yBase = x- and y- coordinates of the median basepoint across
% frames.
%
% xtol,yTol -- Deviations allowed from medianBasepoint in x/y directions (units of pixels).
%
% John Sheppard, 27 October 2014

if nargin < 9
    xTol = 5;
end

if nargin < 10
    yTol = 5;
end

if nargin < 8 || isempty(stopFrame)
    stopFrame = whiskerData(end).time;
end

if nargin < 7 || isempty(startFrame)
    startFrame = 0;
end

if nargin > 4
    framesPerSecond = 5;
end

seqObj = seqIo(seqPath,'r');
figure(1);

for frameCount = startFrame:stopFrame

    hold off;
    pause(.005);
    pause(max([1e-5,(1/framesPerSecond - .005)]));
    clf(1);
    seqObj.seek(frameCount);
    imshow(seqObj.getframe());
    title(['Frame #',num2str(frameCount)]);
    hold on;
    
    if exist('xBase','var');
        plot([xBase-xTol, xBase+xTol],[yBase-yTol, yBase-yTol],'w','linewidth',1);
        plot([xBase-xTol, xBase+xTol],[yBase+yTol, yBase+yTol],'w','linewidth',1);
        plot([xBase-xTol, xBase-xTol],[yBase-yTol, yBase+yTol],'w','linewidth',1);
        plot([xBase+xTol, xBase+xTol],[yBase-yTol, yBase+yTol],'w','linewidth',1);
    end
    
    thisFrameWhiskerIndexes = getWhiskerIndexesForFrame(frameCount,whiskerData);
    
    thisFrameManipIndexes = getWhiskerIndexesForFrame(frameCount,manipData);
    
    if ~isempty(thisFrameManipIndexes)
    plot(manipData(thisFrameManipIndexes).x, ...
        manipData(thisFrameManipIndexes).y, 'w-');
    end
    
    for count = 1:length(thisFrameWhiskerIndexes)
        
        thisFrameWhiskerIndexes = thisFrameWhiskerIndexes(1);
    if ~isempty(thisFrameManipIndexes)
        thisFrameManipIndexes = thisFrameManipIndexes(1);
    end
    
        if whiskerData(thisFrameWhiskerIndexes(count)).stableBasepoint
            plot(whiskerData(thisFrameWhiskerIndexes(count)).x, ...
                whiskerData(thisFrameWhiskerIndexes(count)).y, ...
                'go','MarkerSize',2);
            if ~isnan(whiskerData(thisFrameWhiskerIndexes).contactPointX)
                plot(manipData(thisFrameManipIndexes).manipX, ...
                    manipData(thisFrameManipIndexes).manipY, 'c-','linewidth',1);
                plot(whiskerData(thisFrameWhiskerIndexes).contactPointX, ...
                    whiskerData(thisFrameWhiskerIndexes).contactPointY, 'co','MarkerSize', 6,'MarkerFaceColor','c');
            elseif ~isempty(thisFrameManipIndexes)
                plot(manipData(thisFrameManipIndexes).manipX, ...
                    manipData(thisFrameManipIndexes).manipY, 'y-','linewidth',1);
            end
            
        else
            plot(whiskerData(thisFrameWhiskerIndexes(count)).x, ...
                whiskerData(thisFrameWhiskerIndexes(count)).y, ...
                'ro','MarkerSize',2);
            if ~isnan(whiskerData(thisFrameWhiskerIndexes).contactPointX)
                plot(manipData(thisFrameManipIndexes).manipX, ...
                    manipData(thisFrameManipIndexes).manipY, 'y-','linewidth',1);
                plot(whiskerData(thisFrameWhiskerIndexes).contactPointX, ...
                    whiskerData(thisFrameWhiskerIndexes).contactPointY, 'yo','MarkerSize', 6,'MarkerFaceColor','c');
            elseif ~isempty(thisFrameManipIndexes)
                plot(manipData(thisFrameManipIndexes).manipX, ...
                    manipData(thisFrameManipIndexes).manipY, 'y-','linewidth',1);
            end
        end
        
            if ~whiskerData(thisFrameWhiskerIndexes(count)).contigFrame || ~whiskerData(thisFrameWhiskerIndexes(count)).validLength
                plot(whiskerData(thisFrameWhiskerIndexes(count)).x, ...
                    whiskerData(thisFrameWhiskerIndexes(count)).y, ...
                    'ko','MarkerSize',2);
                if ~isnan(whiskerData(thisFrameWhiskerIndexes).contactPointX)
                    plot(manipData(thisFrameManipIndexes).manipX, ...
                        manipData(thisFrameManipIndexes).manipY, 'y-','linewidth',1);
                    plot(whiskerData(thisFrameWhiskerIndexes).contactPointX, ...
                        whiskerData(thisFrameWhiskerIndexes).contactPointY, 'yo','MarkerSize', 6,'MarkerFaceColor','c');
                elseif ~isempty(thisFrameManipIndexes)
                    plot(manipData(thisFrameManipIndexes).manipX, ...
                        manipData(thisFrameManipIndexes).manipY, 'y-','linewidth',1);
                end
            end
        
    end
end

end % EOF

function thisFrameWhiskerIndexes = getWhiskerIndexesForFrame(frameNumber,whiskerData)
% function thisFrameWhiskerIndexes = getWhiskerIndexesForFrame(frameNumber,whiskerData)

thisFrameWhiskerIndexes = find( [whiskerData.time] == frameNumber  );

%{
   thisFrameWhiskerIndexes= [];
   for count = 1:length(whiskerData)
       if whiskerData(count).time == frameNumber
           thisFrameWhiskerIndexes = [thisFrameWhiskerIndexes, count];
       end
   end
%}

end % EOF
