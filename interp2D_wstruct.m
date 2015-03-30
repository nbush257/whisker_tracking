%interp 2D whisker
function [wstruct] = interp2D_wstruct(wstruct,varargin)

%function [wstruct] = interp2D_wstruct(wstruct,varargin)

if ~isempty(varargin)
    N = varargin{1};
end
N = 1000;

parfor ii = 1:length(wstruct)
    
    
    x = wstruct(ii).x;
    y = wstruct(ii).y;
    try
        [x,y,~] = equidist(x,y,N,0);
    end
    
    wstruct(ii).x = x;
    wstruct(ii).y = y;
    
end


