
function [wStruct,xBaseMedian,yBaseMedian] = trackBP(vidFileName,wStruct,startFrame,endFrame)

v = seqIo(vidFileName,'r');
v.seek(startFrame-1);
I = v.getframe();
imshow(I);
zoom on; title('zoom to the basepoint');pause;
title('click on the basepoint')
bp(1,:) = ginput(1);
for ii = 1:length(wStruct);
    
    % if this is the first frame, use theuser defined basepoint
    if ii == 1
        d = sqrt((wStruct(ii).x-bp(1,1)).^2 + (wStruct(ii).y-bp(1,2)).^2);
    
    else % If this is not the first frame, find the nearest node to the last basepoint.
        d = sqrt((wStruct(ii).x-bp(ii-1,1)).^2 + (wStruct(ii).y-bp(ii-1,2)).^2);
    end
    [~,bpIdx(ii)] = (min(d));%find the index of the node closest to the last basepoint.

    %get the basepoint value based on the index found previously
    bp(ii,1) = wStruct(ii).x(bpIdx(ii));
    bp(ii,2) = wStruct(ii).y(bpIdx(ii));
    % if this isn't the first frame, make sure the basepoint hasn't moved
    % more than 5 pixels from the last time.
    if ii~=1
        bp_movement = sqrt((bp(ii,1)-bp(ii-1,1)).^2 + (bp(ii,2)-bp(ii-1,2)).^2);
        
        if bp_movement>5 %If it has moved more than 5 pixels, use the previous basepoint as the current basepoint.
            %and set the first node on the whisker equal to the last
            %basepoint.
            bpIdx(ii) = 1;
            wStruct(ii).x(1) = bp(ii-1,1);
            wStruct(ii).y(1) = bp(ii-1,2);
            
            %I should do some smoothing here.
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
