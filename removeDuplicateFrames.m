function whiskerData = removeDuplicateFrames(whiskerData,mode)
% function whiskerData = removeDuplicateFrames(whiskerData,mode)
%
% This function identifies duplicate tracking entries pertaining to the
% same video frame of the seq file. These are screened such that only one
% frame remains in the output dataset. The duplicate frames are first
% sorted based on the following criteria in descending order of importance:
% (1) whether frames have a stable basepoint, (2) whether the frame has a
% length violation, (3) whether the tracked whisker has a length
% discontinuity compared with adjacent whisker lengths, and (4) the 2-D
% length of the segment (longest segment preferred). Based on these
% criteria, a single preferred frame is selected and all other duplicate
% entries are discarded. NB: Criteria 1-3 only are performed for the
% tracked whiskers; duplicate frames for manipulator data are discarded
% based only upon the 2-D length.
%
% Inputs
% whiskerData -- tracked data loaded from .whiskers file
% mode -- 'whisker' or 'manipulator'
%
% John Sheppard, 1 November 2014

if nargin < 2
    mode = 'whisker';
end

frameTimes = [whiskerData.time];
dupFrameTimes = [];

for count = 1:length(whiskerData)
    
    numFrames = length( find( [whiskerData.time] == frameTimes(count)));
    
    if numFrames > 1
        dupFrameTimes = [dupFrameTimes, frameTimes(count)];
    end
    
end

dupFrameTimes = unique(dupFrameTimes);

for count = 1:length(dupFrameTimes)
    
    theseEntries = find( [whiskerData.time] == dupFrameTimes(count) );
    
    entryLengths = nan(1,numel(theseEntries));
    
    for entryCount = 1:length(theseEntries)
        thisEntry = theseEntries(entryCount);
        entryLengths(entryCount) = getWhiskerLength(whiskerData(thisEntry).x,whiskerData(thisEntry).y);
    end
    
    %{
    if strcmp(mode,'whisker')
        
        stableBasepoints = [whiskerData(theseEntries).stableBasepoint];
        validLengths = [whiskerData(theseEntries).validLength];
        contigFrames = [whiskerData(theseEntries).contigFrame];
        
        % This routine is sloppy, but don't know how to sort a vector by
        % multiple criteria. -jps
        badIndexes = find(~stableBasepoints);
        if find(stableBasepoints)
            theseEntries(badIndexes)=[];
            validLengths(badIndexes) = [];
            contigFrames(badIndexes) = [];
            entryLengths(badIndexes) = [];
        end
        
        badIndexes = find(~validLengths);
        if find(validLengths)
            theseEntries(badIndexes)=[];
            contigFrames(badIndexes) = [];
            entryLengths(badIndexes) = [];
        end
        
        badIndexes = find(~contigFrames);
        if find(contigFrames)
            theseEntries(badIndexes)=[];
            entryLengths(badIndexes) = [];
        end
        
    end % if 'whisker' mode
    %}
    
    theseEntryIndexes = 1:numel(theseEntries);
    
    [junk,theseEntryIndexesSorted] = sort(entryLengths,1,'descend');
    
    badIndexes = theseEntryIndexesSorted(2:end);
    badEntries = theseEntries(badIndexes);
    
    % Remove the duplicate indexes chosen for omission.
    whiskerData(badEntries) = [];
    
end

end % EOF
