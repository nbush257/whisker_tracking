seqDir = 'H:\';
d = dir([seqDir '*.seq');
for ii = 1:length(dir)
    if strfind(d(ii).name,'calib')
        continue
    end
    v = seqIo([seqDir d(ii).name],'r');
    v.seek(0)
    I = v.getframe();
    imshow(I)
    zoom on; title('zoom to the base point');pause;title('Click on the base point');
    bp(ii,:) = ginput(1);
end
for ii = 1:length(dir)
    
    if strfind(d(ii).name,'calib')
        continue
    end
    
    info = v.getinfo();
    nFrames = v.numFrames;
    aviFileName = [seqDir d(ii).name(1:end-4) '.avi'];
    w = VideoWriter(aviFileName,'Motion JPEG AVI');
    w.open;
    for jj = 1:numFrames
        v.seek(jj-1);
        I = v.getFrame();
        I = adapthisteq(I);
        writeVideo(w,I);
    end
    w.close;
end

d = dir([seqDir '*.avi']);
for ii = 1:length(d)
    autoTracking([seqDir d(ii).name],bp(ii,:));
end

