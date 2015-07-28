function pix2m = pix2m3D
% get a 3D pixel 2 meter
%%%%% All these settings depend on your images.

numIms = 19;
numCorners =25;
cornersFront = struct([]);
cornersTop = struct([]);
calibSize = 2; % in mm
frontCalib = ;
topCalib = ;
stereoCalib = ;
cornerIdx = 1:numCorners;
%% 
for ii = 1:numIms
    cornerIdx =cornerIdx + numCorners;
    load(frontCalib);
    if ~active_images(ii)
        break
        
    end
    cornersFront(ii).x = y(1,cornerIdx);
    cornersFront(ii).y = y(2,cornerIdx);
    
    load(topCalib);
    if ~active_images(ii)
        break
        
    end
    cornersTop(ii).x = y(1,cornerIdx);
    cornersTop(ii).y = y(2,cornerIdx);
    
end
clearvars -except cornersFront cornersTop stereoCalib numIms numCorners calibSize
load(stereoCalib)

A_camera = calibration(1:4);%
B_camera = calibration(5:8);
A2B_transform = calibration([9 10]);


for ii = 1:length(cornersFront)
    fprintf('%0.2f Percent done \n',100*(ii-1)/length(cornersFront));
    
    for jj = 1:numCorners
        [x(ii,jj),y(ii,jj),z(ii,jj)] = Fit_3dBasepoint(...
            cornersFront(ii).x(jj),cornersFront(ii).y(jj),...
            cornersTop(ii).x(jj),cornersTop(ii).x(jj),...
            'A_proj',A_camera,...
            'B_proj',B_camera,...
            'A2B_transform',A2B_transform,'Plot_Final',0);
    end
    pts = [x(ii,:);y(ii,:);z(ii,:)];
    d = pdist2(pts',pts');
    d(d==0) = Inf;
    
    imDist(ii) = mean(min(d));
    
    
end
pix2m = mean(imDist)/calibSize/1000; % 







