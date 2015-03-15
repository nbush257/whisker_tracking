function [ManipOut,ManipOutAllPixels]= clipGetManip(seqObj,initialROI,startFrame,endFrame);
%% want to add functionality that only looks for lines in an angle close to the previous angle of the manipulator.
%frame numbers are referenced to entire video, the first frame indexes at
%1;
thetaThresh = 5;
plotting = 0;
lastwarn('overwrite');
N = 25; %size to dilate the ROI
if iscell(initialROI)
    initialROI =initialROI{1};
end
ManipROI = initialROI;
prevTheta = [];
message = getWaitMessage;
w = waitbar(0,message);
observe = figure;
global retrack
tic;
for ii = startFrame+1:endFrame
    timer = toc;
    if timer>20;
        tic
        message = getWaitMessage;
        figure(observe)
        clf
        imshow(FrameN);ho
        scatter(ManipOut(ii-1).x,ManipOut(ii-1).y);
    end
    
        
    
    
    waitbar((ii-startFrame)/(endFrame-startFrame),w,message);
    
    
    
    seqObj.seek(ii-1);
    FrameN = seqObj.getframe();
    
    
    s = regionprops(ManipROI,'pixellist');
    xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1)); % if this throws an error you can try increasing your ROI dilation.
    yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
    xoffset = min(xvals); yoffset = min(yvals);
    
    FrameN_Manip = FrameN(yvals,xvals);
    manipEdge = edge(FrameN_Manip,'canny');
    [h,t,r]=hough(manipEdge);
    p = houghpeaks(h,2);
    lines = houghlines(manipEdge,t,r,p);
    if ii == startFrame + 1
        prevTheta = mean([lines.theta]);
    end
    
    if length(lines)>1

        if abs(lines(1).theta-lines(2).theta)<=2
            %% if we find two parallel lines, take the average.
            %first check that it is close to the old theta
            
            if abs(mean([lines.theta]-prevTheta))>thetaThresh
                figure
                imshow(FrameN)
                ho
                scatter(xmsmooth,ymsmooth)
                title('Should we manually track?')
                retrack = 0;
                rt = uicontrol('Style','Pushbutton','String','Retrack','Position',[0 0 200 20],'Callback','global retrack; retrack = 1');
                pause
                close all
                if retrack
                    %retrack function
                    [xmsmooth,ymsmooth] = retrackManip(FrameN);
                end
            else
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
            
        else %% if the lines are not parallel, take the line closest to the old theta
            [~,idx] = min(abs([lines.theta]-prevTheta));
            lines = lines(idx);
        end
        
        %% take the longest line
        %         else
        %             l = [];
        %             for jj =1:length(lines)
        %                 l(jj) = sqrt((lines(jj).point1(1) - lines(jj).point2(1))^2 + (lines(jj).point1(2) - lines(jj).point2(2))^2);
        %             end
        %             [~,idx] = max(l);
        %             lines = lines(idx);
        %         end
    end
    
    
    if ~isempty(lines)
        
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
            rt = uicontrol('Style','Pushbutton','String','Retrack','Position',[0 0 200 20],'Callback','global retrack; retrack = 1');
            pause
            close all
            if retrack
                %retrack function
                [xmsmooth,ymsmooth] = retrackManip(FrameN);
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
        
    else
        warning(['no line found at frame ' num2str(ii)])
    end
    
end
delete(w)
close all force
end%EOF

function [xmsmooth,ymsmooth] = retrackManip(frame)
disp('track the manipulator');
fig;set(gcf,'color','w');
imagesc(frame); colormap('gray'); hold on;title('zoom in on manipulator');zoom on; pause;
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
end %EOLF












