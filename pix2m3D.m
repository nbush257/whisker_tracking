function pix2m = pix2m3D
% get a 3D pixel 2 meter
%%%%% All these settings depend on your images.
plotTGL = 1;
mmD = [];
numCorners =42;
cornersFront = struct([]);
cornersTop = struct([]);
calibSize = 2; % in mm
frontCalib = 'Calib_Results_front.mat';
topCalib = 'Calib_Results_top.mat';
stereoCalib = 'rat2015_15_JUN11_VG_D1_t01_Stereo_calib.mat';
cornerIdx = 1:numCorners;
%% 
load(frontCalib)
numIms = n_ima;
for ii = 1:numIms
    cornerIdx =cornerIdx + numCorners;
    load(frontCalib);
    if ~active_images(ii)
        continue
        
    end
    eval( ['cornersFront(ii).x = y_' num2str(ii) '(1,:);']);
      eval( ['cornersFront(ii).y = y_' num2str(ii) '(2,:);']);
    
    load(topCalib);
    if ~active_images(ii)
        continue
        
    end
    eval( ['cornersTop(ii).x = y_' num2str(ii) '(1,:);']);
      eval( ['cornersTop(ii).y = y_' num2str(ii) '(2,:);']);
    
end
clearvars -except cornersFront cornersTop stereoCalib numIms numCorners calibSize plotTGL mmD
load(stereoCalib)
calib_stuffz
A_camera = calibration(1:4);%
B_camera = calibration(5:8);
A2B_transform = calibration([9 10]);


for ii = 1:length(cornersFront)
    fprintf('%0.2f Percent done \n',100*(ii-1)/length(cornersFront));
    if ~active_images(ii)
        continue
    end
    for jj = 1:length(cornersFront(ii).x)
        [x(ii,jj),y(ii,jj),z(ii,jj)] = Fit_3dBasepoint(...
            cornersFront(ii).x(jj),cornersFront(ii).y(jj),...
            cornersTop(ii).x(jj),cornersTop(ii).y(jj),...
            'A_proj',A_camera,...
            'B_proj',B_camera,...
            'A2B_transform',A2B_transform,'Plot_Final',0);
    end
    PTS(ii).x = x(ii,:);
    PTS(ii).y = y(ii,:);
    PTS(ii).z = z(ii,:);
    
    if plotTGL
        clf
    [PTS_top,PTS_front] = BackProject3D(PTS(ii),B_camera,A_camera,A2B_transform);
    subplot(121)
    title('Top')
    plot(PTS_top(:,1),PTS_top(:,2),'.')
    ho
    plot(cornersTop(ii).x,cornersTop(ii).y,'o')
    
    subplot(122)
    title('Front')
    plot(PTS_front(:,1),PTS_front(:,2),'.')
    ho
    plot(cornersFront(ii).x,cornersFront(ii).y,'o')
    pause(.01)
    
    end
    pts = [x(ii,:);y(ii,:);z(ii,:)];
    for jj = 1:numCorners
        [~,d] = dsearchn(pts(:,ii)',pts');
        d(abs(d)<.0001)=Inf;
        mD(jj) = min(d);
    end
    mmD =[mmD mean(mD)];
    
end
pix2m = mean(mmD)/calibSize/1000; % 







