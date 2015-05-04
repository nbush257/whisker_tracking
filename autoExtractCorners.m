<<<<<<< HEAD
% auto calibrate

function [I,points] = autoExtractCorners(vFNameTop,vFNameFront,varargin)
%% function[I,points] = autoExtractCorners(vFNameTop,vFNameFront)
% 
in = input('assumes number of points in checkerboard is 35, is this ok? (y/n)','s');
if strcmp(in,'n')
    stopThisFunctionYouIdiot
end
saving = 1;

vTop = seqIo(vFNameTop,'r');

vFront = seqIo(vFNameFront,'r');
info = vTop.getinfo();


if length(varargin) < 2 
    firstFrame = 1;
    lastFrame = info.numFrames;
elseif length(varargin)>2
    error('improper varargin. Too Many input Args')
else
    firstFrame = varargin{1};
    lastFrame = varargin{2};
end

points = struct;
count = 0;
plotting = 1;
plots = figure;
I = struct;
map = hsv(35);
for i = firstFrame:150:lastFrame%info.numFrames  
    vTop.seek(i-1);
    Itop = vTop.getframe();
    vFront.seek(i-1);
    Ifront = vFront.getframe();
    tempTop =  detectCheckerboardPoints(Itop);
    tempFront = detectCheckerboardPoints(Ifront);
    if size(tempTop,1)~=35 | size(tempFront,1)~=35
        continue
    end
    count = count+1;
    points(count).frame = i;
    points(count).top = detectCheckerboardPoints(Itop);
    points(count).front = detectCheckerboardPoints(Ifront);
    I(count).top = Itop;
    I(count).front = Ifront;
    if saving
        imwrite(Itop,['top' num2str(count) '.tif']);
        imwrite(Ifront,['front' num2str(count) '.tif']);
    end
    if plotting
        subplot(121)
        imshow(Itop)
        hold on
        for j = 1:size(points(count).top,1)
            
            if mod(j,2)
                plot(points(count).top(j,1),points(count).top(j,2),'o','MarkerEdgeColor',map(j,:));
                
            else
                plot(points(count).top(j,1),points(count).top(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
        subplot(122)
        imshow(Ifront)
        hold on
        
        for j = 1:size(points(count).front,1)
            if mod(j,2)
                plot(points(count).front(j,1),points(count).front(j,2),'o','MarkerEdgeColor',map(j,:));
            else
                plot(points(count).front(j,1),points(count).front(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
    end
    
    pause(.01)
    cla
end
close all force;


=======
% auto calibrate

function [I,points] = autoExtractCorners(vFNameTop,vFNameFront,varargin)
%% function[I,points] = autoExtractCorners(vFNameTop,vFNameFront)
% 
in = input('assumes number of points in checkerboard is 35, is this ok? (y/n)','s');
if strcmp(in,'n')
    stopThisFunctionYouIdiot
end
saving = 1;

vTop = seqIo(vFNameTop,'r');

vFront = seqIo(vFNameFront,'r');
info = vTop.getinfo();


if length(varargin) < 2 
    firstFrame = 1;
    lastFrame = info.numFrames;
elseif length(varargin)>2
    error('improper varargin. Too Many input Args')
else
    firstFrame = varargin{1};
    lastFrame = varargin{2};
end

points = struct;
count = 0;
plotting = 1;
plots = figure;
I = struct;
map = hsv(35);
for i = firstFrame:150:lastFrame%info.numFrames  
    vTop.seek(i-1);
    Itop = vTop.getframe();
    vFront.seek(i-1);
    Ifront = vFront.getframe();
    tempTop =  detectCheckerboardPoints(Itop);
    tempFront = detectCheckerboardPoints(Ifront);
    if size(tempTop,1)~=35 | size(tempFront,1)~=35
        continue
    end
    count = count+1;
    points(count).frame = i;
    points(count).top = detectCheckerboardPoints(Itop);
    points(count).front = detectCheckerboardPoints(Ifront);
    I(count).top = Itop;
    I(count).front = Ifront;
    if saving
        imwrite(Itop,['top' num2str(count) '.tif']);
        imwrite(Ifront,['front' num2str(count) '.tif']);
    end
    if plotting
        subplot(121)
        imshow(Itop)
        hold on
        for j = 1:size(points(count).top,1)
            
            if mod(j,2)
                plot(points(count).top(j,1),points(count).top(j,2),'o','MarkerEdgeColor',map(j,:));
                
            else
                plot(points(count).top(j,1),points(count).top(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
        subplot(122)
        imshow(Ifront)
        hold on
        
        for j = 1:size(points(count).front,1)
            if mod(j,2)
                plot(points(count).front(j,1),points(count).front(j,2),'o','MarkerEdgeColor',map(j,:));
            else
                plot(points(count).front(j,1),points(count).front(j,2),'*','MarkerEdgeColor',map(j,:));
            end
        end
        
    end
    
    pause(.01)
    cla
end
close all force;


>>>>>>> 3d2da9842f657a8ee0b04374a039dc87f826b925
