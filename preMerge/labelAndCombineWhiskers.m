front_vid_fname = 'rat2017_08_FEB15_VG_C3_t01_Front_F000001F005000.avi';
data_root_name = regexp(front_vid_fname,'^rat\d{4}_\d{2}_[A-Z]{3}\d\d_VG_[A-Z]\d_t\d\d','match');
top_vid_fname = [front_vid_fname(1:27) 'Top' front_vid_fname(33:end)];
fV = VideoReader(front_vid_fname);
tV = VideoReader(top_vid_fname);

d_front = dir([data_root_name{1} '_Front*.whiskers']);
d_top = dir([data_root_name{1} '_Top*.whiskers']);

assert(length(d_front)==length(d_top),'Different number of files across views');

I_f = read(fV,length(fV)/2);
I_t = read(tV,length(tV)/2);

[mask_f,BP_f] = getMaskAndBP(I_f);
[mask_t,BP_t] = getMaskAndBP(I_t);
%% get limits
imshow(I_f);
title('click on X boundaries(2)')
[x_lim_f,~] = ginput(2);
title('click on Y boundaries(2)')
[~,y_lim_f] = ginput(2);
close all
imshow(I_t);
title('click on X boundaries(2)')
[x_lim_t,~] = ginput(2);
title('click on Y boundaries(2)')
[~,y_lim_t] = ginput(2);

close all

%%
clear fW
for ii = 1:length(d_front)
    w = LoadWhiskers(d_front(ii).name);
    frame_lims = regexp(d_front(ii).name,'F\d{6}F\d{6}','match');
    start_frame = str2num(frame_lims{1}(2:7));
    end_frame = str2num(frame_lims{1}(9:end));
    disp(num2str(end_frame))
    w_masked = applyMaskToWhisker(w,mask_f);
    fW(start_frame:end_frame) = labelWhisker(w_masked,BP_f,x_lim_f,y_lim_f,start_frame-1);
end
%%
clear tW
for ii = 1:length(d_top)
    w = LoadWhiskers(d_top(ii).name);
    frame_lims = regexp(d_front(ii).name,'F\d{6}F\d{6}','match');
    start_frame = str2num(frame_lims{1}(2:7));
    end_frame = str2num(frame_lims{1}(9:end));
    disp(num2str(end_frame))
    w_masked = applyMaskToWhisker(w,mask_t);
    tW(start_frame:end_frame) = labelWhisker(w_masked,BP_t,x_lim_t,y_lim_t,start_frame-1);
end
%%
frame_size.top = size(I_t);
frame_size.front = size(I_f);

mask_struct.top = mask_t;
mask_struct.front = mask_f;
mask_struct.BP_f = BP_f;
mask_struct.BP_t = BP_t;
front_avi = front_vid_fname;
top_avi = top_vid_fname;
%%
save([data_root_name{1} '_tracked.mat'],'*W','frame_size','*_avi','mask_struct')

