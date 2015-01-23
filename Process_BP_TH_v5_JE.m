function [BP,TH,varargout] = Process_BP_TH_v5(C,xw,xs,yw,ys,PT,BP, ...
    TH,TGL_plotsteps,TGL_plot)
% Brian Quist
% July 11, 2012
% July 19, 2012 - Lucie Huet: provision for TH wrap in smoothing
% July 23, 2012 - Brian Quist: Added toggle PT.WskrBaseSide
%
% Chris Schroeder
% August 2, 2012 - changed Line 67 to fix an indexing error
%
% Lucie Huet
% August 30, 2012 - fix for (xw,yw) not containing base point
% Sept 4, 2012 - fix errors from empty (xw,yw) and NaN holes
%
% Chris Schroeder
% May 23, 2013 - fix TH calculation such that when it can't find a good
% calculation it interpolates between the last good calc and the next good
% calc instead of just keeping TH constant
%
% Lucie Huet
% Oct 2, 2014 - Change function name to v4, make PT.proc_base_segment in
% meters instead of pixels, add appropriate conversion factor
% Oct 3, 2014 - for base grabbing in a radius, check for whisker base side
% Oct 30, 2014 - got rid of 'L' or 'R' side - mandate that the first node
% of the whisker is the base
%           - also change how to handle cases of vertical whiskers
%           - And change how wrap works - wrap around median instead of
%           around 0?
%           - Make sure things only get filtered/filled in once


for ii = 1:length(C)
    
    if ~isempty(xw{ii})
        
        if isnan(xw{ii})
            xw{ii}=xw{ii-1};
            yw{ii}=yw{ii-1};
            disp(ii)
        end
        
        baser1 = PT.proc_base_segment(1)/PT.pix2m; % back to pixels
        baser2 = PT.proc_base_segment(2)/PT.pix2m; % back to pixels
        
        % Grab data in a radius
        R = sqrt( (xw{ii} - xs{ii}(1)).^2 + (yw{ii} - ys{ii}(1)).^2);
        good = logical(baser1 < R & R < baser2);
        x = xw{ii}(good);
        y = yw{ii}(good);
        
        if size(x,2)~=1, x = x'; end
        if size(y,2)~=1, y = y'; end
        
        bp = [xs{ii}(1) ys{ii}(1)];
        
        % Grab data on correct side of base
        [~,seg_end] = min(abs(baser2 - sqrt( ...
            (xs{ii} - bp(1)).^2 + (ys{ii} - bp(2)).^2)));
        v = [xs{ii}(seg_end)-bp(1) ys{ii}(seg_end)-bp(2)];
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
            
            % Pick out basepoint and theta
            % pick side of (xx,yy) that's closer to the original basepoint
            dists = sqrt((xx([1 end]) - bp(1)).^2 + (yy([1 end]) - bp(2)).^2);
            if dists(1) < dists(2)
                xx1 = xx(1); xxe = xx(end);
                yy1 = yy(1); yye = yy(end);
            else
                xx1 = xx(end); xxe = xx(1);
                yy1 = yy(end); yye = yy(1);
            end
            
            BP(ii,:) = [xx1 yy1];
            TH(ii) = atan2(yye-yy1,xxe-xx1).*(180/pi);
            
            
            % Plot
            if TGL_plotsteps %|| abs(TH(ii))<0.01,
                figure(3000); clf(3000);
                plot(xs{ii},ys{ii},'c.'); hold on;
                plot(bp(1),bp(2),'go');
                plot(x,y,'ko');
                plot(xx,yy,'r-','LineWidth',2);
                plot(xx1,yy1,'co');
                title(['TH: ',num2str(TH(ii))],'FontWeight','bold');
                drawnow;
                pause
            end
        end
    end   
end

%% Smooth
BP_raw = BP;
TH_raw = TH;

% Look for outliers in TH --> Correct BP as well
% tmp = TH_raw;
% wrap TH about median
medth = median(TH);
thup = TH>(medth + 180);
TH(thup) = TH(thup) - 360;
thdn = TH<(medth - 180);
TH(thdn) = TH(thdn) + 360;


% remove NaN holes - still necessary?
warning('off', 'MATLAB:chckxy:IgnoreNaN');
TH_no_nan = spline(1:length(TH),TH,1:length(TH));
warning('on','MATLAB:chckxy:IgnoreNaN');

for ii = 1:length(TH)
    if isnan(TH(ii))
        TH(ii) = TH_no_nan(ii);
    end
    if isnan(BP(ii,1))
        BP(ii,:) = BP(ii-1,:);
    end
end

% Smooth TH
% t = 1/PT.proc_th_smooth_denom;
% TH = filtfilt(t,[1 t-1],TH);
% or this filter?
[filtz,filtp] = butter(1,PT.filt);
TH_prebwfilt = TH;
TH = filtfilt(filtz,filtp,TH);
TH_bwfilt = bwfilt(TH_prebwfilt,250,0,15);

if TGL_plot,
    figure(3001);clf(3001);
    plot(TH_raw,'k'); hold on;
    plot(TH,'r');
    title('Theta','FontWeight','bold');
    figure(7002); clf(7002);
    plot(TH_prebwfilt,'k'); hold on;
    plot(TH_bwfilt,'r');
    title('Theta','FontWeight','bold');
end

% Smooth BP
% x-data
% t = 1/PT.proc_BP_smooth_denom;
% BP(:,1) = filtfilt(t,[1 t-1],BP(:,1));
% % y-data
% t = 1/PT.proc_BP_smooth_denom;
% BP(:,2) = filtfilt(t,[1 t-1],BP(:,2));
% or these filters?
% [filtz,filtp] = butter(1,PT.filt);
% BP(:,1) = filtfilt(filtz,filtp,BP(:,1));
% BP(:,2) = filtfilt(filtz,filtp,BP(:,2));
BP(:,1) = bwfilt(BP(:,1),250,0,15);
BP(:,2) = bwfilt(BP(:,2),250,0,15);
% plot
if TGL_plot,
    figure(3002);clf(3002);
    subplot(2,1,1);
    plot(BP_raw(:,1),'b'); hold on;
    plot(BP(:,1),'r');
    title('BP x-data','FontWeight','bold');
    subplot(2,1,2);
    plot(BP_raw(:,2),'b'); hold on;
    plot(BP(:,2),'r');
    title('BP y-data','FontWeight','bold');

end

%% JAE Addition 141216
varargout{1}=TH_raw;