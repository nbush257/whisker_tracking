%% Merge2E23D
% ===========================
% This is a simple, step by step 'README' like script. You should load in a
% file that has the following variables:
%
%   - tracked_3D: a 3D whisker struct from the merge
%   - manip: a structure with fields that define the manipulator in both views:
%       Y0_f
%       Y1_f
%       Y0_t
%       Yt_t
%   - calib: a 10 element cell array that defines the camera's
%   relationships. 
% ============================
% NEB 2016_07_07
%% init workspace 
clearvars -except tracked_3D manip calibInfo C frame_size

C(isnan(C)) = 0;
C = logical(C);
assert(isvector(C));
C = C(:);

if ~exist('C','var')
    C = false(length(tracked_3D),1);
end

fname = []; % either manually give the output name here, or in a uinput
p1 = pwd;
%%
if isempty(fname)
    fname = input('Type the filename you want to save the data to.','s');
end
fname_temp = [p1 '\' fname '_temp.mat'];

%% start parallel pool
gcp

% sort the whisker along the x axis
disp('Sorting whisker...')
t3d = sort3Dwhisker(tracked_3D);
%%
disp('Removing second point...')
t3d = rmPt3DWhisker(t3d);

%% smooth the whisker
% disp('Smoothing 3D whisker...')
t3d = smooth3DWhisker(t3d,'spline',5);
save(fname_temp,'t3d','calibInfo')


%% Find the contact point and extend whisker where needed
t3d = makeColumnVectorStruct(t3d);
[CPraw,~,t3d] = get3DCP_hough(manip,t3d,calibInfo,C,frame_size);
save(fname_temp,'t3d','CPraw','-append')

%% smooth the contact point
CP = cleanCP(CPraw);

% In case the contact point is not on the whisker after smoothing, put it
% back on the whisker.

[~,CP] = CPonWhisker(CP,t3d);

% Prepare for E3D
xw3d = {t3d.x};
yw3d = {t3d.y};
zw3d = {t3d.z};

% extract the basepoint
BP = get3DBP(t3d);
save(fname_temp)

%% Output
%% GET REF

save(fname,'*w3d','CP','BP','C')
delete(fname_temp)
%% data QC
figure
for ii = find(C,1):10:length(t3d)
    ho
    cla
    plot3(tracked_3D(ii).x,tracked_3D(ii).y,tracked_3D(ii).z,'k.-')
    
    plot3(xw3d{ii},yw3d{ii},zw3d{ii},'.','color','c')
    
    plot3(CP(ii,1),CP(ii,2),CP(ii,3),'r*')
    
    plot3(BP(ii,1),BP(ii,2),BP(ii,3),'b^')
  
    grid on
    axis equal
      axx(-60,0)
    axy(5,35)
    axz(410,460)
    drawnow
    
    
end


