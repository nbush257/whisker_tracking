function [BPout, wStructOut] = extendBP(wStruct,v)
figure
v.seek(10000);
I = v.getframe();
imshow(I);
zoom on
title('zoom to BP and press enter')
pause
title('Click on the BP')
initBP = round(ginput(1));
wStructOut = wStruct;
BPout = nan(length(wStruct),2);
close all
pause(.01)
parfor ii = 1:length(wStruct)
    if isempty(wStruct(ii).x) || length(wStruct(ii).x)<5
        continue
    end
    xIn = initBP(1):wStruct(ii).x(1);
    xIn = xIn';
    if length(xIn)<1
        continue
    end
    
    fitPts = min([length(wStruct(ii).x)/4 100]);
    warning off
    p = polyfit(wStruct(ii).x(1:fitPts),wStruct(ii).y(1:fitPts),2);
    warning on
    yIn = polyval(p,xIn);
    wStructOut(ii).x =[xIn;wStruct(ii).x];
    wStructOut(ii).y =[yIn;wStruct(ii).y];
    BPout(ii,:) = [wStructOut(ii).x(1) wStructOut(ii).y(1)];
    if mod(ii,1000) == 0
        fprintf('\n Frame %i',ii)
    end
%     if mod(ii,100) == 0 && ii> 80000
%         v.seek(ii-1);
%         I = v.getframe();
%         fprintf('\nFrame %i',ii)
%         cla
%         imshow(I)
%         ho
%         plot(wStruct(ii).x+1,wStruct(ii).y+1,'.')
%         plot(xIn+1,yIn+1,'r.')
%         axy(initBP(2)-40,initBP(2)+40)
%         axx(initBP(1)-40,initBP(1)+40)
%         drawnow
%     end
end

    
