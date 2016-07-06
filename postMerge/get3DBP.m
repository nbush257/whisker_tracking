function node = get3DBP(w,varargin)
%% function BP = get3DBP(w,[node_choice])
%{
This function is a shortcut to just grab the nth point of a 3D whisker
structure.

Defaults to grabbing the first node (BP) as that is the most useful.
%}
%% Input handling

numvargs = length(varargin);
% set defaults
optargs = {1};
% overwrite user supplied args
optargs(1:numvargs) = varargin;
[node_choice] = optargs{:};


%%
node = nan(length(w),3);

for ii = 1:length(w)
    if ~isempty(w(ii).x)
        if length(w(ii).x)>=node_choice
            node(ii,:) = [w(ii).x(node_choice) w(ii).y(node_choice) w(ii).z(node_choice)];
        end
        
    end
    
end

end


