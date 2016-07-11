function getCalibTiffs(trialString)
% get calibration tiffs
% use this script to write a set of caliration images to tiffs.
%% Get the file name.

% Try to match the front and top calib files with the input argument
topVidName = [trialString 'Top_calib.seq'];
frontVidName = [trialString 'Front_calib.seq'];

% if no arguments or the file names dont exist
if nargin>0 || ~exist(topVidName,'file') || ~exist(frontVidName,'file')
    warning('Files in argument not found. Opening filefinder...')
    try
        [templateStr,pName] = uigetfile('*.seq','Choose one of the videos for this calibration.The corresponding alternate view will be automatically chosen');
        cd(pName)
        d = dir([templateStr(1:regexp(templateStr,'t\d\d_','end')) '*calib*.seq']);
        
        assert(length(d)==2)
        
        % Find the appropriate view from the filename
        if regexp(d(1).name,'Front')
            frontVidName = d(1).name;
            topVidName = d(2).name;
        else
            frontVidName = d(2).name;
            topVidName = d(1).name;
        end
        
    catch
        % If there is an error, open two dialog boxes to get the files
        [frontVidName,pName] = uigetFile('*.seq','Choose the FRONT Calibration Video')
        cd(pName)
        [topVidName] = uigetFile('*.seq','Choose the TOP Calibration Video')
    end
end


frames2grab = frames;
top = seqIo(topVidName,'r');
front = seqIo(frontVidName,'r');


topTifDir = ['calibTiffs_' topVidName(1:end-4)];
frontTifDir = ['calibTiffs_' frontVidName(1:end-4)];
mkdir(topTifDir);
mkdir(frontTifDir);
count = 0;
for i = frames2grab
    count = count+1;
    top.seek(i-1);
    front.seek(i-2);
    fI = front.getframe();
    %     fI = adapthisteq(fI);
    tI = top.getframe();
    %     tI = adapthisteq(tI);
    cd(topTifDir)
    imwrite(tI,['top' int2str(count) '.tif'],'tif')
    cd ..
    cd(frontTifDir)
    imwrite(fI,['front' int2str(count) '.tif'],'tif')
    cd ..
end

