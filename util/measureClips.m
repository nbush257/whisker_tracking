function measureClips(aviDir,TAGu)

for jj = 1:dAvi
    V = VideoReader(dAvi(jj).name)
    img = read(V,100000);
    imshow(img);hold on
    title('Click on the center of the pad')
    bp(jj,:) = ginput(1);
    plotv(bp(jj,:),'g*');
    title('Click on the rightmost line that limits the follicle position')
    [fol(jj),~] = ginput(1);
    clf
end

for ii = 1:length(TAGu)
    batchMeasureTraces(TAGu{ii},bp(ii,:),fol(ii),'v');
end