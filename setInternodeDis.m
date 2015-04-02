function wStruct_3D_out = setInternodeDis(wStruct_3D,ds)
%Gets evenly spaced nodes of a defined length. Good for comparing the same
%node across time. Probably useful for a kalman filter.

for ii = 1:length(wStruct_3D)
    
    x = wStruct_3D(ii).x;
    y = wStruct_3D(ii).y;
    z = wStruct_3D(ii).z;
    
    newx = linspace(x(1),x(end),10000);
    newy = interp1(x,y,newx);
    newz = interp1(y,z,newy);
    
    [x,y,z] = getNodes(newx,newy,newz,ds);
    wStruct_3D_out(ii).x = x;
    wStruct_3D_out(ii).y = y;
    wStruct_3D_out(ii).z = z;
    
    
    
    
end
end


function [newX,newY,newZ] = getNodes(x,y,z,ds);

count = 0;
newX = [];
newY = [];
newZ = [];
while 1
    count = count+1;
    if count == 1
        idxMin = 1;
    end
    
    d = abs(sqrt((x(idxMin)-x).^2 + (y(idxMin)-y).^2 + (z(idxMin)-z).^2)-ds);
    d(1:idxMin) = Inf;
    [~,idxMin] = min(d);
    newX(count) = x(idxMin);
    newY(count) = y(idxMin);
    newZ(count) = z(idxMin);
    if idxMin == length(x)
        break
    end
    if count >1000
        break
    end
    
end
end
% end
% plot3(x,y,z,'.')
% hold on
% plot3(newX,newY,newZ,'ro')