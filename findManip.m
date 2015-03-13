function manipOut = findManip(vidFileName,manipPresence)
%%%% WARNING! LIABLE TO TRACK THE WHISKER %%%%%%%

ca


%% try just manually getting the manipulator presence.
enterManip = manipPresence(:,1);
leaveManip = manipPresence(:,2);

v = seqIo(vidFileName,'r');
manipOut = struct([]);
manipOutAllPix = struct([]);
initialROI = {};
initialManip = struct([]);
initialManipAllPix = struct([]);

for ii = 1:length(enterManip)
    v.seek(enterManip(ii)-1);
    I = v.getframe();
    [initialROI{ii},initialManip,initialManipAllPix]=manualTrackManip(I);
    manipOut(enterManip(ii)).x = initialManip.x;
    manipOut(enterManip(ii)).y = initialManip.y;
    manipOut(enterManip(ii)).time = enterManip(ii);
    
    
    manipOutAllPix(enterManip(ii)).x = initialManipAllPix.x;
    manipOutAllPix(enterManip(ii)).y = initialManipAllPix.y;
    manipOutAllPix(enterManip(ii)).time = enterManip(ii);
end

close all

for ii = 1:length(enterManip)
    uicontrol('Style','text','Position',[100 150 150 30],'String',['working on clip ' num2str(ii) ' of ' num2str(length(enterManip))])
    [clipManipOut,clipManipOutAllPix] = clipGetManip(v,initialROI{ii},enterManip(ii),leaveManip(ii));
    manipOut(enterManip(ii)+1:leaveManip(ii)) = clipManipOut(enterManip(ii)+1:leaveManip(ii));
    manipOutAllPix(enterManip(ii)+1:leaveManip(ii)) = clipManipOutAllPix(enterManip(ii)+1:leaveManip(ii));
end
save([vidFileName(1:end-4) '_manipulator.mat'],'manipOut');

