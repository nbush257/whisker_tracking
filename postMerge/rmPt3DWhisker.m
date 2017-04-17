function w_struct3D = rmPt3DWhisker(w_struct3D,varargin)
%% function rmPt3DWhisker(w_struct3D,varargin)
% removes a point from a 3D whisker structure. This is useful because the
% second point in a 3D whisker is usually a bad point. Defaults to removing
% pt 2
%% 

if length(varargin)==1
    node_num = varargin{1};
else
    node_num = 2;
end

%%
for ii = 1:length(w_struct3D)
    if isempty(w_struct3D(ii).x) || length(w_struct3D(ii).x) < node_num
        continue
    end
    w_struct3D(ii).x(node_num) = [];
    w_struct3D(ii).y(node_num) = [];
    w_struct3D(ii).z(node_num) = [];
end