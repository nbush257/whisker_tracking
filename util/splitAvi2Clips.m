function splitAvi2Clips(aviDir,step)
%% function splitAvi2Clips(aviDir)
% splits an avi into clips of length step
%% 


for ii = 1:length(aviDir)
    numFrames = V.numberOfFrames;
    bds = [1:step:numFrames numFrames];
    numClips = length(bds)-1;
    parfor jj = 1:numClips
        V = VideoReader(aviDir(ii).name);

        startFrame = bds(jj);
        endFrame = bds(jj+1)-1;
        if jj==numClips
            endFrame = endFrame+1;
        end
        fileOutName = sprintf([aviDir(ii).name(1:end-4) '_F%06iF%06i.avi'],startFrame,endFrame);
        outName = [aviPath '\' fileOutName];
        W = VideoWriter(outName,'Grayscale AVI');
        W.open;
        for kk = startFrame:endFrame
            if mod(kk,500)==0
                fprintf('Frame %06d of %06d on clip %d\n',kk,numFrames,numClips)
            end
            I = read(V,kk);
            writeVideo(W,I);
        end
        W.close;
        close all force
    end
end