function [ allWhiskers ] = concatWhiskerStruct( framesPerBlock, whiskerDir, prefix, saveallWhiskers, outName )
% function [ allWhiskers ] = concatWhiskerStruct( framesPerBlock, whiskerDir, prefix, saveallWhiskers, outName )
%   Function reads in blocks of whisker files and concatenates them into a
%   single whiskers struct.

if nargin < 1
    framesPerBlock = 5000;
end

if nargin < 5
    outName = 'allWhiskers';
end

if nargin < 4
    saveallWhiskers = 0;
end

if nargin < 3
    prefix = 'block';
end

if nargin < 2
    whiskerDir = pwd;
end

if exist(whiskerDir,'dir')
    cd(whiskerDir);
end

% Initialize allWhiskers
allWhiskers = [];

whiskerDirContents = dir(whiskerDir);

theseFiles = strmatch(prefix,{whiskerDirContents.name});

% Go through each whisker block individually.

blockCount=0;
for fileCount = [theseFiles(:)]'
    blockCount=blockCount+1;
    thisWhiskerFile = whiskerDirContents(fileCount).name;
    thisWhiskerPath = [whiskerDir '/' thisWhiskerFile];
    thisWhiskerStruct = LoadWhiskers(thisWhiskerPath);
    thisWhiskerStruct = updateFrameTimes(thisWhiskerStruct,framesPerBlock,blockCount);
    allWhiskers = [allWhiskers; thisWhiskerStruct];
end

% Save the concatenated whisker struct in .mat format
if saveallWhiskers
    outPath = [whiskerDir '/' outName '.mat'];
    delete(outPath);
    save(outPath,'allWhiskers');
end

end % EOF

function thisWhiskerStruct = updateFrameTimes(thisWhiskerStruct,framesPerBlock,blockCount)
% function thisWhiskerStruct = updateFrameTimes(thisWhiskerStruct,framesPerBlock,blockCount)
% Corrects the frame times when concatenating a whisker struct from shortened tif
% blocks.

previousFrame = framesPerBlock*(blockCount-1);

for frameCount = 1:length(thisWhiskerStruct)
    thisWhiskerStruct(frameCount).time = thisWhiskerStruct(frameCount).time + previousFrame;
end

end % EOF
