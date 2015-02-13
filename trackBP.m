% track BP This code is super slow right now. Also may want to add
% functionality that removes certain partsof the frame from becoming
% possible for the basepoint ( other trimmed whiskers that shouldn't
% move...)
function bp = trackBP(vidFileName,wStruct,startFrame,endFrame)

v = seqIo(vidFileName,'r');
v.seek(startFrame-1);
I = v.getframe();
imshow(I);
zoom on; title('zoom to the basepoint');pause;
title('click on the basepoint')
bp(1,:) = ginput(1)
for ii = 2:length(wStruct);
   
    d = sqrt((wStruct(ii).x-bp(ii-1,1)).^2 + (wStruct(ii).y-bp(ii-1,2)).^2);
    [minD,bpIdx] = (min(d));
    if minD>5
        bp(ii,1) = bp(1,1);
        bp(ii,2) = bp(1,2);
    end
    
    
    bp(ii,1) = wStruct(ii).x(bpIdx);
    bp(ii,2) = wStruct(ii).y(bpIdx);
end

    