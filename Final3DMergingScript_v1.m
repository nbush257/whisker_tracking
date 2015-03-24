%% Whisker I:

clc
clear all
close all

load 'all_whiskers_top.mat' %top-down data
load 'c1_c2_c3_whiskers_front.mat' %front-on data

%% Notes:
% Currently comparing whisker 4 from top down view with whisker 1 from
% front on view.

% This particular input has vectors arranged from tip to base (hence
% flipping of vectors before merging.

% Inputs: n = # of frames analyzing

%% Extracting front on and top down points from free-air tracking:

%Input number of frames (i.e. cell arrays) to loop through AND FrameStartNum:
n = 2;
FrameStartNum = 437;%110; %Note: Frame 1 corresponds to ".../_20750.tif'

%Input whisker analyzing:
fWhisker = 1; %Front-on Whisker = 1
tWhisker = 4; %Top-down Whisker = 4

xf = cell(1,n);
yf = cell(1,n);

xt = cell(1,n);
yt = cell(1,n);

for i = 1:n
    xf{i} = all_whiskers_xf{1,FrameStartNum+i-1}(:,fWhisker);
    xf{i}(~any(xf{i},2),:) = []; %removes zeros in rows
    yf{i} = all_whiskers_yf{1,FrameStartNum+i-1}(:,fWhisker);
    yf{i}(~any(yf{i},2),:) = []; %removes zeros in rows
    xt{i} = all_whiskers_xt{1,FrameStartNum+i-1}(:,tWhisker);
    xt{i}(~any(xt{i},2),:) = []; %removes zeros in rows
    yt{i} = all_whiskers_yt{1,FrameStartNum+i-1}(:,tWhisker);
    yt{i}(~any(yt{i},2),:) = []; %removes zeros in rows

%% Display images and check for base point:

    % Front on:
figure;
imgf = imread(['C:/Users/Hayley/Documents/HartmannLabResearch/JamesFreeAir/SingleRow/140710_singlerow_3_fr_' num2str(20749+FrameStartNum+i-1) '.tif']);
imshow(imgf)
title('Click on Base Point')
axis on
[xf_base_click,yf_base_click] = ginput(1);

    %Check tip or base:
hold on
plot(xf{i}(1,1),yf{i}(1,1),'rs','MarkerSize',6)

    %Plot entire line:
hold on
plot(xf{i},yf{i},'g','LineWidth',3)

    %Polyfit (manually tracked base point to furthest automatically tracked point):
[pf,Sf] = polyfit(xf{i},yf{i},3);  
xf_new = linspace(xf{i}(1,1),xf_base_click,100);
yf_new = pf(1,1).*xf_new.^3+pf(1,2).*xf_new.^2+pf(1,3).*xf_new+pf(1,4);
hold on
plot(xf_new,yf_new,'c','LineWidth',3)
hold off
    
%     %Polyfit (manually tracked base point to manually tracked tip point):
% title('Click on Tip Point')
% [xf_tip_click,yf_tip_click] = ginput(1);
%     %Polyfit with tip:
% xf_new = linspace(xf_tip_click,xf_base_click,100);
% yf_new = pf(1,1).*xf_new.^3+pf(1,2).*xf_new.^2+pf(1,3).*xf_new+pf(1,4);
% hold on
% plot(xf_new,yf_new,'m','LineWidth',3)
% hold off

    % Top down:
figure
imgt = imread(['C:/Users/Hayley/Documents/HartmannLabResearch/JamesFreeAir/SingleRow/140710_singlerow_3_tp_' num2str(20749+FrameStartNum+i-1) '.tif']);
imshow(imgt)
title('Click on Base Point for Whisker Analyzing')
axis on
[xt_base_click,yt_click] = ginput(1);

    %Check tip or base:
hold on
plot(xt{i}(1,1),yt{i}(1,1),'rs','MarkerSize',6)

    %Plot entire line:
hold on
plot(xt{i},yt{i},'g','LineWidth',3)

    %Polyfit (manually tracked base point to furthest automatically tracked point): 
[pt,St] = polyfit(xt{i},yt{i},3);
xt_new = linspace(xt{i}(1,1),xt_base_click,100);
yt_new = pt(1,1).*xt_new.^3+pt(1,2).*xt_new.^2+pt(1,3).*xt_new+pt(1,4);
hold on
plot(xt_new,yt_new,'c','LineWidth',3)
hold off

%   %Polyfit (manually tracked base point to manually tracked tip point):
% title('Click on Tip Point')
% [xt_tip_click,yt_tip_click] = ginput(1);
%    %Polyfit with tip:
% xt_new = linspace(xt_tip_click,xt_base_click,100);
% yt_new = pt(1,1).*xt_new.^3+pt(1,2).*xt_new.^2+pt(1,3).*xt_new+pt(1,4);
% hold on
% plot(xt_new,yt_new,'c','LineWidth',3)
% hold off

%% Flip vectors left to right, so merging from the base point:

xf_final = fliplr(xf_new);
yf_final = fliplr(yf_new);
xt_final = fliplr(xt_new);
yt_final = fliplr(yt_new);

%% Call 3D Merge:

    %note: must list front coordinates first, then top-down
[tracked_3D{i}(:,1),tracked_3D{i}(:,2),tracked_3D{i}(:,3)] = Merge3D(xf_final,yf_final,xt_final,yt_final);

%% Plotting:
figure;
hold on
x = smooth(tracked_3D{i}(:,1));
y = smooth(tracked_3D{i}(:,2));
z = smooth(tracked_3D{i}(:,3));
h = plot3(x,y*cos(-pi/2)-z*sin(-pi/2),y*sin(-pi/2)+z*cos(-pi/2));
axis equal
grid on
ln3
end