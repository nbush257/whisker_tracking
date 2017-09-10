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

C(1:300) = 0; % contact before 300 frames is absurd
%%

close all
figure;
subplot(3,1,1:2);
subplot(313);
onset = find(diff([0;C])==1);
offset = find(diff([0;C])==-1);
try
    for ii = start_deflection:length(onset)
        if strcmp(on_off,'off')
            break
        end
        subplot(3,1,1:2);
        cla
        start = onset(ii)-winsize;
        stop = onset(ii)+winsize;
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title_string = sprintf('Onset Deflection %i of %i',ii,length(onset));
        title(title_string);
        [xx,~,but] = ginput(1);
        if isempty(xx) || but==3
            subplot(313);
            cla
            plot(tip_scale(start:stop,:))
            shadeVector(C(start:stop))
            title('Previous Contact')
            continue
        end
        
        xx = floor(xx);
        if C(start+xx-1)
            C(onset(ii):xx+start-1)=0;
        else
            C(xx+start-1:onset(ii))=1;
        end
        subplot(313);
        cla
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title('Previous Contact')
        
    end
catch except
    disp(except)
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    start_deflection = ii;
    return
end
%% offsets
try
    for ii = start_deflection:length(offset)
        subplot(3,1,1:2);
        
        cla
        start = offset(ii)-winsize;
        stop = offset(ii)+winsize;
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title_string = sprintf('Offset Deflection %i of %i',ii,length(onset));
        title(title_string);
        [xx,~,but] = ginput(1);
        if isempty(xx) || but==3
            subplot(313);
            cla
            plot(tip_scale(start:stop,:))
            shadeVector(C(start:stop))
            title('Previous Contact')
            continue
        end
        
        xx = floor(xx);
        if C(start+xx)
            C(xx+start:offset(ii))=0;
        else
            C(offset(ii):xx+start)=1;
        end
        subplot(313);
        cla
        plot(tip_scale(start:stop,:))
        shadeVector(C(start:stop))
        title('Previous Contact')
    end
catch
    fprintf(repmat('=',20,1))
    fprintf('\nFunction errored out. Returning C variable\n')
    start_deflection=ii;
    return
end




