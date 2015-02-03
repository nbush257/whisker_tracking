ca;clc;

%%%% In each frame, start with:
%%%% The smoothed polynomial whisker from the previous frame
%%%% The x and y pixels of the manipulator from the previous frame

%%% Find roi_M around the manipulator of the previous frame
%%% Impose roi_M on the current frame, and find the manipulator within it
%%% Call the points on the manipulator xm and ym.  The center (mean) of the
%%% manipulator we will store in the variables xmm and ymm
%%% Store these points in ManipOutAllPixels{} = [xm;ym];
%%% Store the average manipulator posiiton in ManipOut{} = [xmm; ymm];


%%% Find roi_W around the full whisker of the previous frame
%%% Split roi_W based on xm and ym.  Call these roip and roid for proximal
%%% and distal
%%% Use edge detection to find the whisker in roip and roid
%%% Store these points in WhiskerOutNotSmooth{};
%%% Fit a polynomial to the whisker points in roip and roid together
%%% Store these points in  WhiskerOut{};


f = rgb2gray(f);
FirstFrame = f;%imread('141023_rat1442_gamma_1_fr_05150.tif');

%%%%%  Get initial whisker position (track entire thing) in frame 1
if exist('FirstTrackedWhiskerPoints.mat','file') == 2
    load FirstTrackedWhiskerPoints
elseif exist('FirstTrackedWhiskerPoints.mat','file') == 0
    disp('track the whisker');
    fig1;set(gcf,'color','w');
    imagesc(FirstFrame); axis([ 140  430  275  355]);colormap('gray'); hold on;
    x = NaN;
    counter  = 0;
    while ~isempty(x)
        counter = counter + 1;
        [x,y] = ginput(1);
        if ~isempty(x)
            xw(counter)= x;  yw(counter) = y;
            plot(xw(counter),yw(counter),'y.');
        end;
    end;
    save FirstTrackedWhiskerPoints xw yw;
end;

%%%% Fit a polynomial to the manual tracked whisker
%%% CONCERN: polynomial may be badly conditioned if the whisker
%%% is rotated funny
[p] = polyfit(xw,yw,3);
xwsmooth = min(xw):1:max(xw);
ywsmooth = polyval(p,xwsmooth);
WhiskerOutNotSmooth{1} = [xw;yw];
WhiskerOut{1}= [xwsmooth;ywsmooth];


%%%%%  Get appeoximate manipulator position in frame 1
if exist('FirstTrackedManipulatorPoints.mat','file') == 2
    load FirstTrackedManipulatorPoints;
elseif exist('FirstTrackedManipulatorPoints.mat','file')== 0
    disp('track the manipulator');
    fig1;set(gcf,'color','w');
    imagesc(FirstFrame); colormap('gray'); hold on;
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
    save FirstTrackedManipulatorPoints xm ym;
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
s = regionprops(bw,'pixellist');
xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1));
yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
xoffset = min(xvals); yoffset = min(yvals);
FirstFrame_Manip = FirstFrame(yvals,xvals);
foobar = edge(FirstFrame_Manip,'sobel');
[h,t,r]=hough(foobar);
p = houghpeaks(h,2);
lines = houghlines(foobar,t,r,p);
counter = 0;
xvals = [lines(1).point1(1),lines(2).point1(1),lines(1).point2(1),lines(2).point2(1)];
yvals = [lines(1).point1(2),lines(2).point1(2),lines(2).point2(2),lines(1).point2(2)];
xvals = [min(xvals), min(xvals), max(xvals), max(xvals)] + xoffset -1;
yvals = yvals+yoffset-1;

[bw,xi,yi]=roipoly(FirstFrame,xvals,yvals);
[m,n]=size(FirstFrame);
BW = poly2mask(xi,yi,m,n);
s = regionprops(BW,'pixellist');

xm = s.PixelList(:,1); ym = s.PixelList(:,2);
ManipOutAllPixels{1} = [xm';ym'];
p = polyfit(xm,ym,1);
xmm = round(min(xm)):round(max(xm));
ymm = polyval(p,xmm);
ManipOut{1} = [xmm;ymm];


% CP{1} = BW.*


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  SANITY CHECK PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,4,1);
imagesc(FirstFrame); colormap('gray'); hold on;
plot(xwsmooth,ywsmooth,'y.');
plot(xmsmooth,ymsmooth,'g.');

subplot(3,4,2);
imagesc(FirstFrame_Manip);ho;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
end;

subplot(3,4,3);
imagesc(FirstFrame); ho;
plot(xvals,yvals,'y.');

subplot(3,4,4);
imagesc(FirstFrame); ho;
plot(xm,ym,'y.');
plot(xmm,ymm,'g.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Find roi_W around the full whisker of the previous frame
%%% Split roi_W based on xm and ym.  Call these roip and roid for proximal
%%% and distal
%%% Use edge detection to find the whisker in roip and roid
%%% Store these points in WhiskerOutNotSmooth{};
%%% Fit a polynomial to the whisker points in roip and roid together
%%% Store these points in  WhiskerOut{};

FrameCounter = 1;

for i = 5151:5180 % 5151:5180
    
    FrameCounter = FrameCounter + 1;
    eval(['FrameN = imread(''141023_rat1442_gamma_1_fr_0' int2str(i) '.tif'',''tif'');']);
    
    %%% Find roi_W around the full whisker of the previous frame
    data = WhiskerOut{FrameCounter - 1};
    xpixels = round(data(1,:));  ypixels = round(data(2,:));
    N = 5;
    foo = zeros(size(FrameN));
    for k = 1:length(xpixels)
        foo(ypixels(k),xpixels(k)) = 1;
    end;
    bw = logical(foo);
    roi_W = bwmorph(bw,'dilate',N);
    s_W = regionprops(roi_W,'pixellist');
    
    %%%% Split roi_W based on xm and ym.
    %%%% Ideally we would call these roip and roid
    %%%% but let's see if we can avoid making any
    %%%% assumptions about which region is proximal
    %%%% and which is distal.  So we will just call them
    %%%% roi1 and roi2
    
    data = ManipOutAllPixels{FrameCounter - 1};
    xpixels = round(data(1,:));  ypixels = round(data(2,:));
    N = 1;
    foo = zeros(size(FrameN));
    for k = 1:length(xpixels)
        foo(ypixels(k),xpixels(k)) = 1;
    end;
    bw = logical(foo);
    roi_M = bwmorph(bw,'dilate',N);
    s_M = regionprops(roi_M,'pixellist');
    
    roi_CP = roi_W.*roi_M;  % region around contact point
    SplitWhisker  = roi_W.*~(roi_CP);
    s = regionprops(logical(SplitWhisker),'all');
    
    
    subplot(3,4,5);cla;
    imagesc(FrameN.*uint8(roi_M)); title([int2str(i) ',roiM']); axis([113.1317  463.7929  270.6227  361.6242]);
    subplot(3,4,6);cla;
    imagesc(FrameN.*uint8(roi_CP));  title([int2str(i) ', CP']); axis([113.1317  463.7929  270.6227  361.6242]);
    subplot(3,4,7);cla;
    imagesc(FrameN.*uint8(SplitWhisker));title([int2str(i) ', SplitWhisker']); axis([113.1317  463.7929  270.6227  361.6242]);
    
    roi1 = zeros(size(FrameN));
    roi1(s(1).PixelIdxList) = 1;
    roi2 = zeros(size(FrameN));
    roi2(s(2).PixelIdxList) = 1;
    
    % %     %%%%% First region -- edge detection method
    % %     threshval = 0.03
    % %     meanval = mean(mean(FrameN(s(1).PixelIdxList)));
    % %     foo = zeros(size(FrameN))+ meanval;
    % %     foo(s(1).PixelIdxList) = FrameN(s(1).PixelIdxList);
    % %     dum = [2,2,2;2,1,2;2,2,2];
    % %     foo = conv2(double(foo),dum);
    % %     foo = foo(2:end-1,2:end-1);
    % %     foo = foo - min(min(foo));
    % %     foo = foo./max(max(foo));
    % %     foobar = edge(foo,threshval);
    % %     foobar = foobar & roi1;
    % %     [a1,b1]=find(foobar == 1);
    
    %%%%% First region -- darkest pixel method
    meanval = mean(mean(FrameN(s(1).PixelIdxList)));
    foo = zeros(size(FrameN))+ meanval;
    foo(s(1).PixelIdxList) = FrameN(s(1).PixelIdxList);
    dum = [2,2,2;2,1,2;2,2,2];
    foo = conv2(double(foo),dum);
    foo = foo(2:end-1,2:end-1);
    foo = foo - min(min(foo));
    foo = foo./max(max(foo));
    data = s(1).ConvexHull;
    xvals = round(min(data(:,1))):round(max(data(:,1)));
    yvals = round(min(data(:,2))):round(max(data(:,2)));
    [~,idx] = min(foo(yvals,xvals));
    idx = idx + min(yvals)-1;
    foo = zeros(size(FrameN));
    for k = 1:length(xvals)
        foo(idx(k),xvals(k)) = 1;
    end;
    foobar = logical(foo) & roi1;
    foobar = bwmorph(foobar,'clean',1);
    [a1,b1]=find(foobar == 1);
    
    
    % % % %     %%%%% Second region -- edge detection method
    % % % %     threshval = 0.03
    % % % %     meanval = mean(mean(FrameN(s(2).PixelIdxList)));
    % % % %     foo = zeros(size(FrameN))+ meanval;
    % % % %     foo(s(2).PixelIdxList) = FrameN(s(2).PixelIdxList);
    % % % %     dum = [2,2,2;2,1,2;2,2,2];
    % % % %     foo = conv2(double(foo),dum);
    % % % %     foo = foo(2:end-1,2:end-1);
    % % % %     foo = foo - min(min(foo));
    % % % %     foo = foo./max(max(foo));
    % % % %     foobar = edge(foo,threshval);
    % % % %     foobar = foobar & roi2;
    % % % %     [a2,b2]=find(foobar == 1);
    
    
    
    %%%%% Second region -- darkest pixel method
    meanval = mean(mean(FrameN(s(2).PixelIdxList)));
    foo = zeros(size(FrameN))+ meanval;
    foo(s(2).PixelIdxList) = FrameN(s(2).PixelIdxList);
    dum = [2,2,2;2,1,2;2,2,2];
    foo = conv2(double(foo),dum);
    foo = foo(2:end-1,2:end-1);
    foo = foo - min(min(foo));
    foo = foo./max(max(foo));
    data = s(2).ConvexHull;
    xvals = round(min(data(:,1))):round(max(data(:,1)));
    yvals = round(min(data(:,2))):round(max(data(:,2)));
    [test,idx] = min(foo(yvals,xvals));
    idx = idx + min(yvals)-1;
    foo = zeros(size(FrameN));
    for k = 1:length(xvals)
        foo(idx(k),xvals(k)) = 1;
    end;
    foobar = logical(foo) & roi2;
    foobar = bwmorph(foobar,'clean',1);
    [a2,b2]=find(foobar == 1);
    
    xvals = [a1;a2]; yvals = [b1;b2];
    
    %%% Impose constraint that each point on the whisker can't have moved
    %%% by more than N pixels
    N = 4;
    OldWhiskerOut = WhiskerOut{FrameCounter-1};
    oldx = OldWhiskerOut(1,:); oldy = OldWhiskerOut(2,:);
    
    
    subplot(3,4,8);cla;
    imagesc(FrameN);colormap('gray');ho;
    plot(oldx,oldy,'c*');
    plot(b1,a1,'g.');
    plot(b2,a2,'y.'); axis([180.0371  315.0917  242.3757  348.8050]);
    
    plot(yvals,xvals,'m*');
    
    N = 2;
    RemoveMe = [];
    for k = 1:length(yvals)
        [idx,~] = findc(oldx,yvals(k),'quiet');
        dum = oldy(round(idx))-xvals(k);
        if abs(oldy(idx)-xvals(k)) > N
            RemoveMe = [RemoveMe,k];
        end;
    end;
    xvals(RemoveMe) = []; yvals(RemoveMe) = [];
    
    plot(yvals,xvals,'b.'); axis([ 194.1961  222.2028  278.6301  319.7081]);
    
    WhiskerOutNotSmooth{FrameCounter} = [yvals;xvals];
    p = polyfit(yvals,xvals,3);
    yvals = round(min(yvals)):round(max(yvals));
    xvals = polyval(p,yvals);
    WhiskerOut{FrameCounter} = [yvals;xvals];
    
    
    
    
    
    
    
    
    
    
    %%%% Find new manipulator out for this frame
    %%%% Find an  ROI around the manipulator and find all pixels within it.
    
    data = ManipOutAllPixels{FrameCounter -1};
    xm = data(1,:); ym = data(2,:);
    N = 10;  % amount to grow ROI around the manipulator from the previous frame
    [p] = polyfit(xm,ym,1);
    xmsmooth = round(min(xm):1:max(xm));
    ymsmooth = round(polyval(p,xmsmooth));
    foo = zeros(size(FrameN));
    %%% There must be a better way to do these next three lines
    for k = 1:length(xmsmooth)
        foo(ymsmooth(k),xmsmooth(k)) = 1;
    end;
    bw = logical(foo);
    bw = bwmorph(bw,'dilate',N);
    s = regionprops(bw,'pixellist');
    xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1));
    yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
    xoffset = min(xvals); yoffset = min(yvals);
    FrameN_Manip = FrameN(yvals,xvals);
    foobar = edge(FrameN_Manip,'sobel');
    [h,t,r]=hough(foobar);
    p = houghpeaks(h,2);
    lines = houghlines(foobar,t,r,p);
    counter = 0;
    xvals = [lines(1).point1(1),lines(2).point1(1),lines(1).point2(1),lines(2).point2(1)];
    yvals = [lines(1).point1(2),lines(2).point1(2),lines(2).point2(2),lines(1).point2(2)];
    xvals = [min(xvals), min(xvals), max(xvals), max(xvals)] + xoffset -1;
    yvals = yvals+yoffset-1;
    
    [bw,xi,yi]=roipoly(FrameN,xvals,yvals);
    [m,n]=size(FrameN);
    BW = poly2mask(xi,yi,m,n);
    s = regionprops(BW,'pixellist');
    
    xm = s.PixelList(:,1); ym = s.PixelList(:,2);
    ManipOutAllPixels{FrameCounter} = [xm';ym'];
    p = polyfit(xm,ym,1);
    xmm = round(min(xm)):round(max(xm));
    ymm = polyval(p,xmm);
    ManipOut{FrameCounter} = [xmm;ymm];
    
    fig1;
    subplot(3,4,9);cla;
    data = WhiskerOut{FrameCounter};
    imagesc(FrameN);ho; plot(data(1,:),data(2,:),'g.');axis([180.0371  315.0917  242.3757  348.8050]);
    
    
    subplot(3,4,10);cla;
    imagesc(FrameN_Manip);ho;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
    end;
    
    subplot(3,4,11);cla;
    imagesc(FrameN); ho;
    plot(xvals,yvals,'y.');axis([113.1317  463.7929  270.6227  361.6242]);
    
    subplot(3,4,12);cla;
    imagesc(FrameN); ho;
    plot(xm,ym,'y.');
    plot(xmm,ymm,'g.');axis([113.1317  463.7929  270.6227  361.6242]);
    
    
    
    pause;
end;
