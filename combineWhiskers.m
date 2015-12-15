% error(' I think there are some very serious bugs in this code. Please refactor\nIt looks like this code assumes that the whiskers files for the manip and whisker are the same')

wPath ='D:\2015_28\test';
manipMeasurePath = dir([wPath '*manip*']);
tracesPath = dir([wPath '*.whiskers']);
whiskerMeasurePath = dir([wPath '*whiskers.measurements*']);
allWhisker = struct([]);
allManip = struct([]);
allWMeasure = struct([]);
allMMeasure = struct([]);

for ii = 1:length(whiskerMeasurePath)
    fprintf('\nLoading whisker \t %i \tof \t %i \n',ii,length(whiskerMeasurePath))
    traces = LoadWhiskers([wPath tracesPath(ii).name]);
    manipMeasure = LoadMeasurements([wPath manipMeasurePath(ii).name]);
    whiskerMeasure = LoadMeasurements([wPath whiskerMeasurePath(ii).name]);
    
    whisker = struct([]);
    tempW = whiskerMeasure([whiskerMeasure.label]==0);
    ID = [[tempW.fid];[tempW.wid]]';
    traceID = [[traces.time];[traces.id]]';
    traceIDX = ismember(traceID,ID,'rows');
    whisker = traces(traceIDX);
    
    tempM = manipMeasure([manipMeasure.label]==0);
    ID = [[tempM.fid];[tempM.wid]]';
    traceID = [[traces.time];[traces.id]]';
    traceIDX = ismember(traceID,ID,'rows');
    manip = traces(traceIDX);
    
    
    
    
    frameString = regexp(whiskerMeasurePath(ii).name,'F\d');
    frameString = whiskerMeasurePath(ii).name(frameString(1)+1:frameString(1)+6);
    firstFrame = str2num(frameString);
    
    
    thundreds = 1:length(whisker)/50:length(whisker);
    for jj = 1:length(whisker)
        if ismember(jj,thundreds)
            fprintf('.')
        end
        whisker(jj).time = double(whisker(jj).time)+firstFrame-1;
            
    end
    
    thundreds = 1:length(whisker)/50:length(manip);
    for jj = 1:length(manip)
        if ismember(jj,thundreds)
            fprintf('.')
        end
        manip(jj).time = double(manip(jj).time)+firstFrame-1;
            
    end
    allMMeasure = [allMMeasure;manipMeasure];
    allWMeasure = [allWMeasure;whiskerMeasure];
    allWhisker = [allWhisker;whisker];
    allManip = [allManip;manip];
end

