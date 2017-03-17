d = dir('*tracked.mat')

for ii = 1:length(d)
	avi_name_front = [d(ii).name(1:end-11) '*Front*.avi'];
	avi_name_top = [d(ii).name(1:end-11) '*Top*.avi'];

	d_avi_front = dir(avi_name_front);
	d_avi_top = dir(avi_name_top);

	front_avi = d_avi_front(1);
	top_avi = d_avi_top(1);

	v_f = VideoReader(front_avi);
	v_t = VideoReader(top_avi);

	If = read(v_f,v_f.numberOfFrames);
	It = read(v_t,v_t.numberOfFrames);

	[mask_f,BP_f] = getMaskAndBP(If);
	[mask_t,BP_t] = getMaskAndBP(It);

	save(d(ii).name,'-append','mask*','BP*')
end
