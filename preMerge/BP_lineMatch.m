function wOut = BP_lineMatch(w,v,plotTGL)
%% function BP_lineMatch(w,v,[plotTGL])
% Inputs:
%       w: a whisker struct
%       v: a videoreader object
%       plotTGL: a binary to plot or not
if nargin < 3
    plotTGL=0;
end
wOut = w;
if isnumeric(v)
    I = v;
else
    I = read(v,5000);
end
imshow(I)
ho
isTop = input('Is Top?(1/0)');
title('Click 3 points to determine track of BP (clik left to right or top to bottom)')
zoom on; pause;
a = ginput(3);
if isTop
    p = polyfit(a(:,2),a(:,1),2);
    c = polyval(p,a(1,2):.1:a(3,2));
    plot(c,a(1,2):.1:a(3,2))
    d = a(1,2):.1:a(3,2);
else
    a = sortrows(a);
    
    p = polyfit(a(:,1),a(:,2),2);
    d = polyval(p,a(1,1):.1:a(3,1));
    plot(a(1,1):.1:a(3,1),d)
    c = a(1,1):.1:a(3,1);
end

if isrow(d); d = d'; end
if isrow(c);c = c'; end
pause
ca
% h = waitbar(0,'Lots of dsearchs can take a while')
tic

parfor ii = 1:length(w)
    %     waitbar(ii/length(w),h)
    if ~isempty(w(ii).x)
        
        
        [~,a2] = dsearchn([c d], [w(ii).x+1 w(ii).y+1]);
        [~,idx] = min(a2);
        
        wOut(ii).x = wOut(ii).x(idx:end);
        wOut(ii).y = wOut(ii).y(idx:end);
        
        if plotTGL
            I = read(v,ii);
            imshow(I)
            ho
            plot(w(ii).x+1,w(ii).y+1,'.')
            plot(w(ii).x(idx:end)+1,w(ii).y(idx:end)+1,'o')
            pause(.01)
            cla
        end
    end
end
toc