
%%%% WARNING! LIABLE TO TRACK THE WHISKER %%%%%%%

vidFileName = 'rat2015_04_vg_D1_t02_Top.seq';

% manipPresenceSmooth = tsmovavg(manipPresence,'s',150);
% fig;
% plot(manipPresenceSmooth);zoom on; pause;
% thresh = ginput(1);
% thresh = thresh(2);
% 
% isManip = logical(zeros(size(manipPresenceSmooth)));
% isManip(manipPresenceSmooth>thresh) = 1;
% enterManip = find(diff(isManip)==1);
% leaveManip = find(diff(isManip) == -1);

 topManipPresent = [3081 7504; 8410 16569; 18746 25524];
 frontManipPresent = [3078 7500; 8311 16640; 18530 25504];%only for a particular vid
 
%% try just manually getting the manipulator presence.

enterManip = topManipPresent(:,1);
leaveManip = topManipPresent(:,2);
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
    
end


