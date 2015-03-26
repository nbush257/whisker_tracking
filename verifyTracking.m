startFrame = 11008;
endFrame = 20644;
count = 0;
tW = top_smooth;
fW = front_smooth;
tVid = seqIo(topVidName,'r');
fVid = seqIo(frontVidName,'r');
close all
figure
for i=startFrame:endFrame
    count = count+1;
    subplot(1,2,1,'replace')
    fVid.seek(i-1);
    If = fVid.getframe();
    imshow(If);
    hold on
    plot(fW(count).x,fW(count).y,'.');
    axis equal
    
    subplot(1,2,2,'replace')
    tVid.seek(i-1);
    It = tVid.getframe();
    imshow(It);
    hold on
    plot(tW(count).x,tW(count).y,'.')
    axis equal
    pause(.01)
    cla
    
end

