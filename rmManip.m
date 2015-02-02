% remove and interpolate manipulator points
function wStruct_no_manip = rmManip(wStruct,manipStruct)
thresh = 4;% sets the ergion around the manipulator edge to remove.

wStruct_no_manip = wStruct;
wtimes = [wStruct.time];
manipTimes = [manipStruct.time];

hundreds = round(1:length(wStruct)/100:length(wStruct));
h = waitbar(0,'Please Wait');
for ii =1:length(wStruct)
    if any(ii == hundreds)
        waitbar(ii/length(wStruct),h)
    end
    
   
    
    x = wStruct(ii).x;
    y = wStruct(ii).y;
    w = double([x y]);
     
    idx = find(manipTimes == wtimes(ii));
    if isempty(idx)
        continue
    elseif length(idx)>1
        manipIds = [manipStruct(idx).id];
        keep = manipIds==0;
        idx = idx(keep);
    end
    
    manipId = manipStruct(idx).id;
    manipX = manipStruct(idx).x;
    manipY = manipStruct(idx).y;
   
    
    
    mMinus  =double([manipX-2 manipY-2]);
    mPlus = double([manipX+2 manipY+2]);
    
    for jj = 1:length(x)
        d(jj) = min(sqrt((manipX - x(jj)).^2 + (manipY - y(jj)).^2));
    end
    
     x(d<thresh) = nan;
     y(d<thresh) = nan;
     wStruct_no_manip(ii).x = x;
     wStruct_no_manip(ii).y = y;
    

end
waitbar(ii/length(wStruct),h,'AllDone')
   
    
    
    
    
    
    
    
    

