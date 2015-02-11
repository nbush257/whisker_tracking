% track BP This code is super slow right now. Also may want to add
% functionality that removes certain partsof the frame from becoming
% possible for the basepoint ( other trimmed whiskers that shouldn't
% move...)
function bpOut = trackBP(vidFileName,firstFrame,lastFrame)
%% only zeeping cmopatability for whisker emerging leftward( right side of rat)
v = seqIo(vidFileName,'r');
v.seek(firstFrame-1);
I = v.getframe();
I = histeq(I);
imshow(I);
zoom on;
title('Zoom, then click on the basepoint');
pause;

bp = round(ginput(1));
bpx = bp(1);
bpy = bp(2);
se = strel('square',10);% i fthis is odd, the for loop needs to be changed in order to accomodate non integer values of the center
mask = zeros(size(I));
mask(bpy,bpx) = 1;

imshow(I);zoom on; title('click on pixels to white out'); pause;

removePix = ginput;
title('click on the bottom, then rightmost boundary that we allow the BP to travel through');
boundarys = ginput(2);
yBound = ceil(boundarys(1,2));
xBound = ceil(boundarys(2,1));

removePix = round(removePix);
seRMpix = strel('disk',1);
m = zeros(size(I));
if ~isempty(removePix)
    m(removePix(:,2),removePix(:,1)) = 1;
end

m = imdilate(m,seRMpix);
p = regionprops(m,'PixelList');
xRM = [];
yRM=[];
for ii = 1:length(p);
    tempX = p(ii).PixelList(:,1);
    xRM = [xRM;tempX];
    
    tempY = p(ii).PixelList(:,2);
    yRM = [yRM;tempY];
end



bw = imdilate(mask,se);
s = regionprops(bw,'extrema');
xmin = round(min(s.Extrema(:,1)));
xmax = round(max(s.Extrema(:,1)));
ymin = round(min(s.Extrema(:,2)));
ymax = round(max(s.Extrema(:,2)));
Isub = I(ymin:ymax,xmin:xmax);
Isub = histeq(Isub,15);
Isub2 = zeros(size(Isub));
Isub2(Isub<35)=1;
cc =  bwconncomp(Isub2);
value=  [];
for ii = 1:length(cc.PixelIdxList)
    region = zeros(size(Isub2));
    region(cc.PixelIdxList{ii}) = 1;
    bounds = size(Isub2);
    center = bounds/2+.5;
    d = bwdist(region);
    value(ii) = d(center(1),center(2));
end
[~,keepRegion] = min(value);
region = zeros(size(Isub2));
region(cc.PixelIdxList{keepRegion}) = 1;


c = regionprops(region,Isub,'WeightedCentroid');
newBPx = c.WeightedCentroid(1);
newBPy = c.WeightedCentroid(2);

newBPFull = round([newBPx + xmin,newBPy+ymin]);
bpOut(firstFrame).x = newBPFull(1);
bpOut(firstFrame).y = newBPFull(2);


for ii = firstFrame+1:lastFrame
    v.seek(ii-1);
    I =v.getframe();
    I =histeq(I);
    I(yRM,xRM) = 255;
    
    if newBPFull(1) > xBound | newBPFull(2) >yBound
        ii =ii-5;
        v.seek(ii-1);
        I =v.getframe();
        I =histeq(I);
        I(yRM,xRM) = 255;
        
        imshow(I);zoom on; pause; title('Basepoint exceeded boundaries, click on the basepoint again');
        bp = round(ginput(1));
    else
        bp = newBPFull;
    end
    mask = zeros(size(I));
    mask(bp(2),bp(1)) = 1;
    
    
    bw = imdilate(mask,se);
    s = regionprops(bw,'extrema');
    xmin = round(min(s.Extrema(:,1)));
    xmax = round(max(s.Extrema(:,1)));
    ymin = round(min(s.Extrema(:,2)));
    ymax = round(max(s.Extrema(:,2)));
    
    Isub = I(ymin:ymax,xmin:xmax);
    Isub = histeq(Isub,15);
    Isub2 = zeros(size(Isub));
    Isub2(Isub<25)=1;
    cc =  bwconncomp(Isub2);
    value=  [];
    for jj = 1:length(cc.PixelIdxList)
        region = zeros(size(Isub2));
        region(cc.PixelIdxList{jj}) = 1;
        bounds = size(Isub2);
        center = bounds/2+.5;
        d = bwdist(region);
        value(jj) = d(center(1),center(2));
    end
    [~,keepRegion] = min(value);
    region = zeros(size(Isub2));
    region(cc.PixelIdxList{keepRegion}) = 1;
    
    
    c = regionprops(region,Isub,'WeightedCentroid');
    newBPx = c.WeightedCentroid(1);
    newBPy = c.WeightedCentroid(2);
    
    newBPFull = round([newBPx + xmin,newBPy+ymin]);
    
    bpOut(ii).x= newBPFull(1);
    bpOut(ii).y =  newBPFull(2);
    %%% plot sanity checks %%%
    imshow(I)
    ho
    scatter(newBPFull(1),newBPFull(2),'r*')
    pause(.01)
    cla
end



