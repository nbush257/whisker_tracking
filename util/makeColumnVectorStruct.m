function w_struct = makeColumnVectorStruct(w_struct)
%% function w_struct = makeColumnVectorStruct(w_struct)
% this is a quick function to make sure all the xy(z) points of a whisker
% struct are column vectors;
% NEB
%%

for ii = 1:length(w_struct)
    w_struct(ii).x = w_struct(ii).x(:);
    w_struct(ii).y = w_struct(ii).y(:);
    if isfield(w_struct,'z')
    w_struct(ii).z = w_struct(ii).z(:);
    end
end

    