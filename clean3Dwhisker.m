
function [tracked_3D,shortWhiskers] = clean3Dwhisker(tracked_3D)
%function tracked_3D = clean3Dwhisker(tracked_3D)

% Fixes whiskers that are too short after merge
% Sets the basepoint as the first node
% Interpolates the nodes



rmShort = input('Remove Short Whiskers? (y/n)','s');
interpCheck = input('Interpolate Whisker? Num Nodes = 200 (y/n)','s');
baseOrder = input('Order the wrt basepoint? (y/n)','s');
shortWhiskers = [];
figure
num_interp_nodes = 200;



for ii = 1:100
    if ~strcmp(baseOrder,'y')
        break
    end
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
    %% if the whsiker is short(Bad merge) then use the previous whisker
    if strcmp(rmShort,'y')
        if length(tracked_3D(ii).x)<5 | length(tracked_3D(ii).y)<5 | length(tracked_3D(ii).z)<5
            tracked_3D(ii).x = tracked_3D(ii-1).x;
            tracked_3D(ii).y = tracked_3D(ii-1).y;
            tracked_3D(ii).z = tracked_3D(ii-1).z;
        end
        shortWhiskers = [shortWhiskers ii];
    end
    %% Flip node order if basepoint os not the first node
    if strcmp(baseOrder,'y')
        dis2bp_first = sqrt((tracked_3D(ii).x(1) - bp(1))^2+ (tracked_3D(ii).y(1) - bp(2))^2);
        dis2bp_last = sqrt((tracked_3D(ii).x(end) - bp(1))^2+ (tracked_3D(ii).y(end) - bp(2))^2);
        
        if dis2bp_first>dis2bp_last
            tracked_3D(ii).x = fliplr(tracked_3D(ii).x);
            tracked_3D(ii).y = fliplr(tracked_3D(ii).y);
            tracked_3D(ii).z = fliplr(tracked_3D(ii).z);
        end
    end
    %% interpolate between whisker nodes
    if strcmp(interpCheck,'y')
        xi = linspace(min(tracked_3D(ii).x),max(tracked_3D(ii).x),num_interp_nodes);
        yi = interp1(tracked_3D(ii).x,tracked_3D(ii).y,xi);
        zi = interp1(tracked_3D(ii).x,tracked_3D(ii).z,xi);
        tracked_3D(ii).x = xi;
        tracked_3D(ii).y = yi;
        tracked_3D(ii).z = zi;
    end
end

