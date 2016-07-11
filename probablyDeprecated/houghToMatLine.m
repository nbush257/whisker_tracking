function [CP,wStructOut] = houghToMatLine(Y0,Y1,wStruct)
thresh = 5;
if length(Y0)~= length(Y1) | length(Y0)~=length(wStruct)
    error('mismatch in size of data')
end
CP = nan(length(Y0),2);
wStructOut = wStruct;

parfor ii = 1:length(Y0)
    
    xOut = wStruct(ii).x;
    yOut = wStruct(ii).y;
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
    
    % interpolate between endpoints of soon to be gap
    toRm = find(d<thresh);
    if ~isempty(toRm)
        xIn = linspace(xOut(toRm(1)),xOut(toRm(end)),length(toRm));
        
        % remove any tracked point within the threshold number of pixels
        xOut(d<thresh) = [];
        yOut(d<thresh) = [];
        warning off
        % do a quadratic fit over the gap. If there is an error, fit all the
        % way to the end.
        try
            p = polyfit(xOut(toRm(1)-5:toRm(1)+5),yOut(toRm(1)-5:toRm(1)+5),2);
        catch
            p = polyfit(xOut(toRm(1)-5:end),yOut(toRm(1)-5:end),2);
        end
        warning on
        yIn = polyval(p,xIn);
    end
    
    
    % find the 2D CP
    [x1,y1] = intersections(xOut,yOut,[0;640],[Y0(ii);Y1(ii)]);
    if length(x1)>1
        x1 = x1(1);
        y1 = y1(1);
    end
    
    if ~isempty(x1)
        CPx = x1;
        CPy = y1;
    else
        CPx = NaN;
        CPy = NaN;
    end
    
    % replace with interpolated polynomial
    if ~isempty(toRm)
        xOut = popIn(xIn,xOut,toRm(1));
        yOut = popIn(yIn,yOut,toRm(1));
    end
    
    % plot every 1000 frames. Doesn't work if parallel.
    if mod(ii,1000) == 0
        
        sprintf('Frame %i',ii)
        clf
        plot(xOut,yOut,'.')
        ho
        plot([0;640],[Y0(ii);Y1(ii)],'r')
        plot(CPx,CPy,'o')
        axx(0,640)
        axy(0,480)
        drawnow
    end
    
    wStructOut(ii).x  = xOut;
    wStructOut(ii).y  = yOut;
    
    CP(ii,:) = [CPx CPy];
    
    
end
function xOut = popIn(a,x,n)
if isrow(x)
    x = x';
end
if isrow(a)
    a = a';
end

if length(x)<n
    xOut = [x;nan(length(a),1)];
    xOut(n:end) = a;
elseif length(x) == n
    xOut = [x;a]; 
else
    xOut = cat(1,x(1:n), a, x(n+1:end));
    
end

