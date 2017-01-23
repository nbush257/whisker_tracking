function getBPandFol(avi_path)
%% function getBPandFol(avi_path)
% Prompts user to determine the basepoint and follicle in the first video
% of a trial. Then uses batchMeasureTraces to measure the whisker and
% assumes only one whisker. You may need to run batchMeasureTraces again
% with another value for n if another edge is consistently being found as a
% whisker.
% ===================
% INPUTS: avi_path - directory of the avi clips you are tracking
% ===================
% NEB 2017_01_23
%% 
avis = dir([avi_path '*.avi']);
avi_name_list = {avis.name};
TAG_idx = regexp(avi_name_list,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(avi_name_list)
    TAG{ii} = avi_name_list{ii}(1:TAG_idx{ii}-1);
end
[TAGu,first] = unique(TAG);

bp= [];
fol = [];

% loop through each trial to get the basepoint and follicle
for ii = 1:length(TAGu)
    % get only the first clip that corresponds to a trial
    d_trial = dir([TAGu{ii} '*.avi']);
    V = VideoReader(d_trial(1).name);
    % read the middle frame
    frame_num = round(V.numberOfFrames/2);
    img = read(V,frame_num);
    % ui to get the BP and Fol
    imshow(img);hold on
    title('Click on the center of the pad')
    bp(ii,:) = ginput(1);
    plotv(bp(ii,:)','g*');
    title('Click on the rightmost line that limits the follicle position')
    [fol(ii),~] = ginput(1);
    clf
end
close all

% run batchMeasureTraces on all files matching that tag with the given
% BP and Fol positions
for ii = 1:length(TAGu)
    d_trial = dir([TAGu{ii} '*.avi']);
    for jj = 1:length(d_trial)
        batchMeasureTraces(d_trial(jj).name(1:end-4),bp(ii,:),fol(ii),'v',1);
    end
end