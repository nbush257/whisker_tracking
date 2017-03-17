function [BPout,wStructOut] = cleanBP(wStruct,r)
%% function [BPout,wStructOut] = cleanBP(wStruct,[r])
% =====================================================
% Takes a 2D whisker struct and performs:
%   1) Median Filtering with length 5 window size
%   2) Outlier deletion
%   3) Kalman Filtering
%  INPUTS:
%   wStruct:        a 2D whisker structure
%   r [optional]:   a 1x2 variance to smooth at with the kalman filter.
%                   Defaults to the variance of the BP
%  OUTPUTS:
%   BPout:          the Nx2 cleaned basepoint vector
%   wStructOut:     a whisker structure with the basepoint replaced by the
%                   smoothed basepoint
% =====================================================
% Nick Bush 12/18/2015
%%
kalman_TGL = 0;
%% Get Basepoint
% preallocate the Basepoint matrix (Nx2)
BP = nan(length(wStruct),2);
% Extract the Basepoint from the structure
for ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    else
        BP(ii,:) = [wStruct(ii).x(1) wStruct(ii).y(1)];
    end
end

%% apply a median filter and delete outliers to remove point disconitnuities
BPf1 = medfilt1(BP,5);
BPf2(:,1) = deleteoutliers(BPf1(:,1),.00000001,1);
BPf2(:,2) = deleteoutliers(BPf1(:,2),.00000001,1);

%% Interpolate over NaNs. If the first or last point are NaN, then make them
% equal to the first or las non-NaN point, respectively.
if any(isnan(BPf2(end,:)))
    BPf2(end,:) = BPf2(find(~any(isnan(BPf2)'),1,'last'),:);
end

if any(isnan(BPf2(1,:)))
    BPf2(1,:) = BPf2(find(~any(isnan(BPf2)'),1,'first'),:);
end
pos = naninterp(BPf2);

BPout = pos;

%% Kalman Filter
if kalman_TGL
    % This code was adapted by NEB from the ekfukf toolbox examples.
    
    % position must be a 2 x N time series of points.
    if size(pos,2)<size(pos,1)
        pos = pos';
    end
    % create state matrix
    vel = [[0;0] diff(pos')'];
    acc = [[0;0] diff(vel')'];
    state = [pos;vel;acc];
    
    
    
    % Measurement model.
    H = [1     0     0     0     0     0;
        0     1     0     0     0     0];
    
    % Variance in the measurements.
    if nargin ~=2
        r = var(pos');
    end
    R = diag([r(1) r(2)]);
    
    % Transition matrix for the continous-time system.
    F = [0 0 1 0 0 0;
        0 0 0 1 0 0;
        0 0 0 0 1 0;
        0 0 0 0 0 1;
        0 0 0 0 0 0;
        0 0 0 0 0 0];
    
    % Noise effect matrix for the continous-time system.
    L =  [0 0;
        0 0;
        0 0;
        0 0;
        1 0;
        0 1];
    %Stepsize
    dt = 0.5;
    
    % Process noise variance
    q = 0.2;
    Qc = diag([q q]);
    
    % Discretization of the continous-time system.
    [A,Q] = lti_disc(F,L,Qc,dt);
    
    % Initial guesses for the state mean and covariance.
    m = state(:,1);
    P = diag([0.1 0.1 0.1 0.1 0.5 0.5]);
    
    MM = zeros(size(m,1), size(state,2));
    PP = zeros(size(m,1), size(m,1), size(state,2));
    
    % Filtering steps.
    h = waitbar(0,'filtering');
    for i = 1:size(state,2)
        waitbar(i/size(state,2),h);
        
        [m,P] = kf_predict(m,P,A,Q);
        [m,P] = kf_update(m,P,pos(:,i),H,R);
        MM(:,i) = m;
        PP(:,:,i) = P;
    end
    close all force
    
    % Smoothing step.
    [SM,SP] = rts_smooth(MM,PP,A,Q);
    [SM2,SP2] = tf_smooth(MM,PP,pos,A,Q,H,R,1);
    xo = SM(1,:);
    yo = SM(2,:);
    BPout = [xo;yo]';
end

% replace first point of all whiskers with the filtered basepoint.
wStructOut = wStruct;
for ii = 1:length(wStruct)
    if ~isempty(wStruct(ii).x)
        wStructOut(ii).x(1) = BPout(ii,1);
        wStructOut(ii).y(1) = BPout(ii,2);
    end
end
