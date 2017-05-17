function t3d = trim3DWhisker(t3d)
%% function trim3DWhisker(t3d)
% Removes the last point in the 3D tracking as it is usually not correct
for ii = 1:length(t3d)
    t3d(ii).x = t3d(ii).x(1:end-1);
    t3d(ii).y = t3d(ii).y(1:end-1);
    t3d(ii).z = t3d(ii).z(1:end-1);
end
