function [ manipData ] = fitManipLine( manipData )
% function [ manipData ] = fitManipLine( manipData )
%
% For every frame in manipData, this function fits a line to the 
% x/y points defining the manipulator. New fields are then added to the
% structure called manipLineX and manipLineY that can be subsequently used
% to search for the contact point with the whisker on each frame.
% 
% John Sheppard, 29 October 2014

for count = 1:length(manipData)
    
    x = manipData(count).x;
    y = manipData(count).y;
    
    betas = polyfit(x,y,1);
    
    manipY = betas(1)*x + betas(2);
    
    manipData(count).manipX = [x(1), x(end)];
    manipData(count).manipY = [manipY(1), manipY(end)];

end % EOF

