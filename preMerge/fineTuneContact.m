function [C,start_deflection] = fineTuneContact(tip_scale,C,varargin)
%% function [C,start_deflection] = fineTuneContact(tip_scale,C,[start,on_off,winsize])
%
%
%% varargin handling
narginchk(2,5)
numvargs = length(varargin);
optargs = {1,'on',50;};
optargs(1:numvargs) = varargin;
[start_deflection, on_off, winsize] = optargs{:};
%%

close all

onset = find(diff([0;C])==1);
offset = find(diff([0;C])==-1);
try
    for ii = start_deflection:length(onset)
        if strcmp(on_off,'off')
            break
        end
        cla
        start = onset(ii)-winsize;
        stop = onset(ii)+winsize;
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title_string = sprintf('Onset Deflection %i of %i',ii,length(onset));
        title(title_string);
        [xx,~,but] = ginput(1);
        if isempty(xx) || but==3
            continue
        end
        
        xx = floor(xx);
        if C(start+xx)
            C(onset(ii):xx+start)=0;
        else
            C(xx+start:onset(ii))=1;
        end
        
        
    end
catch
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    start_deflection = ii;
    return
end
%% offsets
try
    for ii = start_deflection:length(offset)
        cla
        start = offset(ii)-winsize;
        stop = offset(ii)+winsize;
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title_string = sprintf('Offset Deflection %i of %i',ii,length(onset));
        title(title_string);
        [xx,~,but] = ginput(1);
        if isempty(xx) || but==3
            continue
        end
        
        xx = floor(xx);
        if C(start+xx)
            C(xx+start:offset(ii))=0;
        else
            C(offset(ii):xx+start)=1;
        end
        
    end
catch
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    start_deflection=ii;
    return
end




