function wStructOut = houghToMatLine(Y0,Y1,wStruct)
wStructOut = wStruct;
for ii = 1:length(Y0)
    if length(wStruct(ii).x)==0
        continue
    end
    if isnan(Y0(ii))
        continue
    end
    
    Q2 = [640 Y1(ii)];
    Q1 = [0 Y0(ii)];
    P = [wStruct(ii).x wStruct(ii).y];
    d = [];
    
    for jj = 1:size(P,1)
        d(jj) =  abs(det([Q2-Q1;P(jj,:)-Q1]))/norm(Q2-Q1);
    end
    wStructOut(ii).x(d<5) = [];
    wStructOut(ii).y(d<5) = [];
    [x1,y1] = intersections(wStructOut(ii).x,wStructOut(ii).y,[0;640],[Y0(ii);Y1(ii)]);
    if mod(ii,100) == 0
        clf
        plot(wStructOut(ii).x,wStructOut(ii).y,'.')
        ho
        plot([0;640],[Y0(ii);Y1(ii)],'r')
        plot(x1,y1,'o')
        axx(0,640)
        axy(0,480)
        drawnow
    end
    
        
end