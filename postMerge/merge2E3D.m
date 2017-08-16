function merge2E3D(tracked3D_fname)
%% Merge2E23D
% ===========================
% THIS VERSION IS OPTIMIZED FOR RUNNING IMMEDIATELY AFTER MERGING ON QUEST.
% ===========================
%
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
NAN_GAP = 50;

load(tracked3D_fname); 

assert(isstruct(tracked_3D),'No 3D whisker found');
assert(exist('C','var')==1,'No contact variable found');
assert(iscell(calibInfo),'No calibration info found');
assert(exist('frame_size','var')==1,'No frame size found; please save information about frame when tracking 3D');
assert(isstruct(manip),'No manip found')
assert(all(strcmp(fieldnames(manip),{'Y0_f';'Y1_f';'Y0_t';'Y1_t'})),'fields of manipulator are incorrect')
assert(length(tracked_3D)==length(C),'Contact variable and 3D whisker do not have the same number of frames')
assert(~any(isnan(C)),'Contact variable has NaNs, make sure it was computed correctly')

l_manip = [0,0,0,0];
fields = fieldnames(manip);
for ii = 1:length(fields)
    l_manip(ii) = length(manip.(fields{ii}));
end
assert(all(l_manip==length(C)),'Manipulator is not the same length as Contact')

C = logical(C);
assert(isvector(C), 'Contact variable is not a vector');
% Make C a column vector
C = C(:);


%% get output filename
fname_out = [tracked3D_fname(1:regexp(tracked3D_fname,'_t\d\d_','end')) 'toE3D.mat'];

fname_out_temp = [fname_out(1:end-4) '_temp.mat'];

%% start parallel pool
numw = str2num(getenv('PBS_NUM_PPN'));
clust = parcluster();
parpool(clust,numw);

% sort the whisker along the x axis
disp('Sorting whisker...')
t3d = sort3Dwhisker(tracked_3D);
%%
disp('removing short whiskers and the last point')
t3d = clean3Dwhisker(t3d);

%% smooth the whisker
% disp('Smoothing 3D whisker...')
t3d = smooth3DWhisker(t3d,'linear');
save(fname_out_temp,'t3d','calibInfo')


%% Find the contact point and extend whisker where needed
t3d = makeColumnVectorStruct(t3d);
[CPraw,~,t3d] = get3DCP_hough(manip,t3d,calibInfo,C,frame_size);
save(fname_out_temp,'t3d','CPraw','-append')

%% smooth the contact point
CP = cleanCP(CPraw,NAN_GAP);

% In case the contact point is not on the whisker after smoothing, put it
% back on the whisker.

[~,CP] = CPonWhisker(CP,t3d);

% Prepare for E3D
xw3d = {t3d.x};
yw3d = {t3d.y};
zw3d = {t3d.z};

% extract the basepoint
BP = get3DBP(t3d);

%

getE3Dflag;
%% Output

save(fname_out,'*w3d','CP','BP','C','E3D_flag')
fprintf('Saved to %s\n',fname_out)
delete(fname_out_temp)


