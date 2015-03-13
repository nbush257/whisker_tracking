function manipOut = findManip(vidFileName,manipPresence)
%%%% WARNING! LIABLE TO TRACK THE WHISKER %%%%%%%

ca


%% try just manually getting the manipulator presence.
enterManip = manipPresence(:,1);
leaveManip = manipPresence(:,2);

v = seqIo(vidFileName,'r');
manipOut = {};
manipOutAllPix = {};
initialROI = {};
initialManip = {};
initialManipAllPix = {};

for ii = 1:length(enterManip)
    v.seek(enterManip(ii)-1);
    I = v.getframe();
    [initialROI{ii},initialManip{ii},initialManipAllPix{ii}]=manualTrackManip(I);
    manipOut{enterManip(ii)} = initialManip{ii}{1};
    manipOutAllPix{enterManip(ii)} = initialManipAllPix{ii}{1};
end
close all

for ii = 1:length(enterManip)
    uicontrol('Style','text','String',['working on clip ' num2str(ii) ' of ' num2str(length(enterManip))])
    [clipsManipOut{ii},clipsManipOutAllPix{ii}] = clipGetManip(v,initialROI{ii},enterManip(ii),leaveManip(ii));
    for jj = enterManip(ii):leaveManip(ii)
        manipOut{jj} = clipsManipOut{ii}{jj};
        manipOutAllPix{jj} = clipsManipOutAllPix{ii}{jj};
    end
    manipOut{enterManip(ii)} = initialManip{ii}{1};
end
save([vidFileName(1:end-4) '_manipulator.mat'],'manipOut');

