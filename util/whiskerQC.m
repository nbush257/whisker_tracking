function whiskerQC(tVid,fVid,tW,fW,varargin)
%% function whiskerQC(tVid,fVid,tW,fW,varargin)
% ===========================================
% The purpose of this function is to be a shortcut for viewing how well a
% whisker aligns with a video overlay.
% ==========================================
% INPUTS:
%           tVid - top video filename. Can be an avi or seq. Seq seems more
%           useful
%           fVid - front video filename. Can be an avi or seq.
%           tW - top whisker structure.
%           fW - front whisker structure.
%           [stride] - number of frames to skip when viewing sequentially.
%           [firstFrame] - determines which frame we should start watching
%           the video at. Defaults to 3000
%% varargin handling
narginchk(4,6);
numvargs = length(varargin);
optargs = {10,3000};
optargs(1:numvargs) = varargin;
[stride,firstFrame] = optargs{:};

%% 
[~,~,extT] = fileparts(tVid);
[~,~,extF] = fileparts(fVid);

assert(strcmp(extT,extF))

switch extT
    case '.avi' 
        tV = VideoReader(tVid);
        fV = VideoReader(fVid);
        
        assert(tV.numberOfFrames == fV.numberOfFrames);
        
        figure()
        for ii = firstFrame:stride:tV.numFrames
            subplot(121)
            cla
            imshow(read(tV,ii))
            hold on
            plot(tW(ii).x+1,tW(ii).y+1,'-o')
            drawnow
            
            subplot(122)
            cla
            imshow(read(fV,ii))
            hold on
            plot(fW(ii).x+1,fW(ii).y+1,'-o')
            drawnow
        end

    case '.seq'
        tV = seqIo(tVid,'r');
        fV = seqIo(fVid,'r');
        
        tInfo = tV.getinfo();
        fInfo = fV.getinfo();
        assert(tInfo.numFrames == fInfo.numFrames)
        
        tV.seek(10000);
        fV.seek(10000);
        It = tV.getframe();
        If = fV.getframe();
        tFig = figure;
        imshow(It)
        zoom on 
        drawnow
        pause
        tPos = [xlim;ylim];
        close all

        fFig = figure;
        imshow(If)
        zoom on 
        pause(.1)
        drawnow
        pause
        fPos = [xlim;ylim];
        close all
        
        FF = figure;
        FF.Position = [1 41 1920 963];
        for ii = firstFrame:stride:tInfo.numFrames
            subplot(221)
            tV.seek(ii-1);
            cla
            imshow(tV.getframe())
            title(['Frame: ' num2str(ii)])
            hold on
            plot(tW(ii).x+1,tW(ii).y+1,'-o')
            
            
            subplot(222)
            fV.seek(ii-1);
            cla
            title(['Frame: ' num2str(ii)])
            imshow(fV.getframe())
            hold on
            plot(fW(ii).x+1,fW(ii).y+1,'-o')
            
            
            subplot(223)
            cla
            imshow(tV.getframe())
            hold on
            plot(tW(ii).x+1,tW(ii).y+1,'-o')
            axx(tPos(1),tPos(3))
            axy(tPos(2),tPos(4))
            
            
            subplot(224)
            cla
            imshow(fV.getframe())
            hold on
            plot(fW(ii).x+1,fW(ii).y+1,'-o')
            axx(fPos(1),fPos(3))
            axy(fPos(2),fPos(4))
            drawnow;
        end
    otherwise
        error('wrong video file type')
            
end

        

            
            

