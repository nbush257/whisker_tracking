% error(' I think there are some very serious bugs in this code. Please refactor\nIt looks like this code assumes that the whiskers files for the manip and whisker are the same')

wPath ='D:\data\2015_09\tracking\';
mMeasureDir = dir([wPath '*manip*.measurements']);
wTraceDir = dir([wPath '*whisker.whiskers']);
mTraceDir = dir([wPath '*manip.whiskers']);
wMeasureDir = dir([wPath '*whisker.measurements']);
allWhisker = struct([]);
allManip = struct([]);
allWMeasure = struct([]);
allMMeasure = struct([]);
%%
for ii = 1:length(wMeasureDir)
    fprintf('\nLoading whisker \t %i \tof \t %i \n',ii,length(wMeasureDir))
    wTraces = LoadWhiskers([wPath wTraceDir(ii).name]);
    mTraces = LoadWhiskers([wPath mTraceDir(ii).name]);
    mMeasure = LoadMeasurements([wPath mMeasureDir(ii).name]);
    wMeasure = LoadMeasurements([wPath wMeasureDir(ii).name]);
    
    
    frameString = regexp(wMeasureDir(ii).name,'F\d{6}','match');
    frames = [0 0];
    for ii = 1:2
        frames(ii) = str2num(frameString{ii}(2:end));
    end
    
    % extract labelled whisker trace such that the structure is of equal length
    % to the video
    whisker = struct([]);
    tempW = wMeasure([wMeasure.label]==0);
    ID = [[tempW.fid];[tempW.wid]]';
    wTraceID = [[wTraces.time];[wTraces.id]]';
    wTraceIDX = ismember(wTraceID,ID,'rows');
    whisker = wTraces(wTraceIDX);
    
    wT(1) = whisker(1);
    wT(frames(2)-frames(1)+1) = whisker(end);
    fNames = fieldnames(wT);
    for jj = 1:length(fNames)
        wT(end).(fNames{jj}) = [];
    end
    wT([whisker.time]+1) = whisker;
    clear whisker fNames
    
    % extrace labelled maniplutor trace such that the structure is of equal
    % length to the video
    manip = struct([]);
    tempM = mMeasure([mMeasure.label]==0);
    ID = [[tempM.fid];[tempM.wid]]';
    mTraceID = [[mTraces.time];[mTraces.id]]';
    mTraceIDX = ismember(mTraceID,ID,'rows');
    manip = mTraces(mTraceIDX);
    
    mT(1) = manip(1);
    mT(frames(2)-frames(1)+1) = manip(end);
    fNames = fieldnames(mT);
    for jj = 1:length(fieldnames(mT))
        mT(end).(fNames{jj})=[];
    end
    mT([manip.time]+1) = manip;
    clear manip fNames
    
    % Extract whisker measurement such that it is of equal length to the
    % video.
    
    temp_wM = wMeasure([wMeasure.label]==0);
    wM(1) = temp_wM(1);
    wM(frames(2)-frames(1)+1) = temp_wM(end);
    fNames = fieldnames(wM);
    for jj = 1:length(fNames)
        wM(end).(fNames{jj}) = [];
    end
    wM([temp_wM.fid]+1) = temp_wM;
    
    % Extract manip measurement such that it is of equal length to the
    % video
    temp_mM = mMeasure([mMeasure.label]==0);
    mM(1) = temp_mM(1);
    mM(frames(2)-frames(1)+1) = temp_mM(end);
    fNames = fieldnames(mM);
    for jj = 1:length(fNames)
        mM(end).(fNames{jj}) = [];
    end
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
    
    fprintf('\n')
    allMMeasure = [allMMeasure;mM];
    allWMeasure = [allWMeasure;wM];
    allWhisker = [allWhisker;wT];
    allManip = [allManip;mT];
end

