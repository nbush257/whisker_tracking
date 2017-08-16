function tip = getTip(varargin)
%% function getTip(fname)
% This function gets the tip from the whisker either in 2 2D planes, or in
% 3D. Designed to either work by appending the tip to an input file, or by
% saving to workspace if the whisker is in the workspace as a struct
%
% If using two input structs, assumes front is first!!
%
%
%% Input handling
if length(varargin) == 1 
    if isstr(varargin{1}) & exist(varargin{1},'file')
        mode = 'file_append';
        fname = varargin{1};
    elseif isstruct(varargin{1}) & isfield(varargin{1},'z')
        mode = '3D_workspace';
        t3d = varargin{1};
    else
        error('Single input expected to either be a 3D whisker struct or a filename')
    end
    
elseif length(varargin) == 2
    if isstruct(varargin{1}) & isstruct(varargin{2})
        mode = '2D_workspace';
        fw = varargin{1};
        tw = varargin{2};
    else
        error('Two inputs expected to be two 2D whisker structs')
    end
else
    error('expected 1 or 2 inputs')
    
end

%%
switch mode
    case 'file_append' % If the input was one filename, find the tip in 2D and 
        load(fname)
        tip = LOCAL_getTip(fws,tws); % assumes you are only running the filename version if you want both views of a 2D tip. This is the designed purpose of the function
        save(fname,'tip','-append');
    case '3D_workspace'
        tip = LOCAL_getTip(t3d);
    case '2D_workspace'
        tip = LOCAL_getTip(fw,tw);
end
end

function tip = LOCAL_getTip(varargin)
%% function LOCAL_getTip(varargin)
% takes the different cases and extracts the last point on the whisker

if nargin==2 % 2-2D case
    fw = varargin{1};
    tw = varargin{2};
    assert(length(fw)==length(tw),'Two whisker structs are not the same length');
    
    tip = nan(length(fw),4);
    
    % loop over every frame
    for ii = 1:length(fw)
        % skip any nan whiskers
        if isempty(fw(ii).x) || isempty(tw(ii).x)
            continue
        end
        tip(ii,:) = [fw(ii).x(end) fw(ii).y(end) tw(ii).x(end) tw(ii).y(end)];
    end
    
elseif nargin==1 % 3D case
    t3d = varargin{1};
    tip = nan(length(t3d),3);
    
    % loop over every frame
    for ii = 1:length(t3d)
        % skip any nan whiskers
        if isempty(t3d(ii).x) || length(t3d(ii).x)<=2
            continue
        end
        tip(ii,:) = [t3d(ii).x(end) t3d(ii).y(end) t3d(ii).z(end)];
    end
else
    error('Wrong number of inputs to Local function LOCAL_getTip. What did you do??')
end

end



