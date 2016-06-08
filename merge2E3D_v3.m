%% init saving filename
fname = ''

% start parallel pool
parpool
% sort the whisker along the x axis
t3d = sort3Dwhisker(tracked_3D);

% smooth the whisker
t3d= smooth3DWhisker(t3d);
save(fname)
% get contact manually
C = getContact_from3D(t3d);
save(fname)
% Find the contact point and extend whisker where needed
[CPraw,~,t3d] = get3DCP_hough(manip,t3d,calib,C);
save(fname)
% smooth the contact point
CP = cleanCP(CPraw);

% In case the contact point is not on the whisker after smoothing, put it
% back on the whisker.

[~,CP] = CPonWhisker(CP,t3d);

% Prepare for E3D
xw3d = {t3d.x};
yw3d = {t3d.y};
zw3d = {t3d.z};

% extract the basepoint
BP = get3DBP(t3d);
save(fname)

%% data QC
figure
for ii = find(C,1):1000:length(t3d)
    ho
    cla
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'k.-')
    
    plot3(t3d(ii).x,t3d(ii).y,t3d(ii).z,'.','color',[0.5 0.3 0.7])
    
    plot3(CP(ii,1),CP(ii,2),CP(ii,3),'r*')
    
    plot3(BP(ii,1),BP(ii,2),BP(ii,3),'b^')
    
    drawnow
    pause(.05)
    
end


