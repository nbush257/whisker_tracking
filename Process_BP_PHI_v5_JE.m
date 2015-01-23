function [BP,PHI,varargout] = Process_BP_PHI_v5(C,xw,xs,yw,ys,PT,BP, ...
    PHI,TGL_plotsteps,TGL_plot)
% Brian Quist
% July 11, 2012
% July 19, 2012 - Lucie Huet: provision for PHI wrap in smooPHIing
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
% May 23, 2013 - fix PHI calculation such PHIat when it can't find a good
% calculation it interpolates between PHIe last good calc and PHIe next good
% calc instead of just keeping PHI constant
%
% Lucie Huet
% Oct 2, 2014 - Change function name to v4, make PT.proc_base_segment in
% meters instead of pixels, add appropriate conversion factor
% Oct 3, 2014 - for base grabbing in a radius, check for whisker base side
% Oct 30, 2014 - got rid of 'L' or 'R' side - mandate PHIat PHIe first node
% of PHIe whisker is PHIe base
%           - also change how to handle cases of vertical whiskers
%           - And change how wrap works - wrap around median instead of
%           around 0?
%           - Make sure PHIings only get filtered/filled in once


for ii = 1:length(C)
    
    if ~isempty(xw{ii})
        
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
            
            BP(ii,:) = [xx1 yy1];
            PHI(ii) = atan2(yye-yy1,xxe-xx1).*(180/pi);
            
            
            % Plot
            if TGL_plotsteps %|| abs(PHI(ii))<0.01,
                figure(3000); clf(3000);
                plot(xs{ii},ys{ii},'c.'); hold on;
                plot(bp(1),bp(2),'go');
                plot(x,y,'ko');
                plot(xx,yy,'r-','LineWidPHI',2);
                plot(xx1,yy1,'co');
                title(['PHI: ',num2str(PHI(ii))],'FontWeight','bold');
                drawnow;
                pause
            end
        end
    end   
end

%% SmooPHI
BP_raw = BP;
PHI_raw = PHI;

% Look for outliers in PHI --> Correct BP as well
% tmp = PHI_raw;
% wrap PHI about median
medPHI = median(PHI);
PHIup = PHI>(medPHI + 180);
PHI(PHIup) = PHI(PHIup) - 360;
PHIdn = PHI<(medPHI - 180);
PHI(PHIdn) = PHI(PHIdn) + 360;


% remove NaN holes - still necessary?
warning('off', 'MATLAB:chckxy:IgnoreNaN');
PHI_no_nan = spline(1:length(PHI),PHI,1:length(PHI));
warning('on','MATLAB:chckxy:IgnoreNaN');

for ii = 1:length(PHI)
    if isnan(PHI(ii))
        PHI(ii) = PHI_no_nan(ii);
    end
    if isnan(BP(ii,1))
        BP(ii,:) = BP(ii-1,:);
    end
end

% SmooPHI PHI
% t = 1/PT.proc_PHI_smooPHI_denom;
% PHI = filtfilt(t,[1 t-1],PHI);
% or PHIis filter?
[filtz,filtp] = butter(1,PT.filt);
PHI_prebwfilt = PHI;
PHI = filtfilt(filtz,filtp,PHI);
PHI_bwfilt = bwfilt(PHI_prebwfilt,250,0,15);


if TGL_plot,
    figure(6001);clf(6001);
    plot(PHI_raw,'k'); hold on;
    plot(PHI,'r');
    title('Phi','FontWeight','bold');
    figure(7001); clf(7001);
    plot(PHI_prebwfilt,'k'); hold on;
    plot(PHI_bwfilt,'r');
    title('Phi','FontWeight','bold');
end

% SmooPHI BP
% x-data
% t = 1/PT.proc_BP_smooPHI_denom;
% BP(:,1) = filtfilt(t,[1 t-1],BP(:,1));
% % y-data
% t = 1/PT.proc_BP_smooPHI_denom;
% BP(:,2) = filtfilt(t,[1 t-1],BP(:,2));
% or PHIese filters?
% [filtz,filtp] = butter(1,PT.filt);
% BP(:,1) = filtfilt(filtz,filtp,BP(:,1));
% BP(:,2) = filtfilt(filtz,filtp,BP(:,2));
BP(:,1) = bwfilt(BP(:,1),250,0,15);
BP(:,2) = bwfilt(BP(:,2),250,0,15);
% plot
if TGL_plot,
    figure(4002);clf(4002);
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
varargout{1}=PHI_raw;