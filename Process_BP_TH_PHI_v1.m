% Get 3D linear fit then get BP_TH_PHI

function [x,y,z,BP] = Process_BP_TH_PHI_v1(x,y,z,PT)
%function Process_BP_TH_PHI_V1(x,y,z,PT)
% need to fix the pix2m conversion thing. Currently taking only 10% of the
% whisker. THIS IS A WORKAROUND. 
% ASSUMES FIRST POINT IS THE PUTATIVE BASEPOINT.

%%%%%%%%%%%%%%%%% This would be used if we have a good pix2m conversion in
%%%%%%%%%%%%%%%%% 3D 
%%%%%%%%%%%%%%%%% NOTE: 3D pix2m is not the same as 2D pix2m!!!!
%
%%%%%%%%%%%%%%%%% pix2m = PT.pix2m;
%%%%%%%%%%%%%%%%% mDistance = 4; %in mm
%%%%%%%%%%%%%%%%% pixDistance = mDistance/pix2m/1000;

%%
thresh = .1;%just use the first 10%
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

%replace x,y,z

    x(idx) = newX;
    y(idx) = newY;
    z(idx) = newZ;



BP = [x(1) y(1) z(1)];



end %EOF


