% removenon-zero id

function struct = rmNonZeroID(struct)

idx = [struct.id]==0;
struct = struct(idx);
