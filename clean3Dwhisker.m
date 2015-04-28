
function [tracked_3D,shortWhiskers] = clean3Dwhisker(tracked_3D)
%% function tracked_3D = clean3Dwhisker(tracked_3D)
%--------------------------------------------------------------
% Fixes whiskers that are too short after merge
% Sets the basepoint as the first node
% Interpolates the nodes
% Applies a kalman filter along the length of the whisker to smooth it out.
% NOT IMPLEMENTED: A TEMPORAL KALMAN FILTER TO SMOOTH THE PLOTS IN TIME.
% MAYBE DONT NEED THIS.
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


rmShort = input('Remove Short Whiskers? [Default Y](y/n)','s');
interpCheck = input('Interpolate Whisker? Num Nodes = 200 [Default Y](y/n)','s');

temporalKalman = input('Apply temporal Kalman Filtering to the dataset? [Default N] (y/n)','s');
bpFlip = 'n';
shortWhiskers = [];
figure
num_interp_nodes = 200;

%% get median basepoint
for ii = 1:length(tracked_3D)
    BP(:,ii) = [tracked_3D(ii).x(1),tracked_3D(ii).y(1),tracked_3D(ii).z(1)];
end
initBP = median(BP,2);
%% if the whsiker is short(Bad merge) use the mean of the surrounding whiskers
for ii = 1:length(tracked_3D)
    if strcmp(rmShort,'y')
        if length(tracked_3D(ii).x)<5 | length(tracked_3D(ii).y)<5 | length(tracked_3D(ii).z)<5
            prevW = setInternodeDis(tracked_3D(ii-1),.2);
            nextW = setInternodeDis(tracked_3D(ii+1),.2);
            x = mean([prevW.x;nextW.x]);
            y = mean([prevW.y;nextW.y]);
            z = mean([prevW.z;nextW.z]);
            x(isnan(x)) = [];
            y(isnan(y)) = [];
            z(isnan(z)) = [];
            shortWhiskers = [shortWhiskers ii];
        end
    end
end
for ii = 1:length(tracked_3D)
    %% If basepoint isn't consistent on one side, makes it so.
    if strcmp(bpFlip,'z')
        dis2bp_first = sqrt((tracked_3D(ii).x(1) - bp(1))^2+ (tracked_3D(ii).y(1) - bp(2))^2);
        dis2bp_last = sqrt((tracked_3D(ii).x(end) - bp(1))^2+ (tracked_3D(ii).y(end) - bp(2))^2);
        
        if dis2bp_first>dis2bp_last
            disp('You should not be here. I did not expect this issue to occur. Now you have to write code that makes the BP consistent on one side.')
        end
    end
end



%% interpolate between whisker nodes
for ii = 1:length(tracked_3D)
    if strcmp(interpCheck,'y')
        xi = linspace(min(tracked_3D(ii).x),max(tracked_3D(ii).x),num_interp_nodes);
        yi = interp1(tracked_3D(ii).x,tracked_3D(ii).y,xi);
        zi = interp1(tracked_3D(ii).x,tracked_3D(ii).z,xi);
        tracked_3D(ii).x = xi;
        tracked_3D(ii).y = yi;
        tracked_3D(ii).z = zi;
    end
end

% End of iterate through each whisker.
%% check basepoint
for ii = 200:300
    
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'.')
    ho
    plot3(tracked_3D(ii).x(1),tracked_3D(ii).y(1),tracked_3D(ii).z(1),'ro')
    pause(.02)
    if ii~=300
        cla
    end
end


bpFlip = input('-------------------------------- \nFlip the Basepoint? \n (y) to flip \n (n) to keep \n (z) if basepoint is not consistent on one side \n','s');

close all

if strcmp(bpFlip,'y')
    for ii = 1:length(tracked_3D)
        tracked_3D(ii).x = fliplr(tracked_3D(ii).x);
        tracked_3D(ii).y = fliplr(tracked_3D(ii).y);
        tracked_3D(ii).z = fliplr(tracked_3D(ii).z);
    end
end

% if the basepoint isn't consistently on one side.
if strcmp(bpFlip,'z')
    [dis2bp_first, dis2bp_last] = plotGinput2D(tracked_3D);
end



if strcmp(temporalKalman,'y')
    warning('Sorry, the temporal kalman filter has not been implemented yet.')
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


