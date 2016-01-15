% get calibration tiffs
% use this script to write a set of caliration images to tiffs.
cd L:\raw\2015_28
topVidName = 'rat2015_28_SEP_16_VG_E4_t01_Top_calib.seq'
frontVidName = 'rat2015_28_SEP_16_VG_E4_t01_Front_calib.seq'
frames2grab = frames;
top = seqIo(topVidName,'r');
front = seqIo(frontVidName,'r');


topTifDir = ['calibTiffs_' topVidName(1:end-4)];
frontTifDir = ['calibTiffs_' frontVidName(1:end-4)];
mkdir(topTifDir);
mkdir(frontTifDir);
count = 0;
for i = frames2grab
    count = count+1;
    top.seek(i-1);
    front.seek(i-1);
    fI = front.getframe();
%     fI = adapthisteq(fI);
    tI = top.getframe();
%     tI = adapthisteq(tI);
    cd(topTifDir)
    imwrite(tI,['top' int2str(count) '.tif'],'tif')
    cd ..
    cd(frontTifDir)
    imwrite(fI,['front' int2str(count) '.tif'],'tif')
    cd ..
end

    