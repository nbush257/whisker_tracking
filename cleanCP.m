function CPout = cleanCP(CP,C)
%% function CPout = cleanCP(CP)
CPf = medfilt1(CP,5);
r = nanvar(CPf);
cStart = find(diff(C)==1)+1;
cEnd = find(diff(C)==-1);
CPout = nan(size(CP));
for ii = 1:length(cStart)
    [x,y,z] = applyKalman(CPf(cStart(ii):cEnd(ii)),:);
    CPout(cStart(ii):cEnd(ii),:) = [x y z];
end



function [x,y,z] = applyKalman(pos,r)

%position must be a 3 x N time series of points.
% you will probably want to play around with the variances and noises and such.

% create state matrix
vel = [0 0 0 ;diff(pos')];
acc = [0 0 0 ;diff(vel)];
state = [pos' vel acc]';



% Measurement model.
H = [1 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0];

% Variance in the measurements.
% number must be the siz eof the input dims
R = diag([r r r]);

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
end