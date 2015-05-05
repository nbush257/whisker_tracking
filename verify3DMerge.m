
for ii= 1:20000
    if isempty(tracked_3D(ii).x)
        continue
    end

    [wskr_top,wskr_front] = BackProject3D(tracked_3D(ii),calib(5:8),calib(1:4),calib(9:10));
    subplot(121)
    plot(wskr_top(:,1),wskr_top(:,2),'.')
    hold on
    plot(t(ii).x,t(ii).y,'.')
    
    subplot(122)
   
    
    plot(wskr_front(:,1),wskr_front(:,2),'.')
    hold on
    plot(f(ii).x,f(ii).y,'.')
    
    
    pause(.01)
    clf
end
