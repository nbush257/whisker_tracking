calib_stuffz;
A_camera = calib(1:4);
B_camera = calib(5:8);
A2B_transform = calib(9:10);

TGL_plot = 1;

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
tVid = VideoReader(tV);
fVid = VideoReader(fV);
if TGL_plot
    figure
    find(C)
    first = ans(1);
    Itop = read(tVid,first);
    Ifront = read(fVid,first);
    
    wskr3D = tracked_3D(first);
    [wskr_front,wskr_top] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
    subplot(211)
    imshow(Ifront)
    ho
    plot(wskr_front(:,1),wskr_front(:,2),'o');
    plot(f(first).x,f(first).y,'.');
    legend('backProj','Raw Tracks')
    subplot(212)
    imshow(Itop)
    ho
    plot(wskr_top(:,1),wskr_top(:,2),'o')
    plot(t(first).x,t(first).y,'.')
    legend('backProj','Raw Tracks')
    viewCheck = input('Are the views lining up (Y/N)? If not, you might need to flip the camera/whisker label.','s');
    
end


w = waitbar(0,'We are getting the contact point')
for ii = 1:numFrames
    waitbar(ii/numFrames,w,'Getting Contact Point')
    
    if strcmp('N',viewCheck)
        break
    end
    
    wskr3D = tracked_3D([tracked_3D.time]==ii-1);
    if isempty(wskr3D)
        continue
    end
    if isempty(wskr3D.x)
        continue
    end
    if length(wskr3D.x)<10
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
        [wskr_front,wskr_top] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
        f_man_x = fManip([fManip.time]==ii-1).x;
        f_man_y = fManip([fManip.time]==ii-1).y;
        f_man = [f_man_x f_man_y];
        [k,d] = dsearchn(wskr_front,f_man);
        idx = k(d==min(d));
        
    end
    if useFront(ii) == 0
        [wskr_front,wskr_top] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
        t_man_x = tManip([tManip.time]==ii-1).x;
        t_man_y = tManip([tManip.time]==ii-1).y;
        
        t_man = [t_man_x t_man_y];
        [k,d] = dsearchn(wskr_top,t_man);
        idx = k(d==min(d));
        
    end
    CP3D(ii,:) = [wskr3D.x(idx),wskr3D.y(idx),wskr3D.z(idx)];
    CP3D_idx(ii) = idx;
    
    
    if TGL_plot & ~mod(ii,1000)
        clf
        Itop = read(tVid,ii);
        Ifront = read(fVid,ii);
        wskr3D = tracked_3D(ii);
        [wskr_front,wskr_top] = BackProject3D(wskr3D,B_camera,A_camera,A2B_transform);
        subplot(211)
        imshow(Ifront)
        ho
        plot(wskr_front(:,1),wskr_front(:,2),'o');
        plot(f(ii).x,f(ii).y,'.');
        plot(f_man(:,1),f_man(:,2),'x');
        plot(wskr_front(idx,1),wskr_front(idx,2),'r*');
        
        legend('backProj','Raw Tracks','Manipulator','Contact Point')
        subplot(212)
        imshow(Itop)
        ho
        plot(wskr_top(:,1),wskr_top(:,2),'o')
        plot(t(ii).x,t(ii).y,'.')
        plot(t_man(:,1),t_man(:,2),'x')
        plot(wskr_top(idx,1),wskr_top(idx,2),'r*');
        legend('backProj','Raw Tracks','Manipulator','Contact Point')
    end
    
end
delete(w)