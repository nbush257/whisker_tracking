function manipOut = findManip(vidFileName,manipPresence,varargin)
%%%% WARNING! LIABLE TO TRACK THE WHISKER %%%%%%%

ca
%%
enterManip = manipPresence(:,1);
leaveManip = manipPresence(:,2);
if length(varargin) ==1
    PT = varargin{1};
    outFileName = [PT.TAG '_Manip.mat'];
else
    outFileName = sprintf([vidFileName '_F%06i%06i_Manip.mat'],enterManip,leaveManip);
end
%% try just manually getting the manipulator presence.

isSeq = strcmp(vidFileName(end-2:end),'seq');
if isSeq
    v = seqIo(vidFileName,'r');
else
    v = VideoReader(vidFileName);
end

manipOut = struct([]);
manipOutAllPix = struct([]);
initialROI = {};
initialManip = struct([]);
initialManipAllPix = struct([]);

for ii = 1:length(enterManip)
    if isSeq
        v.seek(enterManip(ii)-1);
        I = v.getframe();
    else
        I = read(v,ii);
        I = squeeze(I(:,:,1));
    end
    
    [initialROI{ii},initialManip,initialManipAllPix]=manualTrackManip(I);
    manipOut(enterManip(ii)).x = initialManip.x;
    manipOut(enterManip(ii)).y = initialManip.y;
    manipOut(enterManip(ii)).time = enterManip(ii);
    
    
    manipOutAllPix(enterManip(ii)).x = initialManipAllPix.x;
    manipOutAllPix(enterManip(ii)).y = initialManipAllPix.y;
    manipOutAllPix(enterManip(ii)).time = enterManip(ii);
end

close all force

for ii = 1:length(enterManip)
    if length(enterManip)>1
        uicontrol('Style','text','Position',[100 150 150 30],'String',['working on clip ' num2str(ii) ' of ' num2str(length(enterManip))])
    end
    [clipManipOut,clipManipOutAllPix] = clipGetManip(v,initialROI{ii},enterManip(ii),leaveManip(ii));
    clipManipOut(enterManip(ii)) = manipOut(enterManip(ii));
    clipManipOutAllPix(enterManip(ii)) = manipOutAllPix(enterManip(ii));
    tag = sprintf('_F%06iF%06i_manip.mat',enterManip(ii),leaveManip(ii));
    outFileName = [vidFileName(1:end-4) tag '.mat']
    %save(outFileName,'clipManipOut','clipManipOutAllPix');
    
    manipOut(enterManip(ii)+1:leaveManip(ii)) = clipManipOut(enterManip(ii)+1:leaveManip(ii));
    manipOutAllPix(enterManip(ii)+1:leaveManip(ii)) = clipManipOutAllPix(enterManip(ii)+1:leaveManip(ii));
end
save(outFileName,'manipOut');

