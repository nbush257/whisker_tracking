function 
% start parallel pool
parpool
% sort the whisker along the x axis
t3d = sort3Dwhisker(tracked_3D);
% smooth the whisker
t3ds = smooth3DWhisker(t3d);

% Find the contact point and extend whisker where needed

[CP,~,t3dsext] = get3DCP_hough(manip,t3ds,calib,C);

% smooth the basepoint


% smooth the contact point
CPout = cleanCP(CP);

% In case the contact point is not on the whisker after smoothing, put it
% back on the whisker.

[~,CPclean] = CPonWhisker(CPout,t3dsext);

% Prepare for E3D
xw3d = {t3dsext.x};
yw3d = {t3dsext.y};
zw3d = {t3dsext.z};

% clean first few nodes
BP = get3DBP(t3dsext);

%% data QC
figure
for ii = find(C,1):1000:length(t3dsext)
    ho
    cla
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'k.-')
    
    plot3(t3dsext(ii).x,t3dsext(ii).y,t3dsext(ii).z,'.','color',[0.5 0.3 0.7])
    
    plot3(CPclean(ii,1),CPclean(ii,2),CPclean(ii,3),'r*')
    
    plot3(BP(ii,1),BP(ii,2),BP(ii,3),'b^')
    
    drawnow
    pause(.05)
    
    
    
    
end

