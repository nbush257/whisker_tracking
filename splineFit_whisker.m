function [xs,ys] = splineFit_whisker(xw,yw,numNodes,plotTGL)
%% function xs,ys = splineFit_whisker(xw,yw,[numNodes],[plotTGL])
% Smooths a 2D whisker by using splinefit from Jonas Lundgren
% =================================================
% INPUTS:   xw - a N cell array of whisker x points (each cell is a frame)
%           yw - a N element cell array of whisker y points
%           numNodes - number of nodes to use in the splinefit. Chris seemed
%           to use 4 most of the time.
% OUTPUTS:  xs - smoothed x points
%           ys - smoothed y points.
% =================================================
% Nick Bush, adapted from Chris Schroeder. 2016_05_11
% Needs the splinefit functions from Jonas Jundgren
%% Handle optional input

if nargin <=2
    numNodes = 4;
    plotTGL = 0;
end
if nargin <=3
    plotTGL = 0;
end



%% Fit spline to data
xs = [];
ys = [];
for ii = 1:length(xw),
    xx = []; yy = []; PP = [];
    if ~isempty(xw{ii}),
        xw{ii} = double(xw{ii});
        yw{ii} = double(yw{ii});
        PP = splinefit(xw{ii},yw{ii},numNodes);
        xx = min(xw{ii}):1:max(xw{ii});
        yy = ppval(PP,xx);
        xs{ii} = xx;
        ys{ii} = yy;
        if mod(ii,100)==0 && plotTGL
            figure(3000); clf(3000);
            plot(xw{ii},yw{ii},'b.'); hold on;
            plot(xx,yy,'r-');
            title(['Step: ',num2str(ii)],'FontWeight','bold');
            axis equal;
            drawnow
        end
    else
        xs{ii} = [];
        ys{ii} = [];
    end
end