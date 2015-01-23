function [CP,CP3D,CP3Draw,CP_ind,varargout] = calc_CP(wstruct,mstruct,contact,use_x,BPsmaller,varargin)
%%  function CP = calc_CP(wstruct,mstruct)
%   INPUT:
%       wstruct     = whisker struct with var x, y, and time
%       mstrcut     = manipulator struct with var x, y, and time
%       contact           = logical vector of contact
%       use_x       = logical, use the x-axis to sort
%       BPsmaller   = logical, is the basepoint smaller than the tip
%       VARARGINS:
%           1:      3D whisker struct  (x,y,z fields)
%           2:      A_camera
%           3:      B_camera
%           4:      A2Btransform
%           5:      manip_times - vector of times for manipulator tracking
%       VARARGOUTS:
%           1:      extended 3D whisker struct
%           2:      manipulator fits

warning('off')

%% Define Vars
        desired_extra_percent = 15; % percent of whisker to be added
        abs_length_cutoff = 10;
%%

global A_camera B_camera A2B_transform desired_extra_nodes

extended = 0;
replaced = 0;
manipfits = [];

CP3D = nan(length(wstruct),3);
CP = nan(length(wstruct),2);
CP_ind = nan(length(wstruct),1);
lastCP = nan(1,2);
lastCPind = nan;

if ~isempty(varargin)
    wstruct_3D = varargin{1};
    A_camera = varargin{2};
    B_camera = varargin{3};
    A2B_transform = varargin{4};
    manip_times = varargin{5};
end

QQ = input(sprintf('\nShould we get the 3D node position for contact from this whisker?\n\n(y/n) >> '),'s');

SS = input(sprintf('\nDo you want to smooth the final Contact Point positions?\n\n(y/n) >> '),'s');

PP = input(sprintf('\nDo you want to interpolate the final whisker?\n\n(y/n) >> '),'s');

if ismember(PP,['Y','y','yes','Yes','YES',1])
    num_interp_nodes = input(sprintf('\nWhat is the desired final number of nodes?\n\n(num Nodes) >> '));
end

if ismember(SS,['Y','y','yes','Yes','YES',1])
    frequency = input(sprintf('\nAt what frequncy do you want to smooth the final Contact Point positions?\n\n(freq) >> '));
else
    frequency = nan;
end
if ismember(QQ,['Y','y','yes','Yes','YES',1])
    get3DCP = true;
else
    get3DCP = false;
end

for ii = 1:length(wstruct)
    
    %% Only calculate CP for contact frames
    wtime = wstruct(ii).time;
    if contact(ii)==1
        
        % Find matching ts from manipulator struct
        if ~isempty(manip_times)
            mm = find(manip_times == wtime);
        else
            for mm = 1:length(mstruct)
                if mstruct(mm).time == wtime
                    break
                end
            end
        end
        
        fitted_whisker = polyfit(wstruct(ii).x,wstruct(ii).y,2);
        % Create manipulator point cloud
        manipbinsize = 30;
        if mm < manipbinsize
            mbin = 1:mm+manipbinsize;
        elseif mm > length(mstruct) - manipbinsize
            mbin = mm-manipbinsize:length(mstruct);
        else
            mbin = mm-manipbinsize:mm+manipbinsize;
        end
        
        manipcloudx = [];
        manipcloudy = [];
        for cc = 1:length(mbin)
            manipcloudx = [manipcloudx;mstruct(mbin(cc)).x];
            manipcloudy = [manipcloudy;mstruct(mbin(cc)).y];
        end
        
        manip_fit = polyfit(manipcloudx,manipcloudy,1);
        manipfits{ii} = manip_fit;       
        
        A = fitted_whisker(1);
        B = fitted_whisker(2) - manip_fit(1);
        C = fitted_whisker(3) - manip_fit(2);
        
        xquadP = (-B+sqrt(B^2-4*A*C))/(2*A);
        xquadM = (-B-sqrt(B^2-4*A*C))/(2*A);
        cpoints = {[xquadP,polyval(fitted_whisker,xquadP)],[xquadM,polyval(fitted_whisker,xquadM)]};
        
        if BPsmaller == 0 && use_x == 1
            distP = sqrt((xquadP-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadP)-mean(wstruct(ii).y))^2);
            distM = sqrt((xquadM-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadM)-mean(wstruct(ii).y))^2);
            
        elseif BPsmaller == 0 && use_x == 0
            distP = sqrt((xquadP-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadP)-mean(wstruct(ii).y))^2);
            distM = sqrt((xquadM-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadM)-mean(wstruct(ii).y))^2);
        else
            distP = sqrt((xquadP-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadP)-mean(wstruct(ii).y))^2);
            distM = sqrt((xquadM-mean(wstruct(ii).x))^2+(polyval(fitted_whisker,xquadM)-mean(wstruct(ii).y))^2);
            
%             disp('PROBLEM!')
        end
        dists = [distP,distM];
        contact_point = cpoints{dists==min(dists)};
        
        %% get 3D CP and check for tip-contact/short whiskers
               
        CP(ii,:)=contact_point;
        meanCP=mean(CP,1);
        
%         lastCP = CP(ii,:);

         % Only allow small movements of CP
%         if ~isnan(lastCP(1)) && length(CP)>1
%             mydiff = sqrt((CP(ii,1)-meanCP(1))^2+(CP(ii,2)-meanCP(2))^2);
%             if mydiff > .5
%                 CP(ii,:)=CP(ii-1,:);
%             end
%             
%         end
        
        
        
        if get3DCP
            [wskr_top,~] = BackProject3D(wstruct_3D(ii),A_camera,B_camera,A2B_transform);
            
            % Immediately replace short whiskers
            if length(wskr_top(:,1)) < abs_length_cutoff
                wstruct_3D(ii).x = wstruct_3D(ii-1).x;
                wstruct_3D(ii).y = wstruct_3D(ii-1).y;
                wstruct_3D(ii).z = wstruct_3D(ii-1).z;
                replaced = replaced + 1;
                [wskr_top,~] = BackProject3D(wstruct_3D(ii),A_camera,B_camera,A2B_transform);
            end
            
            xshift = wstruct(ii).x(1)-wskr_top(1,1);
            yshift = wstruct(ii).y(1)-wskr_top(1,2);
            
            shifted_wskr_top = [wskr_top(:,1)+xshift,wskr_top(:,2)+yshift];
            
            T = delaunayn(shifted_wskr_top);
            ind = dsearchn(shifted_wskr_top,T,CP(ii,:));
            
            
            % Calculate the number of nodes needed beyond the contact point
            desired_extra_nodes = ceil(length(wskr_top(:,1))/desired_extra_percent);
%             desired_extra_nodes = 6;
            
            if ind >= length(wskr_top(:,1)) - desired_extra_nodes
                
                xyfit = polyfit(wstruct_3D(ii).x,wstruct_3D(ii).y,3);
                xzfit = polyfit(wstruct_3D(ii).x,wstruct_3D(ii).z,3);
                [wstruct_3D(ii),ind] = LOCAL_extend_one_Seg(wstruct_3D(ii),xyfit,xzfit,CP(ii,:),[xshift,yshift],CP_ind(ii),use_x,BPsmaller);
                extended = extended + 1;
               
            end
            
            
            
            CP3D(ii,:) = [wstruct_3D(ii).x(ind),wstruct_3D(ii).y(ind),wstruct_3D(ii).z(ind)];
            CP_ind(ii) = ind;
            
        end % if get3DCP
        
        % Check real
        if ~isreal(CP(ii))
            fprintf(['\nimaginary component to contact point; frame #',num2str(ii),'\n'])
            CP(ii,:) = CP(ii-1,:);
        end
        
    end % if contact()
    
    if ismember(ii,1000:1000:length(wstruct))
        fprintf('\n%d frames complete\n',ii)
    end
    
    
    
% disp(ii)
end % for ii 


%% Smooth Final CP
if ismember(SS,['Y','y','yes','Yes','YES',1])
    
    binwidth = 100;
    stdev_multiplier = 1;
    outliers=[];
    ind_outliers=[];
    
    % Remove outliers
    CP3Dno_outliers = CP3D;
    CPind_no_outliers = CP_ind;
    outliers = zeros(length(CP3D),1);
    for ss = 1:length(CP)
        if contact(ss)==1
            CPbinx = CP3D(max(1,ss-binwidth/2):min(length(CP),ss+binwidth/2),1);
            medianCPx = median(CPbinx);
            stdevCPx = std(CPbinx);
            CPbiny = CP3D(max(1,ss-binwidth/2):min(length(CP),ss+binwidth/2),2);
            medianCPy = median(CPbiny);
            stdevCPy = std(CPbiny);
            CPbinz = CP3D(max(1,ss-binwidth/2):min(length(CP),ss+binwidth/2),3);
            medianCPz = median(CPbinz);
            stdevCPz = std(CPbinz);
            
            if abs(CP3D(ss,1) - medianCPx) > stdevCPx * stdev_multiplier
                CP3Dno_outliers(ss,1) = nan;
                outliers(ss)=1;
            end
            if abs(CP3D(ss,2) - medianCPy) > stdevCPy * stdev_multiplier
                CP3Dno_outliers(ss,2) = medianCPy;
                outliers(ss)=1;
            end
            if abs(CP3D(ss,3) - medianCPz) > stdevCPz * stdev_multiplier
                CP3Dno_outliers(ss,3) = nan;
                outliers(ss)=1;
            end
            
            % Smooth CPind
            CPindbin = CP_ind(max(1,ss-binwidth/2):min(length(CP),ss+binwidth/2),1);
            medianCPind = median(CPindbin);
            stdevCPind = std(CPbinx);
            if abs(medianCPind - CP_ind(ss)) > stdevCPind * stdev_multiplier
                CPind_no_outliers(ss,1) = nan;
                ind_outliers(ss)=1;
            end
    
        end
    end
    
    
    % Smooth CP- x,y, and z
    CP3Dx_spline = spline(1:length(CP3D),CP3Dno_outliers(:,1),1:length(CP3D));
    CP3Dy_spline = spline(1:length(CP3D),CP3Dno_outliers(:,2),1:length(CP3D));
    CP3Dz_spline = spline(1:length(CP3D),CP3Dno_outliers(:,3),1:length(CP3D));
    
    CP3Dx_filt = bwfilt(CP3Dx_spline,250,0,frequency);
    CP3Dy_filt = bwfilt(CP3Dy_spline,250,0,frequency);
    CP3Dz_filt = bwfilt(CP3Dz_spline,250,0,frequency);
    
    CP3Draw = CP3D;
    CP3D = [CP3Dx_filt,CP3Dy_filt,CP3Dz_filt];
    
end % end if SS


%% Interpolate Final Whisker
if ismember(SS,['Y','y','yes','Yes','YES',1])
    
    for count = 1:length(wstruct_3D)
        xi = linspace(min(wstruct_3D(count).x),max(wstruct_3D(count).x),num_interp_nodes);
        yi = interp1(wstruct_3D(count).x,wstruct_3D(count).y,xi);
        zi = interp1(wstruct_3D(count).x,wstruct_3D(count).z,xi);
        wstruct_3D(count).x = xi;
        wstruct_3D(count).y = yi;
        wstruct_3D(count).z = zi;
    end
    
end % end if PP

%% Set variable out
varargout{1} = wstruct_3D;
varargout{2} = manipfits;
varargout{3} = outliers;
varargout{4} = ind_outliers;


%% function [wskr3D,CPind] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,cntc_pt,shift,lastCPind)
    function [wskr3D,CPind] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,cntc_pt,shift,lastCPind,use_x,BPsmaller)
        
        [wskrA,~] = BackProject3D(wskr3D,A_camera,B_camera,A2B_transform);
        
        % shift whisker
        shifted_wskrA = [wskrA(:,1)+shift(1),wskrA(:,2)+shift(2)];
        
        TT = delaunayn(shifted_wskrA);
        CPind = dsearchn(shifted_wskrA,TT,cntc_pt);
        
        if length(wskrA) >= CPind + desired_extra_nodes
            return
            
        else
            nodespacing = median(diff(wskr3D.x));
            if size (wskr3D.x,1) == 1
                wskr3D.x = [wskr3D.x,wskr3D.x(end)+nodespacing];
                wskr3D.y = [wskr3D.y,polyval(whfitA,wskr3D.x(end))];
                wskr3D.z = [wskr3D.z,polyval(whfitB,wskr3D.x(end))];
            else
                wskr3D.x = [wskr3D.x;wskr3D.x(end)+nodespacing];
                wskr3D.y = [wskr3D.y;polyval(whfitA,wskr3D.x(end))];
                wskr3D.z = [wskr3D.z;polyval(whfitB,wskr3D.x(end))];
            end
            [wskr3D,CPind] = LOCAL_extend_one_Seg(wskr3D,whfitA,whfitB,cntc_pt,shift,lastCPind,use_x,BPsmaller);
        end
        
        
    end % function LOCAL_extend_one_Seg


%{
for ii = 400:length(all_tracked_3D)
frontseq.seek(all_tracked_3D(ii).time);
topseq.seek(all_tracked_3D(ii).time);
subplot(1,2,1)
imshow(frontseq.getframe());hold on
xdiff_fr=fr_27479(ii).x(1)-ext_fbackp{ii}(1,1);
ydiff_fr=fr_27479(ii).y(1)-ext_fbackp{ii}(1,2);
plot(ext_fbackp{ii}(:,1)+xdiff_fr,ext_fbackp{ii}(:,2)+ydiff_fr,'.')
if ~isnan(CP(ii))
scatter(ext_fbackp{ii}(CPind(ii),1)+xdiff_fr,ext_fbackp{ii}(CPind(ii),2)+ydiff_fr,'rp')
end
subplot(1,2,2)
imshow(topseq.getframe());hold on
xdifftop=tp_27479(ii).x(1)-ext_tbackp{ii}(1,1);
ydifftop=tp_27479(ii).y(1)-ext_tbackp{ii}(1,2);
plot(ext_tbackp{ii}(:,1)+xdifftop,ext_tbackp{ii}(:,2)+ydifftop,'.')
if ~isnan(CP(ii))
scatter(ext_tbackp{ii}(CPind(ii),1)+xdifftop,ext_tbackp{ii}(CPind(ii),2)+ydifftop,'rp')
scatter(CP(ii,1),CP(ii,2),'gp')
end
pause(0.001)
clf
end
%}



fprintf(['\t\t ** SUMMARY ** \n\nReplaced ', num2str(replaced), ' frames because their length \n\twas less than the absolute threshold (',num2str(abs_length_cutoff),')\n\n...'...
    ,'Extended ',num2str(extended),' whiskers\n\n'])

warning('on')
end

