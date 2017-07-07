function [t3d,l] = clean3DWhisker(t3d,varargin)
%% function t3d = clean3DWhisker(t3d)
% This function cleans a tracked 3D whisker by removing all whiskers
% smaller than a certain threshold (marking them as empty), and removing
% the last point (which is usually garbage)
%   INPUTS:     t3d - a 3D whisker struct
%   OUTPUTS:    t3d - a cleaned 3D whisker struct
% =============================================
% NEB 20170515
%%
assert(isfield(t3d,'x'),'Not a valid 3D whisker struct')
assert(isfield(t3d,'y'),'Not a valid 3D whisker struct')
assert(isfield(t3d,'z'),'Not a valid 3D whisker struct')
%%
if length(varargin)==1
    l_thresh = varargin{1};
elseif length(varargin)>1
    error('Too many input arguments')
else
    l_thresh = 2;
end
l = zeros(size(t3d));

for ii = 1:length(t3d)
  if length(t3d(ii).x)<l_thresh
      t3d(ii).x = [];
      t3d(ii).y = [];
      t3d(ii).z = [];
      continue
  end
  l(ii) = length(t3d(ii).x);
  t3d(ii).x = t3d(ii).x(1:end-1);
  t3d(ii).y = t3d(ii).y(1:end-1);
  t3d(ii).z = t3d(ii).z(1:end-1);
end




