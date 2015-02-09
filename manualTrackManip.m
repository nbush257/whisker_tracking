% manual track manipulator
function [ManipROI,ManipOut,ManipOutAllPixels] = manualTrackManip(frame)

%%%%%  Get appeoximate manipulator position in frame 1

disp('track the manipulator');
fig1;set(gcf,'color','w');
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



%%%% Find an  ROI around the manipulator and find all pixels within it.

N = 10;  % amount to grow ROI around the manually tracked manipulator
[p] = polyfit(xm,ym,1);
xmsmooth = round(min(xm):1:max(xm));
ymsmooth = round(polyval(p,xmsmooth));


foo = zeros(size(frame));
%%% There must be a better way to do these next three lines
for k = 1:length(xmsmooth)
    %     foo((ymsmooth(i)-min(ymsmooth))+1,(xmsmooth(i)-min(xmsmooth))+1) = 1;
    foo(ymsmooth(k),xmsmooth(k)) = 1;
end;

se = strel('disk',N);
bw = logical(foo);
bw = imdilate(bw,se);

ManipROI = bw;
s = regionprops(bw,'pixellist');
xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1));
yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
xoffset = min(xvals); yoffset = min(yvals);
FirstFrame_Manip = frame(yvals,xvals);
xm = s.PixelList(:,1); ym = s.PixelList(:,2);


ManipOutAllPixels{1} = [xm';ym'];
p = polyfit(xm,ym,1);
xmm = round(min(xm)):round(max(xm));
ymm = polyval(p,xmm);
ManipOut{1} = [xmm;ymm];

