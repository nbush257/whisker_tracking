function [frontWhskr,topWhskr] = BackProject3D(Whskr,A_camera,B_camera,A2B_transform)
%% function [frontWhskr,topWhskr] = BackProject3D(Whskr,A_camera,B_camera,A2B_transform)
% assumes left is front camera
% A_camera = {fc_left,cc_left,kc_left,alpha_c_left};
% B_camera= {fc_right,cc_right,kc_right,alpha_c_right};
% A2B_transform = {om,T};

for ii = 1:length(Whskr.x)
    % Compute Camera A projection
    [frontWhskr(ii,1),frontWhskr(ii,2)] = Get_3DtoCameraProjection(Whskr.x(ii),Whskr.y(ii),Whskr.z(ii), ...
        'proj',A_camera);
    
    % Convert 3D point in A coordinate frame to B coordinate frame
    % ->  Y = rigid_motion(X,om,T)
    r = rigid_motion([Whskr.x(ii),Whskr.y(ii),Whskr.z(ii)]',A2B_transform{1},A2B_transform{2});
    
    % Compute Camera B projection
    [topWhskr(ii,1),topWhskr(ii,2)] = Get_3DtoCameraProjection(r(1),r(2),r(3), ...
        'proj',B_camera);
    
    % % REF output
    % REF.bp_Ap = [uf;vf];
    % REF.bp_Bp = [ut;vt];
    %
    % % JAE addition 140330
    % REF.attempted_bp_A{length(REF.attempted_bp_A)+1} = [uf;vf];
    % REF.attempted_bp_B{length(REF.attempted_bp_B)+1} = [ut;vt];
    %
    % % Guess 3D point location AGAIN -- JAE addition 140331
    % [nXL,nXR] = stereo_triangulation ...
    %     ([uf;vf],[ut;vt],REF.A2B_transform{1},REF.A2B_transform{2}, ...
    %     REF.A_camera{1},REF.A_camera{2},REF.A_camera{3},REF.A_camera{4}, ...
    %     REF.B_camera{1},REF.B_camera{2},REF.B_camera{3},REF.B_camera{4}); %#ok<NASGU>
    % REF.attempted_3d_bp{length(REF.attempted_3d_bp)+1} = nXL;
    
end