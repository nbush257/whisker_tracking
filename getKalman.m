<<<<<<< HEAD

function kf = getKalman(dim, varianceIn)
%% function kf = getKalman(dim, varianceIn)
% Builds a general simple linear Kalman filter for an N dimensional model.


% build measurement model:
H = zeros(dim,dim^2);
% Measurement Variance
R = diag(repmat(varianceIn,1,dim));
% Transition Matrix
v = repmat(1,1,dim*2);
F = diag(v,dim);
% Noise Effect Matrix
l = diag(v,-dim*2);
L = l(1:dim^2,1:dim);

%Step Size
dt = .5;

% process noise variance
q = 0.2;
Qc = diag(repmat(q,1,dim));

% Discretization of the time- continuous signal

[A,Q] = lti_disc(F,L,Qc,dt);
P = diag([repmat(varianceIn,1,dim*2) repmat(varianceIn*5,1,dim)]);


kf.A =A;
kf.Q = Q;
kf.H = H;
kf.R = R;
kf.F = F;
kf.L = L;
kf.P = P;
end %EOF

=======

function kf = getKalman(dim, varianceIn)
%% function kf = getKalman(dim, varianceIn)
% Builds a general simple linear Kalman filter for an N dimensional model.


% build measurement model:
H = zeros(dim,dim^2);
% Measurement Variance
R = diag(repmat(varianceIn,1,dim));
% Transition Matrix
v = repmat(1,1,dim*2);
F = diag(v,dim);
% Noise Effect Matrix
l = diag(v,-dim*2);
L = l(1:dim^2,1:dim);

%Step Size
dt = .5;

% process noise variance
q = 0.2;
Qc = diag(repmat(q,1,dim));

% Discretization of the time- continuous signal

[A,Q] = lti_disc(F,L,Qc,dt);
P = diag([repmat(varianceIn,1,dim*2) repmat(varianceIn*5,1,dim)]);


kf.A =A;
kf.Q = Q;
kf.H = H;
kf.R = R;
kf.F = F;
kf.L = L;
kf.P = P;
end %EOF

>>>>>>> 3d2da9842f657a8ee0b04374a039dc87f826b925
