numFrames = max([fMManip.fid])+1;

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

useFront = repmat(-1,numFrames,1);
useFront(lF>lT) = 1;
useFront(lT>lF) = 0;
CP3D = nans(numFrames,3);
for ii = 1:numFrames
    if (useFront(ii) == -1 & C(ii))
        warning(['There is no tracked manipulator during contact at frame ' num2str(ii)]);
        continue
    end
    if (useFront(ii) == -1 | ~C(ii))
        continue
    end
    wskr3D = tracked_3D([tracked_3D.time]==ii-1);
    if useFront(ii) == 1
        [~,wskr_front] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
        [k,d] = dsearchn(wskr_front,fManip([fManip.time]==ii-1));
        idx = k(d==min(d));        
    end
    if useFront(ii) == 0
        [wskr_top,~] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
        [k,d] = dsearchn(wskr_top,tManip([tManip.time]==ii-1));
        idx = k(d==min(d));
        
    end
    CP3D(ii,:) = [wskr3D.x(ind),wskr3D.y(ind),wskr3D.z(ind)];
end