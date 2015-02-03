function final_wstruct = merge_matching_ts(wstruct,useX,basepointSmaller)
%%  function [wstruct] = merge_matching_ts(wstruct)
%   Inputs
%       wstruct:            data from .whiskers file
%       useX:               do we use X-axis to sort the whisker (or y?)
%       basepointSmaller:   on the given axis, is the basepoint smaller
%                          than the tip
%   collapse matching timestamps and add their x-y points together

for ii = 1:length(wstruct)
    wtimes(ii)=wstruct(ii).time;
end

wstruct_norepeats = struct([]);
thrundreds=300:300:length(wstruct);
fixed_repeats = nan(length(wstruct),1);
tenths=round(length(wstruct)/10:length(wstruct)/10:length(wstruct));
for ii = 1:length(wstruct)
    x = wstruct(ii).x;
    y = wstruct(ii).y;
    this_ent = length(wstruct_norepeats)+1;
    if sum(wtimes==wstruct(ii).time)>1 && ~ismember(wstruct(ii).time,fixed_repeats)
        for kk = ii:length(wstruct)
            if wstruct(ii).time == wstruct(kk).time & ii~=kk
                x(length(x)+1:length(x)+length(wstruct(kk).x)) = wstruct(kk).x;
                y(length(y)+1:length(y)+length(wstruct(kk).y)) = wstruct(kk).y;
                fixed_repeats(ii) = wstruct(ii).time;
                wtimes(kk) = nan;
                break
            end
        end
        
        
        [x,y] = sortWhisker(x,y,useX,basepointSmaller);
        wstruct_norepeats(this_ent).x = x;
        wstruct_norepeats(this_ent).y = y;
        wstruct_norepeats(this_ent).time = wstruct(ii).time;
        
    elseif ~ismember(wstruct(ii).time,fixed_repeats)
        [x,y] = sortWhisker(x,y,useX,basepointSmaller);
        wstruct_norepeats(this_ent).x = x;
        wstruct_norepeats(this_ent).y = y;
        wstruct_norepeats(this_ent).time = wstruct(ii).time;
    end
    
    if ismember(ii,thrundreds)
        fprintf('.')
    elseif ismember(ii,tenths)
        fprintf(['\n',num2str(100*ii/length(wstruct)),' percent complete\n'])
    end
    
end


%%   Order struct chronologically
clear wtimes
fprintf('\n\t Ordering chronologically')
for ii = 1:length(wstruct_norepeats)
    wtimes(ii)=wstruct(ii).time;
end

[corr_order,indicies] = sort(wtimes);
thrundreds=300:300:length(wstruct_norepeats);
tenths=round(length(wstruct_norepeats)/10:length(wstruct_norepeats)/10:length(wstruct_norepeats));
for ii = 1:length(wstruct_norepeats);
    final_wstruct(ii) = wstruct_norepeats(indicies(ii));
     if ismember(ii,thrundreds)
        fprintf('.')
    elseif ismember(ii,tenths)
        fprintf(['\n',num2str(100*ii/length(wstruct)),' percent complete\n'])
    end
end

fprintf(['\n\n\tRemoved/combined ',num2str(length(wstruct)-length(wstruct_norepeats)),' repeated frames\n\n'])
