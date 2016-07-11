% full auto calibration script
clear;close all;
tV = 'rat2016_02_JAN27_VG_E3_t01_Top_calib.seq';
fV = 'rat2016_02_JAN27_VG_E3_t01_Front_calib.seq';
nPts = 42; %42 for 2mm grid, 30 for 4mm grid
%%
mkdir([tV(1:end-14) '_calib'])
warning('off','all')
autoExtractCorners(tV,fV,nPts);
warning('on','all')
movefile('*.tif',[tV(1:end-14) '_calib\'])
cd([tV(1:end-14) '_calib'])
viewLabel = {'front','top'}
for viewCount = 1:2
    close all
    data_calib;
    click_calib;
    check_cond = 0;
    init_intrinsic_param;
    go_calib_optim;
    saving_calib;
    analyse_error;
    movefile('Calib_Results.mat',['calib_' tV(1:end-14) '_' viewLabel{viewCount} '.mat'])
end
pause(.01)
clearvars -except tV fV
load_stereo_calib_files;
go_calib_stereo;
saving_stereo_calib;
ext_calib_stereo;
movefile('Calib_Results_stereo.mat',[tV(1:end-14) '_stereoCalib.mat'])
cd ..