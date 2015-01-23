function TH = get_TH(xw,yw,PT)
%%  function TH = get_TH(xw,yw)
%   Returns the TH angle (or PHI) of the whisker entered (single frame)

xs = xw;
ys = yw;

if ~isempty(xw)
    
    baser1 = PT.proc_base_segment(1)/PT.pix2m; % back to pixels
    baser2 = PT.proc_base_segment(2)/PT.pix2m; % back to pixels
    
    % Grab data in a radius
    R = sqrt( (xw - xs(1)).^2 + (yw - ys(1)).^2);
    good = logical(baser1 < R & R < baser2);
    x = xw(good);
    y = yw(good);
    
    if size(x,2)~=1, x = x'; end
    if size(y,2)~=1, y = y'; end
    
    bp = [xs(1) ys(1)];
    
    % Grab data on correct side of base
    [~,seg_end] = min(abs(baser2 - sqrt( ...
        (xs - bp(1)).^2 + (ys - bp(2)).^2)));
    v = [xs(seg_end)-bp(1) ys(seg_end)-bp(2)];
    U = [x-bp(1) y-bp(2)];
    angs = acos(dot(repmat(v,size(U,1),1),U,2)./...
        (norm(v)*sqrt(U(:,1).^2 + U(:,2).^2)));
    good = abs(angs) < pi/2;
    x = x(good);
    y = y(good);
    clear v U good seg_end
    
    if ~isempty(x)
        
        % Poly-fit
        pp = polyfit(x,y,1);
        xx = min(x):0.1:max(x);
        yy = polyval(pp,xx);
        
        %Section for vertical angles
        if abs(pp) > 5
            pp = polyfit(y,x,1);
            yy = min(y):0.1:max(y);
            xx = polyval(pp,yy);
        end
        
        % Pick out basepoint and PHIeta
        % pick side of (xx,yy) PHIat's closer to PHIe original basepoint
        dists = sqrt((xx([1 end]) - bp(1)).^2 + (yy([1 end]) - bp(2)).^2);
        if dists(1) < dists(2)
            xx1 = xx(1); xxe = xx(end);
            yy1 = yy(1); yye = yy(end);
        else
            xx1 = xx(end); xxe = xx(1);
            yy1 = yy(end); yye = yy(1);
        end
        
        TH = atan2(yye-yy1,xxe-xx1).*(180/pi);
        
    end
end
