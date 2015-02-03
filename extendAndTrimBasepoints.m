function [ whiskerData ] = extendAndTrimBasepoints( whiskerData, useX, basepointSmaller )
% function [ whiskerData ] = extendAndTrimBasepoints( whiskerData, useX, basepointSmaller )
%   This function allows the user to specify a position for the basepoint
%   to be used in all frames of WhiskerData.
%
% John Sheppard, 7 November 2014
% Based on code written by James Ellis

%%  function LOCAL_extend(whiskerData,frame_name)
        imageName = input('\nWhat is the full filename of the image to select the basepoint?\n\n','s');
        
        if exist(imageName,'file') ~= 2
            fprintf([imageName,' does not exist in path\n'])
            whiskerData = extendBasepoints(whiskerData,useX,basepointSmaller);
            return
        end
        figure;
        imshow(imread(imageName))
        text(50,100,sprintf('Zoom in on the whisker base\n\nThen press ENTER'),'BackgroundColor',[.9,.9,.9]);
        sprintf('\nZoom in on the whisker base\n\nThen press ENTER')
        pause
        text(50,100,'Define the whisker base','BackgroundColor',[.9,.9,.9]);hold on
        sprintf('\nDefine the whisker base')
        axis on
        BP = ginput(1);
        
        for jj = 1:length(whiskerData)
            
%             whiskerData(jj).x = double([whiskerData(jj).x(:);BP(1)]);
%             whiskerData(jj).y = double([whiskerData(jj).y(:);BP(2)]);
            
            %   Are any points beyond the selected BP?
            if basepointSmaller
                if useX
                    tooLongIndexes = find(whiskerData(jj).x < BP(1));
                else
                    tooLongIndexes = find(whiskerData(jj).y < BP(2));
                end
            else % if ~basepointSmaller
                if useX
                    tooLongIndexes = find(whiskerData(jj).x > BP(1));
                else
                    tooLongIndexes = find(whiskerData(jj).y > BP(2));
                end
            end
            
            whiskerData(jj).x(tooLongIndexes) = [];
            whiskerData(jj).y(tooLongIndexes) = [];

        end
        
end
