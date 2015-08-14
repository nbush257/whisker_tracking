% Load the Calib_Results_stereo.mat file first
% fc = focal length (2x1)
% cc = principal point (2x1)
% alpha_c = Skew (1x1)
% kc = Distortion (5x1)
% om = Rotation Vector (3x1)
% % T = translaton vector (3x1)
% fc_left = stereoParams.CameraParameters1.FocalLength';
% fc_right = stereoParams.CameraParameters2.FocalLength';
% cc_left = stereoParams.CameraParameters1.PrincipalPoint';
% cc_right = stereoParams.CameraParameters2.PrincipalPoint';
% alpha_c_left = stereoParams.CameraParameters1.Skew;
% alpha_c_right = stereoParams.CameraParameters2.Skew;
% kc_left = [stereoParams.CameraParameters1.RadialDistortion stereoParams.CameraParameters1.TangentialDistortion 0]';
% kc_right = [stereoParams.CameraParameters2.RadialDistortion stereoParams.CameraParameters2.TangentialDistortion 0]';
% om = rodrigues(stereoParams.RotationOfCamera2);
% T = stereoParams.TranslationOfCamera2';

calib = {fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right,om,T};