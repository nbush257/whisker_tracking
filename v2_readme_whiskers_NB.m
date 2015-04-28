%% UI section

%% Need to solve the timestamp issue
%%
% 
% whiskerID = 0;
% manipID=1;
% 
% % get the pixel to meter conversion for the video
% edit pix2m3D.m
% % create the settings file
% edit genSettings2D.m
% 
% %%
% wStruct = LoadWhiskers([PT.path '\' PT.TAG '.whiskers'])
% mStruct = LoadMeasurements([PT.path '\' PT.TAG '.measurements'])

whisker = wStruct([mStruct.label]==whiskerID);
manip = wStruct([mStruct.label]==manipID);

gapped = struct([]);
for ii = 0:max([wStruct.time])
    thisFrame = find([whisker.time] == ii);
    if length(thisFrame)>1
        error('Multiple Whiskers found in the same frame')
    elseif length(thisFrame) == 1
        gapped(ii+1).id = whisker(thisFrame).id;
        
        gapped(ii+1).time = whisker(thisFrame).time;
        gapped(ii+1).x = whisker(thisFrame).x;
        gapped(ii+1).y =whisker(thisFrame).y;
        gapped(ii+1).thick = whisker(thisFrame).thick;
        gapped(ii+1).scores = whisker(thisFrame).scores;
    elseif length(thisFrame) ==0
        gapped(ii+1).id = [];
        gapped(ii+1).time = ii;
        gapped(ii+1).x = [];
        gapped(ii+1).y = [];
        gapped(ii+1).thick = [];
        gapped(ii+1).scores = [];
    else
        disp('You found a blackhole where no numbers exist')
    end
end





