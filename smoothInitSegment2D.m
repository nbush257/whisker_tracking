function wStructOut = smoothInitSegment2D(wstruct)

warning('off')
plotting = 0;
for i = 1:length(wstruct)
    endInit = 50;% length of the initial fit
    
    % if the initial fit length is longer than the whisker, replace the
    % whole whisker
    if length(wstruct(i).x)<endInit
        endInit = length(wstruct(i).x);
    end
    
    % get the temporary x and y values
    x = wstruct(i).x(1:endInit);
    y = wstruct(i).y(1:endInit);
    
    % the if clause makes sure we are using the fit on the better
    % dimension for fitting.
    if var(x)>var(y)
        % fit a fourth order polynomial to the initial segment
        p = polyfit(x,y,4);
        newX = linspace(x(1),x(endInit),endInit);
        newY = polyval(p,newX);
    else
        newY = linspace(y(1),y(endInit),endInit);
        p = polyfit(y,x,4);
        newX = polyval(p,newY);
    end
    
    % set the output structure equal to the initial struct. (doubles)
    wStructOut(i).x = double(wstruct(i).x);
    wStructOut(i).y = double(wstruct(i).y);
    
    % replace the first segment with our smoothed fit.
    wStructOut(i).x(1:endInit) = double(newX);
    wStructOut(i).y(1:endInit) = double(newY);
    wStructOut(i).time = wstruct(i).time;
    
    
    %% If the plotting flag is true, we plot the frames.
    if plotting
        plot(wstruct(i).x,wstruct(i).y,'go')
        hold on
        plot(newX,newY,'r.')
        legend({'Original','New Fits'})
        axis([min(newX)-10 max(newX)+10 min(newY)-10 max(newY)+10])
        pause(.1)
        cla
    end
    
end



