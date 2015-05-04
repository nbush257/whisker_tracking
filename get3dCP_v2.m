numFrames = max([fMManip.fid])+1;
A_camera = frontCam;
B_camera = topCam;



fManip = struct([]);
tManip = struct([]);
numFrames = max([fMManip.fid])+1;
frontMeasure = fMManip([fMManip.label]==0);
ID = [[frontMeasure.fid];[frontMeasure.wid]]';
traceID = [[fTManip.time];[fTManip.id]]';
traceIDX = ismember(traceID,ID,'rows');
fManip = fTManip(traceIDX);

topMeasure = tMManip([tMManip.label]==0);
ID = [[topMeasure.fid];[topMeasure.wid]]';
traceID = [[tTManip.time];[tTManip.id]]';
traceIDX = ismember(traceID,ID,'rows');
tManip = tTManip(traceIDX);

frontL = zeros(numFrames,1);
topL = zeros(numFrames,1);

frontL([frontMeasure.fid]+1)=[frontMeasure.length];
topL([topMeasure.fid]+1)=[topMeasure.length];

useFront = nan(numFrames,1);
useFront(topL==0 & frontL ==0) = -1;
useFront(topL>frontL) = 0;
useFront(frontL>topL)=1;

CP3D = nan(numFrames,3);
badFrames = [];

for ii = 1:numFrames
    wskr3D = tracked_3D([tracked_3D.time]==ii-1);
    if isempty(wskr3D)
        continue
    end
    if isempty(wskr3D.x)
       continue
    end
    
    if (useFront(ii) == -1 & C(ii))
        warning(['There is no tracked manipulator during contact at frame ' num2str(ii)]);
        badFrames = [badFrames ii-1];
        continue
    end
%     if (useFront(ii) == -1 | ~C(ii))
%         continue
%     end
    
    if useFront(ii) == 1
        [wskr_top,wskr_front] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
        man = [fManip([fManip.time]==ii-1).x fManip([fManip.time]==ii-1).y];
        [k,d] = dsearchn(wskr_front,man);
        idx = k(d==min(d));
    end
    if useFront(ii) == 0
        [wskr_top,wskr_front] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
        man = [tManip([tManip.time]==ii-1).x tManip([tManip.time]==ii-1).y];
        [k,d] = dsearchn(wskr_top,man);
        idx = k(d==min(d));
        
    end
    CP3D(ii,:) = [wskr3D.x(idx),wskr3D.y(idx),wskr3D.z(idx)];
end