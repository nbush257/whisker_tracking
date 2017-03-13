%% compare3Dand2D
basename = 'rat2016_45_AUG04_VG_B1_t01';
f_num = 115155;
t3d =t3d;
CP = CP;
%% convert f_num to clip read
close all
d_vid_front = dir([basename '*Front*.avi']);
d_vid_top = dir([basename '*Top*.avi']);

assert(length(d_vid_front) == length(d_vid_top));

for ii =1:length(d_vid_front)
    clip_frames = regexp(d_vid_front(ii).name,'F\d{6}F\d{6}','match');
    clip_frames = clip_frames{1};
    clip_frames = [str2num(clip_frames(2:7)) str2num(clip_frames(9:end))];
    if f_num >= clip_frames(1) && f_num <= clip_frames(2)
        
        fprintf('\nUsing clips:\n\t%s\n\t%s\n',d_vid_front(ii).name,d_vid_top(ii).name)
        f_vid = VideoReader(d_vid_front(ii).name);
        t_vid = VideoReader(d_vid_top(ii).name);
        break
    end
end


%%
im_t = read(t_vid,f_num-clip_frames(1)+1);
im_f = read(f_vid,f_num-clip_frames(1)+1);
% 
% t = [tws(f_num).x(:) tws(f_num).y(:)];
% f = [fws(f_num).x(:) fws(f_num).y(:)];

[backproject_front,backproject_top] = BackProject3D(t3d(f_num),calibInfo(1:4),calibInfo(5:8),calibInfo(9:10));


%% Backproject basepoint

[CP_f(1),CP_f(2)] = Get_3DtoCameraProjection(CP(f_num,1),CP(f_num,2),CP(f_num,3), ...
    'proj',calibInfo(1:4));

% Convert 3D point in A coordinate frame to B coordinate frame
% ->  Y = rigid_motion(X,om,T)
r = rigid_motion([CP(f_num,1),CP(f_num,2),CP(f_num,3)]',calibInfo{9},calibInfo{10});

% Compute Camera B projection
[CP_t(1),CP_t(2)] = Get_3DtoCameraProjection(r(1),r(2),r(3), ...
    'proj',calibInfo(5:8));
%%


bigfig
subplot(121)
imshow(im_t)
hold on
% plotv(t+1,'r-.')
plotv(backproject_top+1,'b-.');ln2

px = [0;size(im_t,2)];
% py = [manip.Y0_t(f_num);manip.Y1_t(f_num)];
plot(px,py)
plotv(CP_t+1,'ro');ln3

subplot(122)
imshow(im_f)
hold on
% plotv(f+1,'r-.')
px = [0;size(im_t,2)];
% py = [manip.Y0_f(f_num);manip.Y1_f(f_num)];
plot(px,py)
plotv(backproject_front+1,'b-.');ln2
plotv(CP_f+1,'ro');ln3


