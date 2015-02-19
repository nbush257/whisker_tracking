function manipOut = findManip(vidFileName,manipPresence)
%%%% WARNING! LIABLE TO TRACK THE WHISKER %%%%%%%




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

for ii = 1:length(enterManip)
    ii
    [clipsManipOut,clipsManipOutAllPix] = clipGetManip(v,initialROI{ii},enterManip(ii),leaveManip(ii));
    for jj = enterManip(ii):leaveManip(ii)
        manipOut{jj} = clipsManipOut{jj};
        manipOutAllPix{jj} = clipsManipOutAllPix{jj};
    end
    manipOut{enterManip(ii)} = initialManip{ii}{1};
end
save([vidFileName(1:end-) '_manipulator.mat'],'manipOut','manipOutAllPix');

