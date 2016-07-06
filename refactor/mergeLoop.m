% Just merge loop


% 3D Merge Whisker % Might want to try to make the seed whisker variable.
tracked_3D_fileName = 'rat2015_15_JUN11_VG_D4_t01_tracked_3D.mat';
minDS = .8;% sets the minimum internode distance.
minWhiskerSize = 20; % in # of nodes
N = 20; % I think this is the number of fits to try. More should give a stabler fit.
%%
if length(f)~=length(t)
    error('Different length structs')
end
numFrames = length(f);
tracked_3D = struct([]);
count = 0;

step =10000;% Saves every 10000 frames


% Outer loop is big serial chunks that saves every [step] frames
for ii = 1:step:numFrames
    count = count+1;
    check = 0;
    % Makes sure we don't try to access a frame past the last frame.
    if (ii+step-1)>length(f)
        iter = length(f)-ii;
    else
        iter = step-1;
    end
    
    % Parallel for loop which does the actual merging. Gets batches from
    % the current outer loop.

    parfor i = ii:ii+iter
        

        %initialize the merged values in the parfor loop.
        merge_x = [];merge_y = [];merge_z = [];last_merge_x = []; last_merge_y = []; last_merge_z = [];
        
        % if this frame is not flagged for merging, skip it. This should
        % have already checked for empties in both views
        
        if ~mergeFlags(i) || isempty(t(i).x) || isempty(f(i).x)
            tracked_3D(i).x = []; tracked_3D(i).y = []; tracked_3D(i).z = [];
            tracked_3D(i).time = i-1;
            continue
        end
        prevWhiskerSize = 0;
        close all
        DS = minDS;
        
        % Initial merge.
        [merge_x,merge_y,merge_z]= Merge3D_JAEv1(f(i).x,f(i).y,t(i).x,t(i).y,i,calib,'wm_opts',{'DS',DS,'N',N});

        x_out = merge_x;
        y_out = merge_y;
        z_out = merge_z;
        
        tracked_3D(i).x = x_out; tracked_3D(i).y = y_out; tracked_3D(i).z = z_out;
        tracked_3D(i).time = i-1;tracked_3D(i).frontTime = f(i).time;tracked_3D(i).topTime = t(i).time;
        
    end
    save([tracked_3D_fileName(1:end-4) '_iter_' num2str(count) ],'tracked_3D')
    
    
end

