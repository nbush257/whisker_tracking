function BP = get3DBP(w)
%% function BP = get3DBP(w)
%{
This function is a shortcut to just grab the first point of a 3D whisker
structure.
%}
%%
BP = nan(length(w),3);

for ii = 1:length(w)
    if ~isempty(w(ii).x)
        BP(ii,:) = [w(ii).x(1) w(ii).y(1) w(ii).z(1)];
    end
    
end

end


