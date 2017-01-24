function [tip_out, wstruct3D_out] = clean3D_tip(wstruct3D,varargin)
%% function wStruct3D_out = clean3D_tip(wstruct3D,[nanFill],[medfiltWin],[outlierThresh])
% =================================================
% Applies a series of smoothing algorithms to make the 3D tip position a
% smooth and reliable indicator of contact. This should prevent small
% tracking errors from dominating contact determination
% =================================================
% INPUTS:
%           wStruct3D - a 3D whisker structure
%           [nanFill] - windowsize over which to interpolate nans. Default
%              is 20.
%           [medfiltWin] - window size over which to perform median
%              filtering. Default is 5. Should be odd.
%           [outlierThresh] - threshold at which an outlier is removed
%               (0-1). Default is 0.0001.
% OUTPUTS:
%           tip - a N x 3 matrix of the x-y-z points of the tip, smoothed
%              over time.
%           wStruct3D_out - replaces the tip position with the smoothed tip
%              position. THIS IS NOT RECOMMENDED AS AN OUTPUT.
% =================================================
% NEB 2016_07_07
%% Input handling and defaults
kalman_TGL = 0;
numvargs = length(varargin);
optargs = {20,5,0.0001}; % 
optargs(1:numvargs) = varargin;
[nanFill,medfiltWin,outlierThresh] = optargs{:};

medfiltWin = round(medfiltWin);
nanFill = round(nanFill);

assert(nanFill>=0);

if medfiltWin < 3
    medfiltWin = 3;
end

if ~mod(medfiltWin,2)
    medfiltWin = medfiltWin-1;
end

%%
tip = nan(length(wstruct3D),3);

% loop over every frame and extract tip position
for ii = 1:length(wstruct3D)
    if ~isempty(wstruct3D(ii).x)
        tip(ii,:) = [wstruct3D(ii).x(end) wstruct3D(ii).y(end) wstruct3D(ii).z(end)];
    end
end

% median filtering
tip_f = medfilt1(tip,medfiltWin);

% Interpolate over small gaps. Hardcoded to 20ms gaps. Maybe want to turn
% into an input?
for ii = 1:3
    tip_f(:,ii) = InterpolateOverNans(tip_f(:,ii),nanFill);
end

% delete outliers and reinterpolate over small gaps
for ii = 1:3
    tip_f(:,ii) = deleteoutliers(tip_f(:,ii),outlierThresh,1);
    tip_f(:,ii) = InterpolateOverNans(tip_f(:,ii),nanFill);
end

if kalman_TGL
    %% Apply Kalman filter to the contact periods (i.e., the tip movement is constrained within a contact period)
    cpt = all(~isnan(tip_f'))'; % first find where it is not a NaN
    ccomp = [0; cpt; 0]; % add these for easier diffing (and force first frame to be a start)
    difc = diff(ccomp);
    cStart = find(difc == 1);  % mark where all contacts START
    cEnd = find(difc == -1) - 1; % mark where all contacts START
    
    % preallocate the tip output
    tip_out = nan(size(tip_f));
    r = nanvar(tip_f);
    
    % loop over all the contact periods
    for ii = 1:length(cStart)
        % If the contact period is less than 3 bins long, skip it.
        if (cEnd(ii)-cStart(ii))<3
            continue
        end
        
        % apply the kalman filter
        [x,y,z] = applyKalman(tip_f(cStart(ii):cEnd(ii),:),r);
        tip_out(cStart(ii):cEnd(ii),:) = [x' y' z'];
    end
    
    tip_out(all(tip_out'==0),:) = NaN;
else
    tip_out = tip_f;
end

%% replace the tip of the whisker with the smoothed whisker.
if nargout == 2
    warning('It is highly recommended NOT to replace the tip position')
    wstruct3D_out = wstruct3D;
    for ii = 1:length(wstruct3D)
        if ~isempty(wstruct3D(ii).x)
            wstruct3D_out(ii).x(node_num) = tip_out(ii,1);
            wstruct3D_out(ii).y(node_num) = tip_out(ii,2);
            wstruct3D_out(ii).z(node_num) = tip_out(ii,3);
        end
    end
end

end
%% LOCAL function: applyKalman
function [x,y,z] = applyKalman(pos,r)

%position must be a 3 x N time series of points.
% you will probably want to play around with the variances and noises and such.
if size(pos,2)<size(pos,1)
    pos = pos';
end

% create state matrix
vel = [[0;0;0]  diff(pos')'];
acc = [[0;0;0] diff(vel')'];
state = [pos;vel;acc];



% Measurement model.
H = [1 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0];

% Variance in the measurements.
% number must be the siz eof the input dims
R = diag([r]);

% Transition matrix for the continous-time system.
F = [0 0 0 1 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 1 0;
    0 0 0 0 0 0 0 0 1;
    0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0];

% Noise effect matrix for the continous-time system.
L = [0 0 0;
    0 0 0;
    0 0 0;
    0 0 0;
    0 0 0;
    0 0 0;
    1 0 0;
    0 1 0;
    0 0 1];
%Stepsize
dt = 0.5;

% Process noise variance
q = 0.2;
Qc = diag([q q q]);

% Discretization of the continous-time system.
[A,Q] = lti_disc(F,L,Qc,dt);

% Initial guesses for the state mean and covariance.
m = state(:,1);
P = diag([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.5 0.5]);

MM = zeros(size(m,1), size(state,2));
PP = zeros(size(m,1), size(m,1), size(state,2));

% Filtering steps.
for i = 1:size(state,2)
    
    
    [m,P] = kf_predict(m,P,A,Q);
    [m,P] = kf_update(m,P,pos(:,i),H,R);
    MM(:,i) = m;
    PP(:,:,i) = P;
end


% Smoothing step.
[SM,SP] = rts_smooth(MM,PP,A,Q);
[SM2,SP2] = tf_smooth(MM,PP,pos,A,Q,H,R,1);
x = SM(1,:);
y = SM(2,:);
z = SM(3,:);
end %EOLF

