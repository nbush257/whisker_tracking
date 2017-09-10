function extend3DtoLength(t3d)
l = nan(size(t3d));
for ii = 1:length(t3d)
    if ~isempty(t3d(ii).x)
        l(ii) = arclength3d(t3d(ii).x,t3d(ii).y,t3d(ii).z);
    end
end
l = nanmedian(l);
for ii = 1:length(t3d)
    
    xIn = t3d(ii).x;
    yIn = t3d(ii).y;
    zIn = t3d(ii).z;
    if iscolumn(t3d(ii).x)
        xIn = xIn';
        yIn = yIn';
        zIn = zIn';
    end
    
    PP = splinefit(xIn(1:end-2),[yIn(1:end-2);zIn(1:end-2)],numNodes,.5,'r');
    %             coefs(ii,:) = PP.coefs(:);
    xx = min(t3d(ii).x):.5:(max(t3d(ii).x));
    step = median(diff(xx));
    pts = ppval(PP,xx);
    l_temp = arclength3d(xx,pts(1,:),pts(2,:));
    while l_temp<l
        xx = [xx xx(end)+step];
        pts = ppval(PP,xx);
        l_temp = arclength3d(xx,pts(1,:),pts(2,:));
    end
    
    
    
    t3d(ii).x = xx;
    t3d(ii).y = pts(1,:);
    t3d(ii).z = pts(2,:);
end
