%% This function finds frames that are missing tracking, has you manually choose the whisker, and combines them into one mat file.

clear all
close all
DM = dir('*Front*whisker.measurements');
DW = dir('*Front*_whisker.whiskers');
DV = dir('*Front*.avi')

for ii = 1:length(DW)
    rm(ii)= any(regexp(DW(ii).name,'manip'));
    rm2(ii) = any(regexp(DW(ii).name,'_whisker'));
end
DW = DW(~rm);


if length(DM)~=length(DW)
    error('number of whiskers files does not match number of measurements')
end
previousLastTime = 0;
allW = [];
allM = [];
for ii = 1:length(DM)
    close all
    choice = [];
    noWhisker = [];
    V = VideoReader(DV(ii).name);
    pause(.001)
    m = LoadMeasurements(DM(ii).name);
    w = LoadWhiskers(DW(ii).name);
    rmID = [m.length]<100;
    
    toRMID = [[m(find(rmID)).wid];[m(find(rmID)).fid]];
    
    wID = [[w.id];[w.time]];
    m = m(~rmID);
    w = w(~ismember(wID',toRMID','rows'));
    wID = [[w.id];[w.time]];
    
    keepM = m([m.label]==0);
    
    ID = [[keepM.wid];[keepM.fid]];
    numFrames = max([m.fid])+1;
    
    
    keepW = w(ismember(wID',ID','rows'));
    
    %% see if there is any region of space to remove traces from.
    
    
    ho
    for jj = 1:5:length(keepW)
        plot(keepW(jj).x,keepW(jj).y,'-.')
    end
    [choiceX,choiceY] = ginput(2);
    choiceX = sort(choiceX);
    choiceY = sort(choiceY);
    if ~isempty(choiceX)
        rm = [];
        for jj = 1:length(keepW)
            B= keepW(jj).x>choiceX(1) & keepW(jj).x<choiceX(2) &keepW(jj).y>choiceY(1) & keepW(jj).y<choiceY(2);
            if any(B)
                rm = [rm jj];
            end
        end
        idx = [m.label]==0 & ismember([m.fid],rm);
        idx = find(idx);
        for jj =1:length(idx)
            m(idx(jj)).label = -1;
        end
        
    end
    
    keepM = m([m.label]==0);
    
    ID = [[keepM.wid];[keepM.fid]];
    wID = [[w.id];[w.time]];
    
    keepW = w(ismember(wID',ID','rows'));
    %%
    missing = setdiff([0:max([m.fid])],[keepM.fid]);
    for jj = 1:length(missing)
        if ~any([m.fid]==missing(jj))
            noWhisker = [noWhisker missing(jj)];
            continue
        end
        
        traceTime =find([w.time]==missing(jj));
        if jj>1 & ~isempty(choice) % check last choice point to see if it falls close to another trace
            closestPt = [];
            for kk = 1:length(traceTime)
                [~,tD] = dsearchn(choice,[w(traceTime(kk)).x w(traceTime(kk)).y]);
                closestPt(kk) = min(tD);
            end
            if min(closestPt)<10
                
                [~,idx] = min(closestPt);
                c = dsearchn([w(traceTime(idx)).x w(traceTime(idx)).y],choice);
                
                choice = [w(traceTime(idx)).x(c) w(traceTime(idx)).y(c)];
                new = w(traceTime(idx));
                m([m.wid]==new.id & [m.fid]==new.time).label = 0;
            else
                
                closestPt = [];
                ca
                imshow(read(V,missing(jj)+1));
                ho
                for kk = 1:length(traceTime)
                    plot(w(traceTime(kk)).x,w(traceTime(kk)).y,'-o')
                end
                title([num2str(jj) ' of ' num2str(length(missing))])
                choice = ginput(1);
                if ~isempty(choice)
                    for kk = 1:length(traceTime)
                        
                        [~,tD] = dsearchn(choice,[w(traceTime(kk)).x w(traceTime(kk)).y]);
                        closestPt(kk) = min(tD);
                    end
                    [~,idx] = min(closestPt);
                    c = dsearchn([w(traceTime(idx)).x w(traceTime(idx)).y],choice);
                    
                    choice = [w(traceTime(idx)).x(c) w(traceTime(idx)).y(c)];
                    new = w(traceTime(idx));
                    
                    m([m.wid]==new.id & [m.fid]==new.time).label = 0;
                else
                    noWhisker = [noWhisker missing(jj)];
                end
                
            end
        else
            closestPt = [];
            close all
            imshow(read(V,missing(jj)+1));
            
            hold on
            
            for kk = 1:length(traceTime)
                plot(w(traceTime(kk)).x,w(traceTime(kk)).y,'-o')
            end
            title([num2str(jj) ' of ' num2str(length(missing))])
            choice = ginput(1);
            if ~isempty(choice)
                for kk = 1:length(traceTime)
                    [~,tD] = dsearchn(choice,[w(traceTime(kk)).x w(traceTime(kk)).y]);
                    closestPt(kk) = min(tD);
                end
                [~,idx] = min(closestPt);
                c = dsearchn([w(traceTime(idx)).x w(traceTime(idx)).y],choice);
                %replace choice with a point on the closest trace. This is useful
                %for serial tracking.
                choice = [w(traceTime(idx)).x(c) w(traceTime(idx)).y(c)];
                new = w(traceTime(idx));
                m([m.wid]==new.id & [m.fid]==new.time).label = 0;
                
            else
                noWhisker = [noWhisker missing(jj)];
            end
        end
    end
    lm = length(m);
    lw = length(w);
    for jjj = 1:length(noWhisker)
        
        names = fieldnames(m);
        timer = strcmp(names,'fid');
        names = names(~timer);
        for kk = 1:length(names)
            m(lm+jjj).(names{kk}) = [];
        end
        m(lm+jjj).fid = noWhisker(jjj);
        m(lm+jjj).label = 0;
        m(lm+jjj).wid = 888;
        
        names = fieldnames(w);
        timer = strcmp(names,'time');
        names = names(~timer);
        
        for kk = 1:length(names)
            w(lw+jjj).(names{kk}) = [];
        end
        w(lw+jjj).time= noWhisker(jjj);
        w(lw+jjj).id= 888;
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
%     for jj = 1:length(noWhisker)
%         names = fieldnames(m);
%         timer = strcmp(names,'fid');
%         names = names(~timer);
%         for kk = 1:length(names)
%             keepM(noWhisker(jj)).(names{kk}) = [];
%         end
%         
%         names = fieldnames(w);
%         timer = strcmp(names,'time');
%         names = names(~timer);
%         
%         for kk = 1:length(names)
%             keepW(noWhisker(jj)).(names{kk}) = [];
%         end
%     end
    
    
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
    
    % verify that nothing bad got tracked for this file
    fig
    ho
    for jj = 1:5:length(keepW)
        plot(keepW(jj).x,keepW(jj).y,'-.')
    end
end

