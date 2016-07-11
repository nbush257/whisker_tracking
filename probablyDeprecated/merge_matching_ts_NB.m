function wStructOut = merge_matching_ts(wStruct)

allTimes = [wStruct.time];
count = 0;

for ii = min(allTimes):max(allTimes)
    count = count+1;
    sameTime = find(ismember(allTimes,ii));
    newX = [];
    newY = [];
    for jj = 1:length(sameTime)
        x = wStruct(sameTime(jj)).x;
        y = wStruct(sameTime(jj)).y;
        if isrow(x)
            x = x';
        end
        if isrow(y)
            y = y';
        end
        
        newX = [newX;x];
        newY = [newY;y];
    end
    wStructOut(count).x = double(newX);
    wStructOut(count).y = double(newY);
    wStructOut(count).time = double(ii);
end

        
