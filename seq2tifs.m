function seq2tifs(prefix,startFrame,endFrame,frameRate,isCalibrationImage,seqDir,outDir)
% function seq2tifs(prefix,startFrame,endFrame,frameRate,isCalibrationImage,seqDir,outDir)
%
% This function exports a .seq file to a tif image stack.
% John Sheppard, Sep-30-2014

if nargin < 6
    seqDir = [pwd '/'];
end

if nargin < 7;
    outDir = [seqDir '/tif/'];
    mkdir(outDir);
end

if nargin < 2
    startFrame = 0;
end

if nargin < 4
    frameRate = 1;
end

if nargin < 5
    isCalibrationImage = 0;
end

if length(prefix) > 4 && prefix(end-3) == '.'
    prefix = prefix(1:end-4);
end

    seqPath = [seqDir, prefix, '.seq'];

    % Read seq file with seqIo (requires seqPlayer utilities).
    thisSeq = seqIo(seqPath,'r');
    seqInfo = thisSeq.getinfo();

    if nargin < 3
        % Recall 0 indexing
        endFrame = seqInfo.numFrames-1;
    end

if isCalibrationImage
    count = 0;
    for ii = startFrame:frameRate:endFrame
        count = count + 1;
        filename = [outDir,prefix,'_',sprintf('%02d',count),'.tif'];
        thisSeq.seek(ii);
        imwrite(thisSeq.getframe(),filename);
    end
else
    count = 0;
    for ii = startFrame:frameRate:endFrame
        count = count + 1;
        filename = [outDir,prefix,'_',sprintf('%02d',ii),'.tif'];
        thisSeq.seek(ii);
        imwrite(thisSeq.getframe(),filename);
    end
end
disp(['Wrote ',num2str(count),' images to ',outDir])

end