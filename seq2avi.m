%Created by Nick Bush, Jan 2014
%Converts a subset of a seq file into an avi. When converting to avi, you are
%liable to have issues if your timestamps are not perfectly sequential.
%ALWAYS check the video for jumping. You may need to rewrite the
%timestamps. 

% Auto histeqs the frame.
function seq2avi(varargin)
%function seq2avi([startFrame],[endFrame])

% get the seq
[fileName,pathName]=uigetfile('*.seq');
fullName= [pathName fileName];
v = seqIo(fullName,'r');
% get info which has number of frames
vInfo = v.getinfo();

% initialize start and endFrame to default to the whole video
startFrame = 1;
endFrame = vInfo.numFrames;

% chek if there is an input, if one argument, start at that frame, if two
% arguments grab all the frames between the arguments(inclusive)

if length(varargin) == 1
    startFrame = varargin{1};
elseif length(varargin) == 2;
    startFrame = varargin{1};
    endFrame = varargin{2};
end

%prep the output filename
stripSuffix = fullName(1:end-3);
outFilename = [pathName fileName(1:end-4) '_' num2str(startFrame) '_' num2str(endFrame) '.avi'];


w = VideoWriter(outFilename,'Motion JPEG AVI');
open(w);

h = waitbar(0,'converting')
for i = startFrame:endFrame
    waitbar((i-startFrame)/(endFrame-startFrame))
    v.seek(i-1);
    img = v.getframe();
    img = histeq(img);
    writeVideo(w,img);
end
close(h)
close(w)
    