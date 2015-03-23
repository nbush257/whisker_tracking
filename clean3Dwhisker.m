%clean 3D whisker struct
function tracked_3D = clean3Dwhisker(tracked_3D)
% if a merged whisker isn't long enough, take the points from the previous
% frame. Not a great fix, but might work

for ii = 1:length(tracked_3D)
    if length(tracked_3D(ii).x)<2 | length(tracked_3D(ii).y)<2 | length(tracked_3D(ii).z)<2
        tracked_3D(ii).x = tracked_3D(ii-1).x;
        tracked_3D(ii).y = tracked_3D(ii-1).y;
        tracked_3D(ii).z = tracked_3D(ii-1).z;
    end
end

