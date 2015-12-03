% get calibration tiffs
% use this script to write a set of caliration images to tiffs.
cd L:\raw\2015_06
topVidName = 'rat2105_06_0226_FEB26_vg_B2_calib_pre_top.seq'
frontVidName = 'rat2105_06_0226_FEB26_vg_B2_calib_pre_Front.seq'
frames2grab = [4840 5102 5348 5594 6493 7119 8204 8494 9438 9939 9998 11109 11736 13296 13912 14090 14350 14370 14885 ];
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
    tI = top.getframe();
    cd(topTifDir)
    imwrite(tI,['top' int2str(count) '.tif'],'tif')
    cd ..
    cd(frontTifDir)
    imwrite(fI,['front' int2str(count) '.tif'],'tif')
    cd ..
end

    