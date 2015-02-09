function [ManipOut,ManipOutAllPixels] = findManip(varargin)
% needs something to tell when there is movement.


% ManipOut =
% findManip(frameStack)
% or findManip(vidFileName,firstFrameNum,lastFrameNum)
if length(varargin) == 1
    frames = varargin{1};
else
    vidFileName = varargin{1};
    firstFrameNum = varargin{2};
    lastFrameNum = varargin{3};
    
    
    if strcmp(vidFileName(end-3:end),'.seq')
        v = seqIo(vidFileName,'r');
        count = 0;
        for i = firstFrameNum:lastFrameNum
            count = count +1;
            v.seek(i);
            f = v.getframe();
            frames(:,:,count) = f;
        end
    elseif strcmp('.avi',vidFileName(end-3:end))
        v = VideoReader(vidFileName);
        frames = v.read([firstFrameNum lastFrameNum]);
        frames = squeeze(frames(:,:,1,:));
    else
        fprintf('No Video File Loaded')
        
        
    end
end


numberOfFrames = size(frames,3);
FirstFrame = squeeze(frames(:,:,1));


%%%%%  Get appeoximate manipulator position in frame 1

disp('track the manipulator');
fig1;set(gcf,'color','w');
imagesc(FirstFrame); colormap('gray'); hold on;title('zoom in on manipulator');zoom on; pause;
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



%%%% Find an  ROI around the manipulator and find all pixels within it.

N = 10;  % amount to grow ROI around the manually tracked manipulator
[p] = polyfit(xm,ym,1);
xmsmooth = round(min(xm):1:max(xm));
ymsmooth = round(polyval(p,xmsmooth));
foo = zeros(size(FirstFrame));
%%% There must be a better way to do these next three lines
for k = 1:length(xmsmooth)
    %     foo((ymsmooth(i)-min(ymsmooth))+1,(xmsmooth(i)-min(xmsmooth))+1) = 1;
    foo(ymsmooth(k),xmsmooth(k)) = 1;
end;
bw = logical(foo);
bw = bwmorph(bw,'dilate',N);
ManipROI = bw;
s = regionprops(bw,'pixellist');
xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1));
yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
xoffset = min(xvals); yoffset = min(yvals);
FirstFrame_Manip = FirstFrame(yvals,xvals);
xm = s.PixelList(:,1); ym = s.PixelList(:,2);


ManipOutAllPixels{1} = [xm';ym'];
p = polyfit(xm,ym,1);
xmm = round(min(xm)):round(max(xm));
ymm = polyval(p,xmm);
ManipOut{1} = [xmm;ymm];


%
% %only edge detect on ROI in N pixels
% foobar = edge(FirstFrame_Manip,'sobel');
% foobar = foobar.*bw(yvals,xvals);
% [h,t,r]=hough(foobar);
% p = houghpeaks(h,2);
% lines = houghlines(foobar,t,r,p);
% counter = 0;
%
% if length(lines)
%     for ii =1:length(lines)
%         l(ii) = sqrt((lines(ii).point1(1) - lines(ii).point2(1))^2 + (lines(ii).point1(2) - lines(ii).point2(2))^2);
%     end
%     [~,idx] = max(l);
% lines = lines(idx);
% end
%


% xvals = [lines.point1(1),lines.point2(1)];
% yvals = [lines.point1(2),lines.point2(2)];
% xvals = [min(xvals), max(xvals)] + xoffset -1;
% yvals = yvals+yoffset-1;
%
% [bw,xi,yi]=roipoly(FirstFrame,xvals,yvals);
% [m,n]=size(FirstFrame);
% BW = poly2mask(xi,yi,m,n);
% s = regionprops(BW,'pixellist');
%
% xm = s.PixelList(:,1); ym = s.PixelList(:,2);
% ManipOutAllPixels{1} = [xm';ym'];
% p = polyfit(xm,ym,1);
% xmm = round(min(xm)):round(max(xm));
% ymm = polyval(p,xmm);
% ManipOut{1} = [xmm;ymm];

%% Iterate through all the frames
FrameCounter = 1;
wait = waitbar(0,'Finding the Manipulator');
%compare = figure;

for i = 2:numberOfFrames;
    if ~mod(i, 100)
        waitbar(i/numberOfFrames,wait)
    end
    FrameCounter = FrameCounter + 1;
    FrameN = squeeze(frames(:,:,i));
    
    N = 5; % Increase previos ROI by same num of pixels
    
    s = regionprops(ManipROI,'pixellist');
    xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1));
    yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
    xoffset = min(xvals); yoffset = min(yvals);
    FrameN_Manip = FrameN(yvals,xvals);
    
    foobar = edge(FrameN_Manip,'sobel');
    foobar = foobar.*ManipROI(yvals,xvals);
    [h,t,r]=hough(foobar);
    
    
    p = houghpeaks(h,2);
    lines = houghlines(foobar,t,r,p);
    counter = 0;
    
    if length(lines)>1
        for ii =1:length(lines)
            l(ii) = sqrt((lines(ii).point1(1) - lines(ii).point2(1))^2 + (lines(ii).point1(2) - lines(ii).point2(2))^2);
        end
        [~,idx] = max(l);
        lines = lines(idx);
    end
    xm = [lines.point1(:,1) lines.point2(:,1)];
    ym = [lines.point1(:,2) lines.point2(:,2)];
    xm = xm + xoffset - 1;
    ym = ym +yoffset - 1;
    p = polyfit(xm,ym,1);
    
    xmsmooth = round(min(xm):1:max(xm));
    ymsmooth = round(polyval(p,xmsmooth));
    mask = zeros(size(FrameN));
    %%% There must be a better way to do these next three lines
    for k = 1:length(xmsmooth)
        mask(ymsmooth(k),xmsmooth(k)) = 1;
    end;
    
    bw = logical(mask);
    bw = bwmorph(bw,'dilate',N);
    
    s = regionprops(mask,'pixellist');
    ManipROI = bw;
    
    xm = s.PixelList(:,1); ym = s.PixelList(:,2);
    ManipOutAllPixels{FrameCounter} = [xm';ym'];
    p = polyfit(xm,ym,1);
    xmm = round(min(xm)):round(max(xm));
    ymm = polyval(p,xmm);
    ManipOut{FrameCounter} = [xmm;ymm];
    
    %% plotting checks
    %    figure(compare);
    %         comp = bw.*double(FrameN);
    %         comp = uint8(comp);
    %         subplot(221);imshow(bw);subplot(222);imshow(FrameN);subplot(224); imshow(comp);
    %         pause;
    %
end
waitbar(1,wait,'all done');