function [idx,CPout] = CPonWhisker(CP,w)
%% function [idx,CPout] = CPonWhisker(CP,w)
% ==============================================
% Takes a 3D CP and makes sure that the CP is exactly on a node of the
% whisker. Particularly helpful if the CP has been smoothed and may no
% longer correspond to a node on the whisker
% INPUTS:
%
% OUTPUTS
% ===============================================
% Nick Bush 2016_04_28
%%
CPout = CP;
idx = nan(length(w),1);
for ii = 1:length(w)
    if any(isnan(CP(ii,:)))
        continue
    end
    if isempty(w(ii).x) || length(w(ii).x)<10
        continue
    end
    d = (CP(ii,1)-w(ii).x).^2+(CP(ii,2)-w(ii).y).^2+(CP(ii,3)-w(ii).z).^2; %calculate the squared distance because we don't actually care how far, just the min.
    [~,idx(ii)] = min(d);
    idx(ii) = round(idx(ii));
    if nargout == 2
        CPout(ii,:) = [w(ii).x(idx(ii)) w(ii).y(idx(ii)) w(ii).z(idx(ii))];
    end
    
end

    