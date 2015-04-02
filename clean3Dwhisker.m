
function [tracked_3D,shortWhiskers] = clean3Dwhisker(tracked_3D)
%% function tracked_3D = clean3Dwhisker(tracked_3D)
%--------------------------------------------------------------
% Fixes whiskers that are too short after merge
% Sets the basepoint as the first node
% Interpolates the nodes
% -------------------------------------------------------------
% INPUT:
%       tracked_3D      = a 3d whisker struct with x,y,z and time fields.
% OUTPUTS:
%       tracked_3D      = the processed 3D whisker struct with x,y,z, and time
%                       fields
%       shortWhiskers   = a 1 x N vector of frame indices where the whisker
%                         was too short and had to be copied from the previous frame
% ---------------------------------------------------------------
% NOTES:


rmShort = input('Remove Short Whiskers? (y/n)','s');
interpCheck = input('Interpolate Whisker? Num Nodes = 200 (y/n)','s');
baseOrder = input('Order the wrt basepoint? (y/n)','s');

shortWhiskers = [];
figure
num_interp_nodes = 200;



for ii = 1:300
    if ~strcmp(baseOrder,'y')
        break
    end
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'.')
    ho
    plot3(tracked_3D(ii).x(1),tracked_3D(ii).y(1),tracked_3D(ii).z(1),'ro')
    pause(.02)
    if ii~=300
    cla
    end
end
input('-------------------------------- \nFlip the Basepoint? \n (y) to flip \n (n) to keep \n (z) if basepoint is not consistent on one side \n','s');
close all

% if the basepoint isn't consistently on one side.
if strcmp(baseOrder,'z')
    [dis2bp_first, dis2bp_last] = plotGinput2D(tracked_3D);
end


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
    %% If basepoint isn't consistent on one side, makes it so.
    if strcmp(baseOrder,'z')
        dis2bp_first = sqrt((tracked_3D(ii).x(1) - bp(1))^2+ (tracked_3D(ii).y(1) - bp(2))^2);
        dis2bp_last = sqrt((tracked_3D(ii).x(end) - bp(1))^2+ (tracked_3D(ii).y(end) - bp(2))^2);
        
        if dis2bp_first>dis2bp_last
            disp('You should not be here. I did not expect this issue to occur. Now you have to write code that makes the BP consistent on one side.')
        end
    end
    
    %% If the basepoint is on the wrong side
    if strcmp(baseOrder,'y')
        tracked_3D(ii).x = fliplr(tracked_3D(ii).x);
        tracked_3D(ii).y = fliplr(tracked_3D(ii).y);
        tracked_3D(ii).z = fliplr(tracked_3D(ii).z);
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
end %EOF



function [dis2bp_first, dis2bp_last] = plotGinput2D(tracked_3D)
warning('This has not been debugged because no one expects it to happen.')
% if you find yourself here, we are getting a UI for the basepoint an
% finding the node closest to it.

for ii = 1:300
    if ~strcmp(baseOrder,'y')
        break
    end
    plot2(tracked_3D(ii).x,tracked_3D(ii).y,'.')
    pause(.02)
    if ii ~= 3
        cla
    else
        bp = ginput(1);
    end
    
end

end


