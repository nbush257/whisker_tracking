function [pts_out,v_axis_rotated] = rotate_to_axis(pts,v_axis)
%% function [xx,yy,zz] = rotate_to_axis(pts,axis)
% this takes a set of points and rotates them such that the given axis is
% the vertical axis, and the origin is the first point of the given axis.
% This is designed to work with the motor data at the current time, but
% will probably be useful if it gets refactored in the future.
% ========================================================
% INPUTS:   pts -a Nx3 matrix of points that represent the whisker
%           
%           v_axis - a Nx3 matrix of points that defines the vertical axis.
%           We assume the origin is the first row of the matrix
%
% OUTPUTS: pts_out - translated and rotated points of the whisker
% ========================================================
% NEB 20170518
%% 
assert(size(pts,2)==3,'Whisker points are not a Nx3 matrix.')
assert(size(v_axis,2)==3,'Axis is not a Nx3 matrix')
assert(size(v_axis,1)>1,'Not enough points in the axis, need at least 2')
%%
origin = v_axis(1,:);
v_axis = v_axis-v_axis(1,:);
m1_norm = v_axis(end,:)./norm(v_axis(end,:));
r = vrrotvec([0 0 1],m1_norm);
m = vrrotvec2mat(r);
v_axis_rotated = v_axis*m;

pts_out = pts - origin;
pts_out = pts_out*m;


