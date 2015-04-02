function allC = findContact(wStruct_3D)
thresh = .1;% percentage of the whisker to linear fit
for ii = 1:length(wStruct_3D)
    
    x = wStruct_3D(ii).x;
    y = wStruct_3D(ii).y;
    z = wStruct_3D(ii).z;
    
    d = sqrt((x-x(1)).^2+(y-y(1)).^2+(z-z(1)).^2);
    maxd = max(d);
    t = thresh*maxd;
    idx = d<t;
    
    % make all pts columns
    if isrow(x)
        x = x';
    end
    if isrow(y)
        y = y';
    end
    if isrow(z)
        z = z';
    end
    
    %get first 10% of the whisker
    x_seg = x(idx);
    y_seg = y(idx);
    z_seg = z(idx);
    
    %Calculate the covariance matrix, get the eigen values and eigen vectors of
    %the inital 3D segment
    C = cov([x_seg y_seg z_seg]);
    e = eig(C);
    [~,dim] = max(e);
    [V,~] = eig(C);
    m = mean([x_seg y_seg z_seg]);
    
    %define where to calculate points from the eigenvectors
    extentBeg = sqrt((x_seg(1)-m(1))^2 + (y_seg(1)-m(2))^2 + (z_seg(1)-m(3))^2);
    extentEnd = sqrt((x_seg(end)-m(1))^2 + (y_seg(end)-m(2))^2 + (z_seg(end)-m(3))^2);
    
    %calculate endpoints
    pts = [V(:,dim)*-extentBeg+m' V(:,dim)*extentEnd+m'];
    
    % interpolate in between endpoints
    newX = linspace(pts(1,1),pts(1,2),length(x_seg));
    newY = linspace(pts(2,1),pts(2,2),length(x_seg));
    newZ = linspace(pts(3,1),pts(3,2),length(x_seg));
    
    dist1 = sqrt((x(1)-newX(1))^2 + (y(1)-newY(1))^2 + (z(1)-newZ(1))^2);
    diste = sqrt((x(1)-newX(end))^2 + (y(1)-newY(end))^2 + (z(1)-newZ(end))^2);
    
    if dist1 > diste
        newX = fliplr(newX);
        newY = fliplr(newY);
        newZ = fliplr(newZ);
    end
    
    %         %replace x,y,z
    %         x(idx) = newX;
    %         y(idx) = newY;
    %         z(idx) = newZ;
    
    
    %  BP(ii,:) = [x(1) y(1) z(1)];
    
    %% Calculate TH angle
    
    TH(ii) = atan2(newY(end)-newY(1),newX(end)-newX(1))*180/pi;
    %% Calculate PHI projection angle
    
    PHI(ii) = atan2(newZ(end)-newZ(1),newX(end)-newX(1))*180/pi;
    
    
    %% Calculate PHI euler
    
    xydist = sqrt((newY(end)-newY(1))^2 + (newX(end)-newX(1))^2);
    PHIE(ii) = -atan2(newZ(end)-newZ(1),xydist)*180/pi;
end

centeredTH = (TH - TH(1))/(max(TH)-min(TH));
centeredPHI = (PHI - PHI(1))/(max(PHI)-min(PHI));
centeredPHIE = (PHIE - PHIE(1))/(max(PHIE)-min(PHIE));
dAngle = sqrt(centeredPHI.^2 + centeredPHIE.^2 + centeredTH.^2);
dAnglet = tsmovavg(dAngle,'s',15);


count = 0;
allC = [];
step = 500
for ii = 1:step:length(wStruct_3D)
    if (ii+step-1)>length(wStruct_3D)
        l = length(dAnglet(ii:end));
        plot(dAnglet(ii:end))
        [~,thresh] = ginput(1);
        C = logical(zeros(l,1));
        C(dAnglet(ii:end)>thresh) = 1;
    else
        plot(dAnglet(ii:ii+step-1))
        l = length(dAnglet(ii:ii+step-1));
        [~,thresh] = ginput(1);
        C = zeros(l,1);
        C(dAnglet(ii:ii+step-1)>thresh) =1 ;
    end
    
    allC =[allC;C];
end
close all
end % EOF


