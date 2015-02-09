% This can absolutely be parallelized in gpu. Figure this out
function allChange = isManipPresent_v2(vidFileName,varargin);
% allChange = isManipPresent_v2(vidFileName,[eThresh],[mask]);

% Helps you find parts of the video when some manipulation is present. The
% algorithm uses edge detection to be robust to changes in overall
% illuminence. A faster algorithm would be to just look for changes in
% pixel values but flicker can frequently flood these changes.

% INPUTS: 
    % vidFileName: path where the video file is. Currently only takes .seq
        % For the future, allow arbitrary video or tif stack. This should be
        % pretty easy
    
    % eThresh: the threshold to apply when using the edge detection. This
        % might depend on the quality of your data. Default allows the
        % function to pick the default;
    
    % mask: ROI where we want to check for the manipulator. Useful to pre determine the ROIs if you
        % want to batch process a lot of videos.
        
% OUTPUTS:  
    
    % allChange: is a 1x[numFrames] vector which tells you about the amount
    % of edges detected in the ROI. You can set a threshold and it will
    % tell you when something is happening in the frame. 
    
% Nick Bush 2/4/2015

%% 

eThresh = [];

v = seqIo(vidFileName,'r');
info = v.getinfo();

maxPerIter = 5000; % Split the video so you don't run out of memory.
numIters = ceil(info.numFrames/maxPerIter);
allOut = [];
v.seek(0);
firstFrame = v.getframe();


% Checks for the optional arguments
if length(varargin)==1
    bw = roipoly(firstFrame); %asks you to set the ROI if needed
    eThresh = varargin{1};
    ca;
elseif length(varargin)>1
    eThresh = varargin{1};
    bw = varargin{2};
else
    bw = roipoly(firstFrame);
    close all;
end

allChange = []; %initialize the output variable. 
tic;

% Iterate over each clip in the video file sequentially
for kk = 1:numIters
    disp(['Working on batch ' num2str(kk) ' of ' num2str(numIters)]);
   
    % determine the number of frames in this clip. Important particularly
    % for last clip which is variable length.
    if kk == numIters
        numFramesInIter = mod(info.numFrames,maxPerIter);
    else
        numFramesInIter = maxPerIter;
    end
    
%     % For verbose
%     hundreds = [1:round(numFramesInIter/100):numFramesInIter];
%     tens = [1:round(numFramesInIter/10):numFramesInIter];
    
    
    % Initialize frames
    clear frames;
    frames(info.height,info.width,numFramesInIter) = uint8(0);
   
    
    % Reference the clip frames to the overall frames
    startFrame = (kk-1)*maxPerIter+1;
    endFrame = startFrame + numFramesInIter-1;
    
    fprintf('\t loadingFrames')
    
    c = 0;% c is an index within clip starting at 1
    
    % Load in the clip.
    for i = startFrame:endFrame
        if endFrame>=size(frames,3)
            c = c+1;
            v.seek(i-1); % Seqs are indexed at 0 
            frames(:,:,c) = v.getframe();
        end
    end
    
    % Initialize the clip specific output variable.
    change = zeros(1,length(numFramesInIter));
    fprintf('\t gettingedges \n');
    % Iterate over every frame. This uses parallel computing. If you need
    % to avoid this, remove the parfor and alternate the comments
    parfor i = 1:numFramesInIter
        %         if any(i==hundreds)
        %             fprintf('.')
        %         end
        %         if any(i == tens);
        %             fprintf('\n');
        %         end
        %   e = edge(frames(:,:,i),eThresh);
        
        
         e = edge(gpuArray(frames(:,:,i)),eThresh); % comment this if not parallel
         e = gather(e); % Comment this if not parallel.
         %e = edge(frames(:,:,i),'canny',eThresh);
        
        e_masked = e.*bw;
        change(i) = sum(sum(e_masked)); % Get sum of edges in the ROI.
    end
    allChange = [allChange change];% Send clip output to overall output. 
end
toc;
