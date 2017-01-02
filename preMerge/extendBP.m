function [BPout, wStructOut] = extendBP(wStruct,BP)

wStructOut = wStruct;
BPout = nan(length(wStruct),2);
close all
pause(.01)
fprintf('\nExtending BP...')
parfor ii = 1:length(wStruct)
    if isempty(wStruct(ii).x) || length(wStruct(ii).x)<5
        continue
    end
    xIn = BP(1):wStruct(ii).x(1);
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
%     if mod(ii,1000) == 0
%         fprintf('\n Extending BP Frame %i',ii)
%     end
%     if mod(ii,100) == 0 && ii> 80000
%         v.seek(ii-1);
%         I = v.getframe();
%         fprintf('\nFrame %i',ii)
%         cla
%         imshow(I)
%         ho
%         plot(wStruct(ii).x+1,wStruct(ii).y+1,'.')
%         plot(xIn+1,yIn+1,'r.')
%         axy(BP(2)-40,BP(2)+40)
%         axx(BP(1)-40,BP(1)+40)
%         drawnow
%     end
end

    
