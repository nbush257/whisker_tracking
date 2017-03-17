function wstruct3D = createWStruct3D(x,y,z)
%% function wstruct3D = createWStruct3D(x,y,z)
assert(iscell(x))
assert(iscell(y))
assert(iscell(z))


assert(length(x)==length(y));
assert(length(y)==length(z));

for ii = 1:length(x)
    assert(length(x{ii}) == length(y{ii}));
    assert(length(y{ii}) == length(z{ii}));
    wstruct3D(ii).x = x{ii};
    wstruct3D(ii).y = y{ii};
    wstruct3D(ii).z = z{ii};
end

