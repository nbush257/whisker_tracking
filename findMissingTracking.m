DM = dir('*.measurements');
DW = dir('*.whiskers');
% vid =
if length(DM)~=length(DW)
    error('number of whiskers files does not match number of measurements')
end
previousLastTime = 0;
allW = [];
allM = [];
for ii = 1:length(DM)
    m = LoadMeasurements(DM(ii).name);
    w = LoadWhiskers(DW(ii).name);
    keepM = m([m.label]==0);
    missing = setdiff([0:max([m.fid])],[keepM.fid]);
    numFrames = max([m.fid])+1;
    for jj = 1:length(missing)
        
        if jj==1| (jj>1 & (missing(jj)-missing(jj-1))>25)
            
            traceTime =find([w.time]==missing(jj));
            close all
            hold on
            for kk = 1:length(traceTime)
                plot(w(traceTime(kk)).x,w(traceTime(kk)).y,'-o')
            end
            title([num2str(jj) ' of ' num2str(length(missing))])
            choice = ginput(1);
        else
            traceTime =find([w.time]==missing(jj));
            
        end
        closestPt = [];
        for kk = 1:length(traceTime)
            [~,tD] = dsearchn(choice,[w(traceTime(kk)).x w(traceTime(kk)).y]);
            closestPt(kk) = min(tD);
        end
        [~,idx] = min(closestPt);
        new = w(traceTime(idx));
        m([m.wid]==new.id & [m.fid]==new.time).label = 0;
    end
    keepM = m([m.label]==0);
    if length(keepM)~=max([m.fid])+1
        error('Number of tracked whiskers does not equal number of frames')
    end
    
    ID = [[keepM.wid];[keepM.fid]];
    wID = [[w.id];[w.time]];
    
    keepW = w(ismember(wID',ID','rows'));
    % sort by time
    [~,I] = sort([keepW.time]);
    keepW = keepW(I);
    [~,I] = sort([keepM.fid]);
    keepM = keepM(I);
    
    if any(diff([keepW.time])~=1) | any(diff([keepM.fid])~=1)
        error('Some timestep is not equal to 1')
    end
    for jj = 1:length(keepM)
        keepW(jj).time= keepW(jj).time + previousLastTime;
        keepM(jj).fid = keepM(jj).fid + previousLastTime;
    end
    
    allW = [allW;keepW];
    allM = [allM;keepM];
    previousLastTime = previousLastTime + numFrames;
    
end

