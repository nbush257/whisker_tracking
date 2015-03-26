function [CP3D,wstruct_3D,needToExtend] = get3DCP(wstruct,mstruct,contact,use_x,BPsmaller,CP,varargin)
% Finds the contact point and interpolates the 3D whisker


global A_camera B_camera A2B_transform desired_extra_nodes


extended = 0;
replaced = 0;
manipfits = [];
desired_extra_percent = 5; %set to 0 if you don't want to extend
CP3D = nan(length(wstruct),3);
num_interp_nodes = 200;

abs_length_cutoff = 10;

if ~isempty(varargin)
    wstruct_3D = varargin{1};
    A_camera = varargin{2};
    B_camera = varargin{3};
    A2B_transform = varargin{4};
    manip_times = varargin{5};
end



% % interpolate the 3D whisker
% 
% for count = 1:length(wstruct_3D)
%     xi = linspace(min(wstruct_3D(count).x),max(wstruct_3D(count).x),num_interp_nodes);
%     yi = interp1(wstruct_3D(count).x,wstruct_3D(count).y,xi);
%     zi = interp1(wstruct_3D(count).x,wstruct_3D(count).z,xi);
%     wstruct_3D(count).x = xi;
%     wstruct_3D(count).y = yi;
%     wstruct_3D(count).z = zi;
% end
% 
% 



% will need to make sure all indexing is right


needToExtend = [];
iter_length = min(length(CP),length(wstruct_3D));
m = getWaitMessage;
w = waitbar(0,'waiting');
tic;
for ii = 1:iter_length
    waitbar(ii/iter_length,w,m);
    if toc>20
        m = getWaitMessage;
        
        tic;
    end
    
    % short circuit if no contact
    if isnan(CP(ii,1))
        continue
    end
    
    
    [wskr_top,~] = BackProject3D(wstruct_3D(ii),A_camera,B_camera,A2B_transform);
    
    % Immediately replace short whiskers
    % edited by NB 2015_03_23 to look at the 3D length, not the 2D
    % length
    if length(wstruct_3D(ii).x)< abs_length_cutoff
        wstruct_3D(ii).x = wstruct_3D(ii-1).x;
        wstruct_3D(ii).y = wstruct_3D(ii-1).y;
        wstruct_3D(ii).z = wstruct_3D(ii-1).z;
        replaced = replaced + 1;
        [wskr_top,~] = BackProject3D(wstruct_3D(ii),A_camera,B_camera,A2B_transform);
    end
    
    
    T = delaunayn(wskr_top);
    ind = dsearchn(wskr_top,T,CP(ii,:));
    
    
    % Calculate the number of nodes needed beyond the contact point
    desired_extra_nodes = ceil(length(wskr_top(:,1))/desired_extra_percent);
    %             desired_extra_nodes = 6;
    
    if ind >= length(wskr_top(:,1)) - desired_extra_nodes
%         xyfit = polyfit(wstruct_3D(ii).x,wstruct_3D(ii).y,3);
%         xzfit = polyfit(wstruct_3D(ii).x,wstruct_3D(ii).z,3);
%         xshift = 0;
%         yshift = 0;
        %[wstruct_3D(ii),ind] = LOCAL_extend_one_Seg(wstruct_3D(ii),xyfit,xzfit,CP(ii,:),[xshift,yshift],CP_ind(ii),use_x,BPsmaller);
        needToExtend = [needToExtend ii];
        
        extended = extended + 1;
    end
    
    
    
    CP3D(ii,:) = [wstruct_3D(ii).x(ind),wstruct_3D(ii).y(ind),wstruct_3D(ii).z(ind)];
    CP_ind(ii) = ind;
    
    
    % Check real
    if ~isreal(CP(ii))
        fprintf(['\nimaginary component to contact point; frame #',num2str(ii),'\n'])
        CP(ii,:) = CP(ii-1,:);
    end
end

delete(w)
end%EOF

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




