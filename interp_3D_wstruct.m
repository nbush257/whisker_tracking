function wstruct_3D = interp_3D_wstruct(wstruct_3D);
num_interp_nodes = 200;


for count = 1:length(wstruct_3D)
    xi = linspace(min(wstruct_3D(count).x),max(wstruct_3D(count).x),num_interp_nodes);
    yi = interp1(wstruct_3D(count).x,wstruct_3D(count).y,xi);
    zi = interp1(wstruct_3D(count).x,wstruct_3D(count).z,xi);
    wstruct_3D(count).x = xi;
    wstruct_3D(count).y = yi;
    wstruct_3D(count).z = zi;
end