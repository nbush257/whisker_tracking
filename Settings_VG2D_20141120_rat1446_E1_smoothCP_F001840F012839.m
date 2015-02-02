%% Settings_VG2D_20140908_gamma_F001840F012839
% -------------------------------------------------------------------------
% Settings file for image processing
% -------------------------------------------------------------------------
% DATA SPECIFICS:
%   + Data author: James Ellis
%   + Date taken: 11/20/14
%   + Trial: E1
%   + Frames: 1840 - 12839
% -------------------------------------------------------------------------
% James
% Dec 17, 2014

%% 00. Path names and labeling
% ** CHANGE WITH EACH DATASET **

% Data path location:
PT.dataname = '141120_rat1446_E1_1_';
PT.path = '/Users/mozilla/Desktop/WhiskerLab/Nick_Chris_Setup/rat1446/E1/merge_results/3D_NoSmooth/Contact_debugging_150105/';
PT.data = '/Users/mozilla/Desktop/WhiskerLab/Nick_Chris_Setup/rat1446/E1/merge_results/3D_NoSmooth/Contact_debugging_150105/';

% Frame sequence
PT.Frames = [1840 12839];

% Data TAG:
PT.TAG = ['_141023_rat1446_E1_triang_',num2str(PT.Frames(1),'%06.0f'),'F',num2str(PT.Frames(2),'%06.0f')];

% /////////////////////////////////////////////////////////////////////////

% Save path location:
PT.save = '/Users/mozilla/Desktop/WhiskerLab/Nick_Chris_Setup/rat1446/E1/merge_results/3D_NoSmooth/Contact_debugging_150105/';

%% Run_Extract_2D_WSKR
% --> Run: Setup_PEG_Top_v2.m
% =========================================================================
% ** CHANGE WITH EACH DATASET: FROM Setup_Peg_Top.m **

% Crop position
PT.pos = [105 255 49 42];

% /////////////////////////////////////////////////////////////////////////
% ** Change as needed (should not vary much across datasets) **
PT.ImageOrientation = 'L'; % Direction that nose points

PT.wskr_gaussian = {[25,25],100};
PT.wskr_canny = 0.5; % canny threshold
PT.wskr_dilate1 = 4; % pixels
PT.wskr_dilate2 = 5; % pixels

PT.wskr_TH = [30 70]; % pixels to dilate to find theta 

PT.wskr_canny_contour = [0.02 0.1]; % Whisker threshold for canny filter

PT.pos_w = 3; % pixels, width about crop to search for whisker crossing

% JAE addition 140908
PT.WskerBaseSide = 'L';
PT.WskrBaseSide = 'L';

PT.zone = 'LT'; % L: Left, R: Right, T: Top, B: Bottom (Any order)
% Zone around crop-zone to check for whisker crossing

PT.pix2m = 3/3450;

%% Run_Process_2D_WSKR
% ** CHANGE WITH EACH DATASET: **

% /////////////////////////////////////////////////////////////////////////
% ** Change as needed (should not vary much across datasets) **

PT.proc_spline_nodes = 4;
PT.proc_contact_thresh = 1.0; 
PT.proc_base_segment = [5.8e-5 0.004]; % [inner outer] Circle radius (pixels) from base-point to include
PT.proc_th_smooth_denom = 1; % No-filtering: 1
PT.proc_BP_smooth_denom = 5; % No-filtering: 1

%% Elastica2D
PT.E2D_E = 1; % Young's Modulus, 1 Pa*
PT.E2D_R = 1; % Base radius, 1 m*
PT.E2D_t2b_ratio = 20;

%% Elastica3D
PT.E3D_E = 3.3e9; % Young's Modulus, 3.3 GPa
PT.E3D_rbase = 100e-6; % radius of base, 100 micrometers
PT.E3D_taper = 15; % taper ratio (base to tip)
PT.filt = Inf; % a number from 0 to 1 for cutoff frequency, 1 is half the sample rate
% for no filter, put PT.filt to Inf

PT.pct_planar = 0.7; % what percentage of the undeflected whisker we want
PT.REF = nan;

%% Filtering for Lucie
% 141103
desired_freq = 25;
samp_rate = 250; % Hz of video acquisition
PT.filt = desired_freq/(samp_rate/2);