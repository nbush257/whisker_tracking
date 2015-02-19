% get calibration tiffs
cd C:\Users\guru\Documents\hartmann_lab\data\2015_04\
topVidName = 'rat2015_04_vg_D1_t02_Top.seq'
frontVidName = 'rat2015_04_vg_D1_t02_Front.seq'
frames2grab = [36097 36810 37433 38727 42601 ];
top = seqIo(topVidName,'r');
front = seqIo(frontVidName,'r');


topTifDir = ['calibTiffs_' topVidName(1:end-4)];
frontTifDir = ['calibTiffs_' frontVidName(1:end-4)];
mkdir(topTifDir);
mkdir(frontTifDir);
for i = frames2grab
    top.seek(i-1);
    front.seek(i-1);
    fI = front.getframe();
    tI = top.getframe();
    cd(topTifDir)
    imwrite(tI,['top' int2str(i) '.tif'],'tif')
    cd ..
    cd(frontTifDir)
    imwrite(fI,['front' int2str(i) '.tif'],'tif')
    cd ..
end

    