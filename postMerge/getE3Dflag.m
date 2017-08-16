%make E3D flag
xl = cellfun(@length,xw3d)~=0;
yl = cellfun(@length,yw3d)~=0;
zl = cellfun(@length,zw3d)~=0;

CP_flag = any(isfinite(CP),2);

cat = [xl(:) yl(:) zl(:) CP_flag(:) C(:)];
E3D_flag = all(cat,2);
clear cat xl yl zl CP_flag
