function seq2tifstack(prefix,seqDir,outDir,startFrame,endFrame,frameRate)
% function seq2tifstack(prefix,seqDir,outPath)
%
% This function exports a .seq file to a tif image stack.
% John Sheppard, Sep-30-2014

if nargin < 3
    seqDir = [pwd '/'];
end

if nargin < 4;
    outDir = seqDir;
end

if nargin < 5
    startFrame = 0;
end

if nargin < 7
    frameRate = 1;
end

seqPath = [seqDir, prefix, '.seq'];

% Read seq file with seqIo (requires seqPlayer utilities).
thisSeq = seqIo(seqPath,'r');
seqInfo = thisSeq.getinfo();

if nargin < 6
    % Recall 0 indexing
    endFrame = seqInfo.numFrames-1;
end

filename = [outDir,prefix,'.tif'];
filepath = [outDir, '/', filename];
delete(filepath);

count = 1;
thisSeq.seek(startFrame);
imwrite(thisSeq.getframe(),filename);

for ii = startFrame+1:frameRate:endFrame
    count = count + 1;
    thisSeq.seek(ii);
    imwrite(thisSeq.getframe(),filename,'writemode','append');
end

disp(['Wrote ',num2str(count),' images to tif stack ',filepath])

end