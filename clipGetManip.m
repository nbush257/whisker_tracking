function [ManipOut,ManipOutAllPixels]= clipGetManip(videoObj,initialROI,startFrame,endFrame);
%% want to add functionality that only looks for lines in an angle close to the previous angle of the manipulator.
%frame numbers are referenced to entire video, the first frame indexes at
%1;

global N
thetaThresh = 5;
plotting = 0;
lastwarn('overwrite');
N = 15; %size to dilate the ROI
if iscell(initialROI)
    initialROI =initialROI{1};
end
isSeq = isstruct(videoObj);

ManipROI = initialROI;
prevTheta = [];
message = getWaitMessage;
w = waitbar(0,message);
observe = figure;
title('Observe')
manTracked = 0;
global retrack
tic;
count = 0;
for ii = startFrame+1:endFrame
    count = count+1;
    %% User monitoring
    timer = toc;
    if timer>2;
        tic
        message = getWaitMessage;
        if ~exist('observe')
            observe = figure;
            title('Observe')
        end
        
        clf
        imshow(FrameN);ho
        scatter(ManipOut(ii-1).x,ManipOut(ii-1).y);
    end
    waitbar((ii-startFrame)/(endFrame-startFrame),w,message);
    %% Get the current Frame
    if isSeq
        videoObj.seek(ii-1);
        FrameN = videoObj.getframe();
    else
        FrameN = read(videoObj,count);
        FrameN = squeeze(FrameN(:,:,1));
    end
    
    FrameN = medfilt2(FrameN,[3 3]);
    
    % Use the previous manipROI to defint the current region of
    % investigation
    s = regionprops(ManipROI,'pixellist');
    xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1)); % if this throws an error you can try increasing your ROI dilation.
    yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
    xoffset = min(xvals); yoffset = min(yvals);
    FrameN_Manip = FrameN(yvals,xvals);
    % Line Detect
    manipEdge = edge(FrameN_Manip,'canny');
    [h,t,r]=hough(manipEdge);
    p = houghpeaks(h,2);
    lines = houghlines(manipEdge,t,r,p,'MinLength',10);
    
    if ii == startFrame + 1
        if length(lines)==0
            prevTheta = t(p(1,2));
        else
            prevTheta = mean([lines.theta]);
        end
    end
    
    if length(lines)>1
        lines = lines(1:2);
        if abs(lines(1).theta-lines(2).theta)<=2% the threshold for parallel is 2 degrees
            %% if we find two parallel lines, take the average.
            % If the lines are not near o the previous theta, check for
            % retrack
            if abs(mean([lines.theta]-prevTheta))>thetaThresh
                figure
                imshow(FrameN)
                ho
                plot([lines(1).point1(1)+xoffset-1 lines(1).point2(1)+xoffset-1],[lines(1).point1(2)+yoffset-1 lines(1).point2(2)+yoffset-1], 'go')
                
                try
                    
                    plot([lines(2).point1(1)+xoffset-1 lines(2).point2(1)+xoffset-1],[lines(2).point1(2)+yoffset-1 lines(2).point2(2)+yoffset-1], 'go')
                end
                %scatter(xmsmooth,ymsmooth)
                title('Should we manually track?')
                retrack = 0;
                rt = uicontrol('Style','Pushbutton','String','Retrack','Position',[0 0 200 20],'Callback','global retrack; retrack = 1;uiresume(gcbf)');
                uiwait(gcf)
                close all
                if retrack
                    %retrack function
                    [xmsmooth,ymsmooth,ManipROI] = retrackManip(FrameN);
                    retrack = 0;
                    manTracked = 1;
                else % if we don't retrack we take the line closest to the previous theta
                    p1(1) = mean([lines(1).point1(1) lines(2).point1(1)]);
                    p1(2) = mean([lines(1).point1(2) lines(2).point1(2)]);
                    p2(1) = mean([lines(1).point2(1) lines(2).point2(1)]);
                    p2(2) = mean([lines(1).point2(2) lines(2).point2(2)]);
                    dumtheta =mean([lines.theta]);
                    lines =struct;
                    lines.point1 = p1;
                    lines.point2 = p2;
                    lines.theta = dumtheta; clear dumtheta;
                    
                end
            else % if the lines are parallel and not far from previous theta then take the mean
                p1(1) = mean([lines(1).point1(1) lines(2).point1(1)]);
                p1(2) = mean([lines(1).point1(2) lines(2).point1(2)]);
                p2(1) = mean([lines(1).point2(1) lines(2).point2(1)]);
                p2(2) = mean([lines(1).point2(2) lines(2).point2(2)]);
                dumtheta =mean([lines.theta]);
                lines =struct;
                lines.point1 = p1;
                lines.point2 = p2;
                lines.theta = dumtheta; clear dumtheta;
            end
        else % if the lines are not parallel, take the line closest to the old theta
            [~,idx] = min(abs([lines.theta]-prevTheta));
            lines = lines(idx);
        end
    end
    %%
    
    if isempty(lines)
        
        disp('Manually track because lines was empty')
        [xmsmooth,ymsmooth,ManipROI] = retrackManip(FrameN);
        
        ManipOut(ii).x = xmsmooth;
        ManipOut(ii).y = ymsmooth;
        ManipOut(ii).time = ii;
        
        ManipOutAllPixels(ii).x = xmsmooth;
        ManipOutAllPixels(ii).y = ymsmooth;
        ManipOutAllPixels(ii).time = ii;
        continue
    end
    % if there is only one line, extract those
    if ~isempty(lines) & length(lines)==1
        
        xm = [lines.point1(:,1) lines.point2(:,1)];
        ym = [lines.point1(:,2) lines.point2(:,2)];
        xm = xm + xoffset - 1;
        ym = ym +yoffset - 1;
        p = polyfit(xm,ym,1);
        
        [warner,~] = lastwarn;
        if strcmp(warner,'Polynomial is badly conditioned. Add points with distinct X values, reduce the degree of the polynomial, or try centering and scaling as described in HELP POLYFIT.')
            p = polyfit(ym,xm,1);
            
            ymsmooth = (min(ym):.2:max(ym));
            xmsmooth = round(polyval(p,ymsmooth));
            ymsmooth = round(ymsmooth);
        else
            xmsmooth = (min(xm):.2:max(xm));
            ymsmooth = round(polyval(p,xmsmooth));
            xmsmooth = round(xmsmooth);
        end
        
        
        
        if abs(lines.theta-prevTheta)>thetaThresh & ii~=startFrame+1 %
            warning(['manipulator angle jumped at frame ' num2str(ii)])
            figure
            imshow(FrameN)
            ho
            
            
            scatter(xmsmooth,ymsmooth)
            title('Should we manually track?')
            retrack = 0;
            rt = uicontrol('Style','Pushbutton','String','Retrack','Position',[0 0 200 20],'Callback','global retrack; retrack = 1;uiresume(gcbf)');
            uiwait(gcf)
            close all
            if retrack
                %retrack function
                [xmsmooth,ymsmooth,ManipROI] = retrackManip(FrameN);
                retrack =0;
                
            end
            
        else
            prevTheta = lines.theta;
        end
        
        
        mask = zeros(size(FrameN));
        %%% There must be a better way to do these next three lines
        for k = 1:length(xmsmooth)
            mask(ymsmooth(k),xmsmooth(k)) = 1;
        end;
        
        bw = logical(mask);
        
        se = strel('disk',N);
        bw = imdilate(bw,se);
        if size(bw)~=size(FrameN)
            warning(['size of ROI is different from the frame at frame ' num2str(ii)]);
        end
        
        s = regionprops(bw,'pixellist');
        ManipROI = bw;
        
        
        xPixels = s.PixelList(:,1); yPixels = s.PixelList(:,2);
        ManipOutAllPixels(ii).x = xPixels';
        ManipOutAllPixels(ii).y = yPixels';
        ManipOutAllPixels(ii).time = ii;
        
        p = polyfit(xm,ym,1);
        if p(1) ==0
            pause
        end
        
        
        ManipOut(ii).x = xmsmooth;
        ManipOut(ii).y = ymsmooth;
        ManipOut(ii).time = ii;
        
        if plotting
            subplot(221)
            imshow(ManipROI);ho;plot(xm,ym);
            subplot(222)
            imshow(FrameN);ho;plot(xm,ym);
            subplot(223)
            imshow(FrameN_Manip);
            subplot(224)
            imshow(manipEdge)
            pause(.01);
            
            clf;
        end
        
    elseif manTracked==1 & ~isempty(lines)
        ManipOut(ii).x = xmsmooth;
        ManipOut(ii).y = ymsmooth;
        ManipOut(ii).time = ii;
        
        ManipOutAllPixels(ii).x = ManipOutAllPixels(ii-1).x;
        ManipOutAllPixels(ii).y = ManipOutAllPixels(ii-1).y;
        ManipOutAllPixels(ii).time = ii;
        
    else
        warning(['Unknown error occurred at frame ' num2str(ii) ', setting the manipulator equal to the last frame'])
        ManipOut(ii).x = xmsmootManipOut(ii-1).x;
        ManipOut(ii).x = xmsmootManipOut(ii-1).y;
        ManipOut(ii).time = ii;
        
        ManipOutAllPixels(ii).x = ManipOutAllPixels(ii-1).x;
        ManipOutAllPixels(ii).y = ManipOutAllPixels(ii-1).y;
        ManipOutAllPixels(ii).time = ii;
    end
    
    
end
delete(w)
close all force
end%EOF

function [xmsmooth,ymsmooth,ROI] = retrackManip(frame)
global N
disp('track the manipulator');
fig;set(gcf,'color','w');
imagesc(frame); colormap('gray'); hold on;title('zoom in on manipulator');
title('track the manipulator')
x = NaN;
counter  = 0;
while ~isempty(x)
    counter = counter + 1;
    [x,y] = ginput(1);
    if ~isempty(x)
        xm(counter)= x;  ym(counter) = y;
        plot(xm(counter),ym(counter),'g*');
    end;
end;
close all

% amount to grow ROI around the manually tracked manipulator
[p] = polyfit(xm,ym,1);
xmsmooth = min(xm):.2:max(xm);
ymsmooth = round(polyval(p,xmsmooth));
xmsmooth = round(xmsmooth);

% makes sure xmsmooth and ymsmooth do not exceed frame size
idx = xmsmooth>size(frame,2) | ymsmooth>size(frame,1);
xmsmooth(idx) = [];
ymsmooth(idx) = [];

bw = logical(zeros(size(frame)));
for i = 1:length(xmsmooth)
    bw(ymsmooth(i),xmsmooth(i)) = 1;
end

se = strel('disk',N);
ROI = imdilate(bw,se);



end %EOLF












