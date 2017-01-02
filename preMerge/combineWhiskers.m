function [allWhisker,allWMeasure] = combineWhiskers(wFileName,saveTGL)
%% function [allWhisker,allWMeasure] = combineWhiskers([filename,saveTGL])

%% input handling
narginchk(0,2)    
if nargin == 2
    [wPathName,wFileName,ext] = fileparts(wFileName);
elseif nargin == 1
    saveTGL = false;% default to not saving
    [wPathName,wFileName,ext] = fileparts(wFileName);
    
elseif nargin == 0
    saveTGL = false;
    [wFileName,wPathName] = uigetfile('*.whiskers','Select one file of the whisker that you want to combine');

    [~,wFileName] = fileparts(wFileName);
else 
    error('Wrong number of inputs')
end

%% Get all clips from a particular trial

% For the whisker
% Replace Frame numbers with a wildcard to create a directory pointer that looks at every file from a partiucular trial
[Tag_start,Tag_end] = regexp(wFileName,'_F\d{6}F\d{6}'); TagW = [wFileName([1:Tag_start-1]) '*' wFileName(Tag_end+1:end)];
% Create directory structs that point to all the files we will want to load
wTraceDir = dir([wPathName TagW '.whiskers']);
wMeasureDir = dir([wPathName TagW '.measurements']);
% Find out how many files are in each directory pointer. Used to determine
% if there are equal numbers of files

lDir = [length(wTraceDir) length(wMeasureDir)];
assert(lDir(1) == lDir(2))
% Throw an error if the number of files are not consistent across
% measurements and whiskers files or across manipulators and whiskers
%% init global reference structures
% trying to init so that the global struct is the size of the video.

wTraces = LoadWhiskers([wPathName wTraceDir(1).name]);
wMeasure = LoadMeasurements([wPathName wMeasureDir(1).name]);

allWhisker(1) = wTraces(1);
allWMeasure(1) = wMeasure(1);

% get length of video from filename
[v1,v2] = regexp(wTraceDir(end).name,'F\d{6}'); globalLastFrame = str2num(wTraceDir(end).name(v1(2)+1:v2(end)));

%% Init full lengthstruct
temp_fNames = fieldnames(allWhisker);
allWhisker(globalLastFrame) = wTraces(end);
allWMeasure(globalLastFrame) = wMeasure(end);

for ii = 1:length(temp_fNames)
    allWhisker(globalLastFrame).(temp_fNames{ii}) = [];
end

temp_fNames = fieldnames(allWMeasure);
for ii = 1:length(temp_fNames)
    allWMeasure(globalLastFrame).(temp_fNames{ii}) = [];
end


%% Main Loop that grabs the information from each file and puts it in a global reference
for ii = 1:length(wMeasureDir)
    % load in all the data
    fprintf('Loading whisker %i of %i:\n\t%s\n\t%s\n',ii,length(wMeasureDir),wTraceDir(ii).name,wMeasureDir(ii).name)
    
    wTraces = LoadWhiskers([wPathName wTraceDir(ii).name]);
    wMeasure = LoadMeasurements([wPathName wMeasureDir(ii).name]);
   
    % extract global frame numbers from filename
    frameString = regexp(wMeasureDir(ii).name,'F\d{6}','match');
    frames = [0 0];
    for ii = 1:2
        frames(ii) = str2num(frameString{ii}(2:end));
    end
    
    % extract labelled whisker trace such that the structure is of equal length
    % to the video
    clear wT
    whisker = struct([]);
    % Look at only the traces labeled 0
    tempW = wMeasure([wMeasure.label]==0);
    % short circuit if there is no labeled whisker (This shouldn't
    % happen often
    if isempty(tempW)
        warning(['No labeled whisker found; skipping file ' wTraceDir(ii).name])
        continue
    end
    % Make a N x 2 matrix of frame time (local) and whisker id from the
    % measurement file.
    ID = [[tempW.fid];[tempW.wid]]';
    % Make a corresponding N x 2 matrix of frame time (local) and
    % whisker id from the .whisker file
    wTraceID = [[wTraces.time];[wTraces.id]]';
    % compare the 2 Nx2 matrices
    wTraceIDX = ismember(wTraceID,ID,'rows');
    % set a new .whisker like struct from the labeled whiskers
    whisker = wTraces(wTraceIDX);
    
    % wT is the struct that will be the length of the video file; init
    % it here
    wT(1) = whisker(1);% set the first frame equal to the first from before
    wT(frames(2)-frames(1)+1) = whisker(end); % temporarily set the last entry equal to the last labeled whisker (not necesarily in the last frame)
    % make the last entry empty as it is not the same as the last
    % labeled whisker
    fNames = fieldnames(wT);
    for jj = 1:length(fNames)
        wT(1).(fNames{jj}) = [];
        wT(end).(fNames{jj}) = [];
    end
    
    % set wT eqaul to the labeled whiskers ST the entry number equals the
    % local timestamp (1 indexed)
    wT([whisker.time]+1) = whisker;
    clear whisker fNames % clear these temporary variables
    
    % Extract whisker measurement such that it is of equal length to the
    % video.
    % subset of whisker measurements with labeled whisker
    clear wM
    temp_wM = wMeasure([wMeasure.label]==0);
    % init measurement-like struct ST it is of equal length to the
    % video clip
    wM(1) = temp_wM(1);
    wM(frames(2)-frames(1)+1) = temp_wM(end);
    % Clear last entry because the last labeled whisker may not be the last
    % frame
    fNames = fieldnames(wM);
    for jj = 1:length(fNames)
        wM(1).(fNames{jj}) = [];
        wM(end).(fNames{jj}) = [];
    end
    % set wM eqaul to the labeled whisker ST the entry number equals the
    % local timestamp (1 indexed)
    wM([temp_wM.fid]+1) = temp_wM;
  
    
    % replace time stamp with global timestamp (zero indexed)
    for jj = 1:frames(2)-frames(1)+1
        wT(jj).time = double(wT(jj).time)+frames(1)-1;
        wM(jj).fid = double(wM(jj).fid)+frames(1)-1;
        
    end
    % concatenate global structure with the local structure.
    fprintf('\n')
    allWMeasure(frames(1):frames(2)) = wM;
    allWhisker(frames(1):frames(2)) = wT;
end
%% fill in empty structs with sequential time stamps
emptyWhisker = cellfun(@isempty,{allWhisker.time});

for ii = find(emptyWhisker)
    allWhisker(ii).time = ii-1;
    allWMeasure(ii).fid = ii-1;
end
%% fill in empty fields with NaN
fieldN = {'face_x','face_y','length','score','angle','curvature','follicle_x','follicle_y','tip_x','tip_y'};
for ii = 1:length(fieldN)
    emptyLogical = cellfun(@isempty,{allWMeasure.(fieldN{ii})});
    for jj = find(emptyLogical)
        allWMeasure(jj).(fieldN{ii}) = NaN;
    end
end
%% Save output
if saveTGL
    writeName = [wFileName(1:Tag_start) 'whisker'];
    save(writeName,'all*');
end
