% detect movement
%% get the video
v = seqIo(vidFileName,'r');
info = v.getinfo();

maxPerIter = 5000;
numIters = ceil(info.numFrames/maxPerIter);
allOut = [];
for kk = 1:numIters
    if kk == numIters
        numFramesInIter = mod(info.numFrames,maxPerIter);
    else
        numFramesInIter = maxPerIter;
    end
    
    
    clear frames;
    frames(info.height,info.width,numFramesInIter) = uint8(0);
    %frames = zeros(info.height,info.width,numFramesInIter);
    %frames = uint8(frames);
    c = 0;
    
    startFrame = (kk-1)*maxPerIter+1;
    endFrame = startFrame + numFramesInIter;
    
    
    for i = startFrame:endFrame%info.numFrames On this machine we can't go much above maxPerIter frames at once
        c = c+1;
        v.seek(i);
        frames(:,:,c) = v.getframe();
    end
    
    counter = 0;
    check = 0;
    in = [];
    while check == 0;
        counter = counter +100;
        imshow(squeeze(frames(:,:,counter)));
        in = ginput(2);
        if isempty(in)
            check = 0;
        else
            check = 1;
        end
    end
    ca
    [~,direction] = min(abs(in(1,:)-in(2,:)));
    
    if direction == 1
        lines = frames(:,in(:,direction),:);
    elseif direction == 2
        lines = frames(in(:,direction),:,:);
    else
        disp('You broke everything');
        break
    end
    
    
    
    [~,m] = min([in(1) in(2) (640 - in(1)) (480 - in(2))]);
    
    if m == 1
        line = frames(1:480,1,:);
    elseif m == 2
        line = frames(1,1:640,:);
    elseif m == 3
        line = frames(1:480,640,:);
    elseif m ==4
        line = frames(480,1:640,:);
    end
    clear frames;
    
    line = squeeze(line);
    
    e = edge(line,'canny',.5);
    
    fig;imshow(line);fig; imshow(e);title('set limits on where to detect edges');zoom on; pause;
    
    ignore = ginput;
    if size(ignore,1) == 1
        ignore(2,2) = 0;
        ignore = sort(ignore(:,2));
    elseif size(ignore,1) == 2
        ignore = sort(ignore(:,2));
    else
        ignore = sort(ignore(:,1:2));
    end
    
    
    a = sum(e(ignore(1):ignore(2),:));
    fig
    plot(a)
    title('Zoom, then click on the threshold for manip presentation');zoom on; pause;
    t = ginput(1);
    if ~isempty(t)
        t = t(2);
    else
        t = inf;
    end
    ca;
    
    out = zeros(length(a),1);
    out(a>t) = 1;
    out = logical(out);
    allOut = [allOut;out];
    close all;
end
