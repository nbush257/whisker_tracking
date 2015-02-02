% remove and interpolate manipulator points
function wStruct_no_manip = rmManip(wStruct,manipStruct)
manipWidth = 5;% sets the ergion around the manipulator edge to remove.

wStruct_no_manip = wStruct;
wtimes = [wStruct.time];
manipTimes = [manipStruct.time];

hundreds = round(1:length(wStruct)/100:length(wStruct));
h = waitbar(0,'Please Wait');
for ii =1:length(wStruct)
    if any(ii == hundreds)
        waitbar(ii/length(wStruct),h)
    end
    if ii == 5573
        pause
    end
    x = wStruct(ii).x;
    y = wStruct(ii).y;
    w = double([x y]);
     
    idx = find(manipTimes == wtimes(ii));
    if isempty(idx)
        continue
    end
    
    manipX = manipStruct(idx).x;
    manipY = manipStruct(idx).y;
    manipId = manipStruct(idx).id;
    if manipId ~= 0 % if the id is not 0 then it goes on to the next index
        continue
    end
    
    mMinus  =double([manipX-2 manipY-2]);
    mPlus = double([manipX+2 manipY+2]);
    
    for jj = 1:length(x)
        xTestA = x(jj) < mPlus(:,1) & x(jj) > mMinus(:,1);
        xTestB = x(jj) > mPlus(:,1) & x(jj) < mMinus(:,1);
        
        xTest = xTestA | xTestB;
        
        yTestA = y(jj) < mPlus(:,2) & y(jj) > mMinus(:,2);
        yTestB = y(jj) > mPlus(:,2) & y(jj) < mMinus(:,2);
        
        yTest = yTestA | yTestB;
        
        btw(jj) = any(xTest) & any(yTest);
    end
    x(btw) = nan;
    y(btw) = nan;
    wStruct_no_manip(ii).x = x;
    wStruct_no_manip(ii).y = y;
    

end
waitbar(ii/length(wStruct),h,'AllDone')
   
    
    
    
    
    
    
    
    

