function combineWhiskers()


%% Get all clips from a particular trial

% Use uigetdir to choose the trial you wnat to use
    % For the whisker
[wFileName,wPathName] = uigetfile('*.whiskers','Select one file of the whisker that you want to combine');
wFileName = wFileName(1:end-9) %Strip the .whiskers extension
cd(wPathName)
    % For the manipulator
[mFileName,mPathName] = uigetfile('*.whiskers',['Select one file of the manipulator that you want to combine for:' wFileName]);
mFileName = mFileName(1:end-9) % Strip the .whiskers extension

% Replace Frame numbers with a wildcard to create a directory pointer that looks at every file from a partiucular trial
[Tag_start,Tag_end] = regexp(wFileName,'_F\d{6}F\d{6}'); TagW = [wFileName([1:Tag_start-1]) '*' wFileName(Tag_end+1:end)];
[Tag_start,Tag_end] = regexp(mFileName,'_F\d{6}F\d{6}'); TagM = [mFileName([1:Tag_start-1]) '*' mFileName(Tag_end+1:end)];

% Create directory structs that point to all the files we will want to load
mMeasureDir = dir([mPathName TagM '.measurements']);
wTraceDir = dir([wPathName TagW '.whiskers']);
mTraceDir = dir([wPathName TagM '.whiskers']);
wMeasureDir = dir([wPathName TagW '.measurements']);
% Find out how many files are in each directory pointer. Used to determine
% if there are equal numbers of files
lDir = [length(mMeasureDir) length(wTraceDir) length(mTraceDir) length(wMeasureDir)];

% Throw an error if the number of files are not consistent across
% measurements and whiskers files or across manipulators and whiskers
% if length(unique(lDir))~=1
%     error('Inconsistent number of files available')
% end
    
%% init global reference structures
% trying to init so that the global struct is the size of the video.

wTraces = LoadWhiskers([wPathName wTraceDir(1).name]);
mTraces = LoadWhiskers([wPathName mTraceDir(1).name]);
mMeasure = LoadMeasurements([wPathName mMeasureDir(1).name]);
wMeasure = LoadMeasurements([wPathName wMeasureDir(1).name]);


allWhisker(1) = wTraces(1);
allManip(1) = mTraces(1);
allWMeasure(1) = wMeasure(1);
allMMeasure(1) = mMeasure(1);

% get length of video from filename
[v1,v2] = regexp(wTraceDir(end).name,'F\d{6}'); globalLastFrame = num2str(wTraceDir(end).name(v1(2)+1:v2(end)));

temp_fNames = fieldnames(allWhisker);
allWhisker(globalLastFrame) = wTraces(end);
allManip(globalLastFrame) = mTraces(end);
allWMeasure(globalLastFrame) = wMeasure(end);
allMMeasure(globalLastFrame) = mMeasure(end);

for ii = 1:length(temp_fNames)
    allWhisker(globalLastFrame).(temp_fNames{ii}) = [];
    allManip(globalLastFrame).(temp_fNames{ii}) = [];
end

temp_fNames = fieldnames(allWMeasure);
for ii = 1:length(temp_fNames)
    allWMeasure(globalLastFrame).(temp_fNames{ii}) = [];
    allMMeasure(globalLastFrame).(temp_fNames{ii}) = [];
end


%% Main Loop that grabs the information from each file and puts it in a global reference
for ii = 1:length(wMeasureDir)
    % load in all the data
    fprintf('\nLoading whisker \t %i \tof \t %i \n',ii,length(wMeasureDir))
    wTraces = LoadWhiskers([wPath wTraceDir(ii).name]);
    mTraces = LoadWhiskers([wPath mTraceDir(ii).name]);
    mMeasure = LoadMeasurements([wPath mMeasureDir(ii).name]);
    wMeasure = LoadMeasurements([wPath wMeasureDir(ii).name]);
    
    % extract global frame numbers from filename
    frameString = regexp(wMeasureDir(ii).name,'F\d{6}','match');
    frames = [0 0];
    for ii = 1:2
        frames(ii) = str2num(frameString{ii}(2:end));
    end
    
    % extract labelled whisker trace such that the structure is of equal length
    % to the video
    whisker = struct([]);
        % Look at only the traces labeled 0
    tempW = wMeasure([wMeasure.label]==0);
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
        wT(end).(fNames{jj}) = [];
    end
    
    % set wT eqaul to the labeled whiskers ST the entry number equals the
    % local timestamp (1 indexed)
    wT([whisker.time]+1) = whisker;
    clear whisker fNames % clear these temporary variables
    
    % extrace labelled maniplutor trace such that the structure is of equal
    % length to the video
    manip = struct([]);
        % Look at only the traces labeled 0
    tempM = mMeasure([mMeasure.label]==0);
        % Make a N x 2 matrix of frame time (local) and manipulator id from the
        % measurement file.
    ID = [[tempM.fid];[tempM.wid]]';
        % Make a corresponding N x 2 matrix of frame time (local) and
        % manipulator id from the .whisker file
    mTraceID = [[mTraces.time];[mTraces.id]]';
        % compare the 2 Nx2 matrices
    mTraceIDX = ismember(mTraceID,ID,'rows');
        % set a new .whisker like struct from the labeled manipulator
    manip = mTraces(mTraceIDX);
        % mT is the struct that will be the length of the video file; init
        % it here
    mT(1) = manip(1);
    mT(frames(2)-frames(1)+1) = manip(end);
    fNames = fieldnames(mT);
        % make the last entry empty as it is not the same as the last
        % labeled manipulator
    for jj = 1:length(fieldnames(mT))
        mT(end).(fNames{jj})=[];
    end
    % set mT eqaul to the labeled manipulators ST the entry number equals the
    % local timestamp (1 indexed)
    mT([manip.time]+1) = manip;
    clear manip fNames
    
    % Extract whisker measurement such that it is of equal length to the
    % video.
        % subset of whisker measurements with labeled whisker
    temp_wM = wMeasure([wMeasure.label]==0);
        % init measurement-like struct ST it is of equal length to the
        % video clip
    wM(1) = temp_wM(1);
    wM(frames(2)-frames(1)+1) = temp_wM(end);
        % Clear last entry because the last labeled whisker may not be the last
        % frame
    fNames = fieldnames(wM);
    for jj = 1:length(fNames)
        wM(end).(fNames{jj}) = [];
    end
        % set wM eqaul to the labeled whisker ST the entry number equals the
        % local timestamp (1 indexed)
    wM([temp_wM.fid]+1) = temp_wM;
    
    % Extract manip measurement such that it is of equal length to the
    % video
        % subset of manip measurements with labeled whisker
    temp_mM = mMeasure([mMeasure.label]==0);
        % init measurement-like struct ST it is of equal length to the
        % video clip
    mM(1) = temp_mM(1);
    mM(frames(2)-frames(1)+1) = temp_mM(end);
        % Clear last entry because the last labeled whisker may not be the last
        % frame
    fNames = fieldnames(mM);
    for jj = 1:length(fNames)
        mM(end).(fNames{jj}) = [];
    end
        % set mT eqaul to the labeled manipulators ST the entry number equals the
        % local timestamp (1 indexed)
    mM([temp_mM.fid]+1) = temp_mM;
    
    
% replace time stamp with global timestamp
    for jj = 1:frames(2)-frames(1)+1
        if ismember(jj,thundreds)
            fprintf('.')
        end       
        wT(jj).time = double(wT(jj).time)+frames(1);
        mT(jj).time = double(mT(jj).time)+frames(1);
        wM(jj).time = double(wM(jj).fid)+frames(1);
        mM(jj).time = double(mM(jj).fid)+frames(1);
        
    end
    % concatenate global structure with the local structure.
    fprintf('\n')
    allMMeasure = [allMMeasure;mM];
    allWMeasure = [allWMeasure;wM];
    allWhisker = [allWhisker;wT];
    allManip = [allManip;mT];
end

