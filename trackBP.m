% track BP This code is super slow right now. Also may want to add
% functionality that removes certain partsof the frame from becoming
% possible for the basepoint ( other trimmed whiskers that shouldn't
% move...)
function [wStruct,xBaseMedian,yBaseMedian] = trackBP(vidFileName,wStruct,startFrame,endFrame)

v = seqIo(vidFileName,'r');
v.seek(startFrame-1);
I = v.getframe();
imshow(I);
zoom on; title('zoom to the basepoint');pause;
title('click on the basepoint')
bp(1,:) = ginput(1);
for ii = 1:length(wStruct);
    if ii == 1
        d = sqrt((wStruct(ii).x-bp(ii,1)).^2 + (wStruct(ii).y-bp(ii,2)).^2);
    else
        
        
        d = sqrt((wStruct(ii).x-bp(ii-1,1)).^2 + (wStruct(ii).y-bp(ii-1,2)).^2);
    end
    [~,bpIdx(ii)] = (min(d));
    
    
    
    bp(ii,1) = wStruct(ii).x(bpIdx(ii));
    bp(ii,2) = wStruct(ii).y(bpIdx(ii));
    if ii~=1
        bp_movement = sqrt((bp(ii,1)-bp(ii-1,1)).^2 + (bp(ii,2)-bp(ii-1,2)).^2);
        
        if bp_movement>5
            bpIdx(ii) = 1;
            wStruct(ii).x(1) = bp(ii-1,1);
            wStruct(ii).y(1) = bp(ii-1,2);
            bp(ii,1) = bp(ii-1,1);
            bp(ii,2) = bp(ii-1,2);
        end
    end
end
for ii =1:length(wStruct)
    wStruct(ii).x = wStruct(ii).x(bpIdx(ii):end);
    wStruct(ii).y = wStruct(ii).y(bpIdx(ii):end);
    wStruct(ii).xBase = bp(ii,1);
    wStruct(ii).yBase = bp(ii,2);
end
xBaseMedian = nanmedian([wStruct.xBase]);
yBaseMedian = nanmedian([wStruct.yBase]);
