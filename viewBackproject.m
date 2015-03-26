

for ii = 1:length(tracked_3D)
    [wskr_top,wskr_front] = BackProject3D(tracked_3D(ii),B_camera,A_camera,A2B_transform);
    subplot(121)
    plot(front_manip_removed(ii).x,front_manip_removed(ii).y,'.')
    ho
    plot(wskr_front(:,1),wskr_front(:,2),'r.')
    axis equal
    title('front')
    legend({'original tracking','back projection'})
    
    
    
    subplot(122)
    plot(top_manip_removed(ii).x,top_manip_removed(ii).y,'.')
    ho
    plot(wskr_top(:,1),wskr_top(:,2),'r.')
    title('top')
    legend({'original tracking','back projection'})
    axis equal
    pause(.04)
    
    
    clf
end

    