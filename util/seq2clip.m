function seq2clip(seq_path,avi_path,step)
%% function seq2clip(seq_path)
% takes all the seqs in a path and converts them to clips using the Norpix
% Batch processor and ffmpeg. This function is pulled from the old
% seqProcessor script in an effort to chunk the code better

%    INPUTS:    seq_path - path where all the seqs you want to convert to
%               clips are stored
%               avi_path - path where the avis will be stored


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
        ffmpeg_string = sprintf('ffmpeg -f image2 -start_number %i -i %s -c:v wmv2 -q 2 %s',start_frame,[avi_path '\' clip_folder '\' avi_name(1:end-4) '.%d.tif'],[avi_path '\' avi_name]);
        system(ffmpeg_string)
        
        % remove the temp folder and its contents. 
        
        rmdir(clip_folder,'s')
    end
end