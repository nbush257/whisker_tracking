function [BPout, wStruct3D_out] = clean3D_BP(wstruct3D)
%% function wStruct3D_out = clean3D_BP(wstruct3D)
% Once you have a merged 3D whisker we should smooth the basepoint again in
% 3D
BP = nan(length(wstruct3D),3);
for ii = 1:length(wstruct3D)
    if ~isempty(wstruct3D(ii).x)
        BP(ii,:) = [wstruct3D(ii).x(1) wstruct3D(ii).y(1) wstruct3D(ii).z(1)];
    end
end
BPf = medfilt1(BP,5);

for ii = 1:3
    BPf(:,ii) = InterpolateOverNans(BPf(:,ii),20);
end
for ii = 1:3
    BPf(:,ii) = deleteoutliers(BPf(:,ii),.0001,1);
    BPf(:,ii) = InterpolateOverNans(BPf(:,ii),20);
end

cpt = all(~isnan(BPf'))'; % first find where it is not a NaN
ccomp = [0; cpt; 0]; % add these for easier diffing (and force first frame to be a start)
difc = diff(ccomp);
cStart = find(difc == 1);  % mark where all whisks START
cEnd = find(difc == -1) - 1;

% preallocate the CP output
BPout = nan(size(BPf));
r = nanvar(BPf);
% loop over all the contact periods
for ii = 1:length(cStart)
    % If the contact period is less than 3 bins long, skip it.
    if (cEnd(ii)-cStart(ii))<3
        continue
    end
    
    % apply the kalman filter
    [x,y,z] = applyKalman(BPf(cStart(ii):cEnd(ii),:),r);
    BPout(cStart(ii):cEnd(ii),:) = [x' y' z'];
end

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
BPout(all(BPout'==0),:) = NaN;
wstruct3D_out = wstruct3D;
for ii = 1:length(wstruct3D)
    if ~isempty(wstruct3D(ii).x)
        wstruct3D_out(ii).x(1) = BPout(ii,1);
        wstruct3D_out(ii).y(1) = BPout(ii,2);
        wstruct3D_out(ii).z(1) = BPout(ii,3);
    end
end

end
