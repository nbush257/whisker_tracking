% videoDataPreprocessing_v2()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run this file at the end of the day after recording whisker videos. This
% will copy all the seqs on D:\, E:\ and F:\ into a chosen path. Then chops
% them up into avis of a certain size [Default = 20000 frames]. Then traces the avi
% files and saves the .whiskers files. It then tryies to find the whisker
% using measure and reclassify (via batchMeasureTraces).
% -------------------------
% Currently refactoring to do processing on local before backing everything
% up and to deal with new mikrotron system. Backing up will be done
% manually until we have more hard drives
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

convert_TGL = 0; track_TGL = 0;
convert_TGL = input('Do you want to convert Seqs into avis? (1/0)');
track_TGL = input('Do you want to track the whisker?');

step = 20000; % number of frames to save to each avi
% Get the files to convert
seq_path = uigetdir('F:/','Where are the .seq files?');

if convert_TGL | track_TGL
    avi_path = ['E:/tracked'];
    mkdir(avi_path);
end
if track_TGL
    whisker_path = avi_path;
end

%% get clips from seq
d_seq = dir([seq_path '\*.seq']);
num_seqs = length(d_seq);
cd(avi_path)
for ii = 1:num_seqs
    % ignore calibration files
    if ~isempty(strfind(d_seq(ii).name,'calib'))
        continue
    end
    % get the root name for this seq
    [~,avi_root] = fileparts(d_seq(ii).name);
    % get the number of frames for this seq
    info = seqIo([seq_path '\' d_seq(ii).name],'getinfo');
    num_frames = info.numFrames;
    % get the clip boundaries based on number of frames and clip size
    bounds = [1:step:num_frames num_frames];
    num_clips = length(bounds)-1;
    
    % loop through each clip
    for jj = 1:num_clips
        % make a temp folder to store uncompressed tiffs
        clip_folder = sprintf('temp_%02i',jj);
        mkdir(clip_folder)
        % get this clips starting and ending frame
        start_frame = bounds(jj);
        end_frame = bounds(jj+1)-1;
        % condition for the last clip so that we don't miss the last frame
        if jj==num_clips
            end_frame = end_frame+1;
        end
        
        % generate the name of the clip that includes the frame numbers
        avi_name = sprintf([avi_root '_F%06iF%06i.avi'],start_frame,end_frame);
        % create the string sent to the norpix batch processor.
        % Current settings:
        % export to uncompressed tif files
        % save tif files in temp folder
        %
        clestring = sprintf('clexport -i %s -f tif -o %s -of %s -s %i -e %i',[seq_path '\' d_seq(ii).name],[avi_path ,'/' clip_folder],avi_name,start_frame,end_frame);
        system(clestring)
        % replace first image in seq with second because sometimes there
        % are issues where that image is far over saturated
        if jj == 1
            tif_path = [avi_path '\' clip_folder];
            d_tif = dir([tif_path '\*.tif']);
            tif_1 = d_tif(1).name;
            delete([tif_path '\' tif_1]);
            copyfile([tif_path '\' d_tif(2).name],[tif_path '\' tif_1]);
        end
        
        
        % run ffmpeg to take the sequence of tiff images and save them as a
        % compressed avi. Need to pass the first frame number or else
        % ffmpeg will error out.
        % AVI settings:
        % wmv2 codec
        % quality 2 (0 is highest)
        % save in avi_path, not the temp folder
        % removes the temp dir for the tiffs
        ffmpeg_string = sprintf('ffmpeg -f image2 -start_number %i -i %s -vf hqdn3d -c:v wmv2 -pix_fmt gray -q 2 %s & rmdir /s /q %s & exit &',start_frame,[avi_path '\' clip_folder '\' avi_name(1:end-4) '.%d.tif'],[avi_path '\' avi_name],clip_folder);
        system(ffmpeg_string)
               
        
    end
end
%%
if track_TGL
    parfor ii = 1:length(avis)
        avi_name = avis(ii).name;
            whiskers_name = [whisker_path '\' avi_name(1:end-4) '.whiskers'];
            trace_string = sprintf('trace %s %s ',[avi_path '\' avi_name],whiskers_name);
            system(trace_string);
    end
end
%% Lossy backup of full length seqs
% cd(seq_path)
% parfor ii = 1:length(d_seq)
%     seq_root = d_seq(ii).name(1:end-4);
%     cle_string = sprintf('clexport -i %s -o %s -of %s -f seq -cmp 8',[seq_path '\' d_seq(ii).name],seq_path,[seq_root '.H264.seq'])
%     system(cle_string)
% end
% delete([seq_path '\*.idx']);

%% Get BP and FOL for each trial
avis = dir([avi_path '\*.avi']);
avi_name_list = {avis.name};
TAG_idx = regexp(avi_name_list,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(avi_name_list)
    TAG{ii} = avi_name_list{ii}(1:TAG_idx{ii}-1);
end
[TAGu,first] = unique(TAG);

if track_TGL
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
    
end
%% Combine whiskers
% cd(avi_path)
% tops = dir('*Top*F000001*.whiskers');
% fronts = dir('*Front*F000001*.whiskers');
% for ii = 1:length(tops)
%     [tW,tM] = combineWhiskers(tops(ii).name,0);
%     [fW,fM] = combineWhiskers(fronts(ii).name,0);
%     outFileName = regexp(tops(ii).name,'Top','split');
%     outFileName = [outFileName{1} 'tracked.mat'];
%     save(outFileName,'tW','fW','tM','fM')
% end
% 

