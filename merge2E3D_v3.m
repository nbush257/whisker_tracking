% sort the whisker along the x axis
t3d = sort3Dwhisker(tracked3D);
% smooth the whisker 

t3ds = smooth3DWhisker(t3d);

% Find the contact point and extend whisker where needed

[CP,~,t3dsext] = get3DCP_hough(Y0_f,Y1_f,Y0_t,Y1_t,t3ds,calibInfo,C);

% Interpolate the whisker to have a lot of points
t3dsin = interp3Dwhisker(t3dsext);

% smooth the contact point
CPout = cleanCP(CP);

% In case the contact point is not on the whisker after smoothing, put it
% back on the whisker.

[~,CPclean] = CPonWhisker(CPout,t3dsin);


% Prepare for 
xw3d = {t3dsin.x};
yw3d = {t3dsin.y};
zw3d = {t3dsin.z};

BP = clean3D_BP(t3dsin);