% merge2E3D

%% load premerge data
%% load merged data
%% load calibration data IMPORTANT TO LOAD THIS LAST!!!
%% 
tracked_3D_raw = tracked_3D;
tracked_3D = spatialWhiskerKalman3D(tracked_3D_raw,.05);


get3dCP_v2

tVid = VideoReader(tV);
fVid = VideoReader(fV);
figure
% Backprojection verification
for ii = 19000:length(tracked_3D)
    idx = CP3D_idx(ii);
    if isempty(tracked_3D(ii).x)
        continue
    end
    topI = read(tVid,ii);
    frontI = read(fVid,ii);
    clf
    
    CPstruct.x = CP3D(ii,1);
    CPstruct.y = CP3D(ii,2);
    CPstruct.z = CP3D(ii,3);
    [wskrTop,wskrFront] = BackProject3D(tracked_3D(ii),topCam,frontCam,A2B_transform);
    [CP_top,CP_front] = BackProject3D(CPstruct,topCam,frontCam,A2B_transform);
    
    subplot(221)
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'.')
    ho
    if C(ii)
    plot3(CP3D(ii,1),CP3D(ii,2),CP3D(ii,3),'r*')
    end
    
    subplot(223)
    imshow(topI)
    ho
    plot(wskrFront(:,1),wskrFront(:,2),'o')
    if C(ii)
    plot(wskrFront(idx,1),wskrFront(idx,2),'r*');
    end
    
    subplot(224)
    imshow(frontI)
    ho
    plot(wskrTop(:,1),wskrTop(:,2),'o')
    if C(ii)
    plot(wskrTop(idx,1),wskrTop(idx,2),'r*');
    end
    pause(.5)
    
end


    