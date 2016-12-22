function [mask,BP] = getMaskAndBP(I)
%% function [mask,BP] = getMaskAndBP(v_name)
% use this function to front load all the user input for whisk2merge
% INPUTS: V - filename for the video
% OUTPUTS:  mask - a binary mask the size of the video frame, used in
%               applyMasktoWhisker
%           BP - location of the basepoint that is used in extendBP
% NEB 2016_12_01
%%
close all force
imshow(I)
title('apply mask where you want to remove tracked points')
set(gcf,'unit','normalized','position',[0 0 1 1]);
mask = roipoly;
close all force


imshow(I);
title('zoom to BP and press enter')
zoom on
pause()
drawnow
title('Click on the BP')
BP = round(ginput(1));
close all 
pause(.01)
