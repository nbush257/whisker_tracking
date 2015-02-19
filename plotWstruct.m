% plot whisker from struct
w = front_manip_removed;

for ii = startFrame:endFrame
    scatter(w(ii).x,w(ii).y,'k.')
    axis([0 640 0 480])
    pause(.01)
    
end
