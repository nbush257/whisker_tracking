% full auto calibration script
clear;close all;
tV = '2016_12_20_B1_t03_top.avi';
fV = '2016_12_19_B1_t03_front.avi';
nPts = 42; %42 for 2mm grid, 30 for 4mm grid 42 for 5 mm grid
%%
n_sq_x_default = 10;
n_sq_y_default = 10;
dX = 2;
dY = 2;
inconsistent_pairs_detection = 0;
stride = 1;
recompute_intrinsic_left = 0;
recompute_intrinsic_right = 0;
%%
mkdir([tV(1:end-14) '_calib'])
warning('off','all')
autoExtractCorners(tV,fV,nPts,stride);
warning('on','all')
movefile('*.tif',[tV(1:end-14) '_calib\'])
cd([tV(1:end-14) '_calib'])
viewLabel = {'front','top'};
for viewCount = 1:2
    close all
    calib_name = viewLabel{viewCount};
    
    data_calib;
    click_calib;
    check_cond = 0;
    init_intrinsic_param;
    go_calib_optim;
    saving_calib;
%     analyse_error;
    movefile('Calib_Results.mat',['calib_' tV(1:end-14) '_' viewLabel{viewCount} '.mat'])
end

%%
pause(.01)
clearvars -except tV fV viewLabel inconsistent_pairs_detection recompute*

calib_file_name_left = ['calib_' tV(1:end-14) '_' viewLabel{1} '.mat'];
calib_file_name_right = ['calib_' tV(1:end-14) '_' viewLabel{2} '.mat'];


load_stereo_calib_files;
%% get 2D pts
pts_2D = struct();
for ii= 1:n_ima
    str = sprintf(['pts_2D(ii).xL = x_left_%i;'],ii); 
    
    eval(str);
    str = sprintf(['pts_2D(ii).xR = x_right_%i;'],ii); 
    eval(str);
end
%%
go_calib_stereo;
saving_stereo_calib;
ext_calib_stereo;
savefig(['extrinsic_' tV(1:end-14) '.fig'])

calib_stuffz;
movefile('Calib_Results_stereo.mat',['calib_stereo_' tV(1:end-14) '.mat'])
cd ..
%%
reprojection_stereo_evaluation(pts_2D,calibInfo);

