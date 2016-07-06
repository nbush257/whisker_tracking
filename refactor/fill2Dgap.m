function outStruct = fill2Dgap(structIn)
%% function outStruct = fill2Dgap(structIn)
% This is meant to fill in holes in the whisker, although it is not
% commented and therefore is probably in bad shape. Sanity checks and
% refactorization are suggested

warning('This code is poorly commented, sanity checks are suggested')

PlotFlag = 0;
for ii = 1:length(structIn)
    if isempty(structIn(ii).x);continue;end
    dx = diff(structIn(ii).x);
    dy = diff(structIn(ii).y);
    gap = sqrt(dx.^2+dy.^2)>4 & sqrt(dx.^2+dy.^2)<100;
    gap = find(gap);
    if any(gap)
        gap(gap<2)=2;
        yout = [];
        xout = [];
        for jj = 1:length(gap)
            try
                youtGap = interp1([structIn(ii).x(gap(jj)-1) structIn(ii).x(gap(jj)+1)],[structIn(ii).y(gap(jj)-1) structIn(ii).y(gap(jj)+1)],structIn(ii).x(gap(jj)-1):structIn(ii).x(gap(jj)+1));
                yout = [yout youtGap];
                xout = [xout structIn(ii).x(gap(jj)-1):structIn(ii).x(gap(jj)+1)];
            end
        end
        
        outStruct(ii).x = [structIn(ii).x;xout'];
        outStruct(ii).y = [structIn(ii).y;yout'];
        outStruct(ii).time = structIn(ii).time;
    else
        outStruct(ii).x = structIn(ii).x;
        outStruct(ii).y = structIn(ii).y;
        outStruct(ii).time = structIn(ii).time;
    end
    if PlotFlag
        cla
        plot(structIn(ii).x,structIn(ii).y,'.')
        ho
        plot(outStruct(ii).x,outStruct(ii).y,'o')
        axis([0 640 0 480])
        drawnow
    end
    
    
    
end