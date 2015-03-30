function wStructOut = merge_matching_ts(wStruct,useX,basepoint_smaller)
%% function wStructOut = merge_matching_ts(wStruct)
% --------------------------------------------------------------------
% Takes whisk input with multiple tracked whiskers per frame and combines
% them into a single whisker per frame. Also sorts the whisker depending on
% the position of the basepoint and direction of whisker.
% --------------------------------------------------------------------
% INPUTS:
%   wStruct = 'whisk' struct
% OUTPUTS:
%   wStructOut = 'whisk'-like struct with combined whiskeres from the same
%   frame. Also casts all values to doubles.
% --------------------------------------------------------------------
% Nick Bush 2015_03_30
% --------------------------------------------------------------------

% grab times from all frames
allTimes = [wStruct.time];
count = 0;
% iterate over all times between the minimum and maximum of all the times.
for ii = min(allTimes):max(allTimes)
    count = count+1;
    %% find indices of all frames that share a time with the current time
    sameTime = find(ismember(allTimes,ii));
    newX = [];
    newY = [];
    
    %% skip frames with one or no whiskers tracked.
    if length(sameTime)<=1
        % sort the whisker
        [newX,newY] = sortWhisker(x,y,useX,basepoint_smaller);
        % Output
        wStructOut(count).x = double(newX);
        wStructOut(count).y = double(newY);
        wStructOut(count).time = double(ii);
        continue
    end
    
    %% Concatenate all x and y coords for same frame times.
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
    end % End single frame for loop
    %% Sort the whisker
    [newX,newY] = sortWhisker(newX,newY,useX,basepoint_smaller);    
    %% Outputs
    wStructOut(count).x = double(newX);
    wStructOut(count).y = double(newY);
    wStructOut(count).time = double(ii);
end% End all time frames for loop
end% EOF



