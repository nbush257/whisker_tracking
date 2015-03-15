function manipStructOut = extendManip(manipStruct)
% function manipStructOut = extendManip(manipStruct)
% Takes a tracked manipulator and extends it to the edges of the frame.
% This is useful since sometimes the Hough transform doesn't get
% the entire line.





disp('assumes the frame is 640x480')
for ii = 1:length(manipStruct)
    clear newX newY
    if isempty(manipStruct(ii).x)
        manipStructOut(ii) = manipStruct(ii);
        continue
    end
    x = manipStruct(ii).x;
    y = manipStruct(ii).y;
    time = manipStruct(ii).time;
    %%
    
    try
        p = polyfit([x(1) x(end)],[y(1) y(end)],1);
        newX = 1:.2:640;
        newY = polyval(p,newX);
        
        
        useX = 1;
    catch
        p = polyfit([y(1) y(end)],[x(1) x(end)],1);
        newY = 1:.2:480;
        newX = polyval(p,newY);
        
        useX = 0;
    end
    
    clear p;
    
    
    %%
    idx = newX>640 | newY>480 | newX<0 | newY < 0 ;
    newX(idx) = [];
    newY(idx) = [];
    if length(newX)<100 & useX ==1
        p = polyfit([y(1) y(end)],[x(1) x(end)],1);
        newY = 1:.2:480;
        newX = polyval(p,newY);
        
        idx = newX>640 | newY>480 | newX<0 | newY < 0 ;
        newX(idx) = [];
        newY(idx) = [];
    elseif length(newX)<100 & useX ==0
        p = polyfit([x(1) x(end)],[y(1) y(end)],1);
        newX = 1:.2:640;
        newY = polyval(p,newX);
        
        
        idx = newX>640 | newY>480 | newX<0 | newY < 0 ;
        newX(idx) = [];
        newY(idx) = [];
    end
    
    
    
    
    
    manipStructOut(ii).x = newX;
    manipStructOut(ii).y = newY;
    manipStructOut(ii).time = time;
end

end %EOF
