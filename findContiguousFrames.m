function findContiguousFrames(struct1,struct2,lowCut);

if nargin < 3
    lowCut = 50;
end

maxTime = max([struct1(end).time, struct2(end).time]);

allTimes1 = nan(1,maxTime);
allTimes2 = nan(1,maxTime);

frameTimes1 = [struct1.time];
frameTimes2 = [struct2.time];

allTimes1(frameTimes1) = frameTimes1;
allTimes2(frameTimes2) = frameTimes2;

sumTimes = sum([allTimes1;allTimes2],1);

areFramesContig = ~isnan(sumTimes);

NaNIndexes = find(isnan(areFramesContig));

ContigSegmentStartIndexes = NaNIndexes

BlockLengths = diff(NaNIndexes);

%contigSegments = BlockLengths>1;

contigSegments = BlockLengths >= lowCut;

for segmentCount = 1:length(BlockLengths)
    
    
    if contigSegments(segmentCount)
        
        segmentLength = 
        
        
    end
    
end

