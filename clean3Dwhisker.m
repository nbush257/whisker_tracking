
function tracked_3D = clean3Dwhisker(tracked_3D)
%function tracked_3D = clean3Dwhisker(tracked_3D)

% Fixes whiskers that are too short after merge
% Sets the basepoint as the first node
% Interpolates the nodes

num_interp_nodes = 200;


%% get UI for the basepoint

for ii = 1:100
    plot(tracked_3D(ii).x,tracked_3D(ii).y,'.')
    pause(.02)
    if ii ~=100
        cla
    else
        
        title('Click on the basepoint');
        bp = ginput(1);
    end
end    
close all
%
for ii = 1:length(tracked_3D)
    %% if the whsiker is short( Bad merge) then use the previous whisker
    if length(tracked_3D(ii).x)<2 | length(tracked_3D(ii).y)<2 | length(tracked_3D(ii).z)<2
        tracked_3D(ii).x = tracked_3D(ii-1).x;
        tracked_3D(ii).y = tracked_3D(ii-1).y;
        tracked_3D(ii).z = tracked_3D(ii-1).z;
    end
    
    %% Flip node order if basepoint os not the first node
    dis2bp_first = sqrt((tracked_3D(ii).x(1) - bp(1))^2+ (tracked_3D(ii).y(1) - bp(2))^2);
    dis2bp_last = sqrt((tracked_3D(ii).x(end) - bp(1))^2+ (tracked_3D(ii).y(end) - bp(2))^2);
    
    if dis2bp_first>dis2bp_last
        tracked_3D(ii).x = fliplr(tracked_3D(ii).x);
        tracked_3D(ii).y = fliplr(tracked_3D(ii).y);
        tracked_3D(ii).z = fliplr(tracked_3D(ii).z);
    end
    
    
    %% interpolate between whisker nodes
    xi = linspace(min(tracked_3D(ii).x),max(tracked_3D(ii).x),num_interp_nodes);
    yi = interp1(tracked_3D(ii).x,tracked_3D(ii).y,xi);
    zi = interp1(tracked_3D(ii).x,tracked_3D(ii).z,xi);
    tracked_3D(ii).x = xi;
    tracked_3D(ii).y = yi;
    tracked_3D(ii).z = zi;
    
end

