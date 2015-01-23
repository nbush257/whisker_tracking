function [wtstruct_matched,wfstruct_matched] = match_whisker_struct_by_ts(wtstruct,wfstruct)
%%  function [wtstruct,wfstruct] = match_whisker_struct_by_ts(wtstruct,wfstruct)
%

% get times for top/front struct 
for ii = 1:length(wtstruct)
    wt_times(ii) = double(wtstruct(ii).time);
end
for ii = 1:length(wfstruct)
    wf_times(ii) = double(wfstruct(ii).time);
end

%find matches
[matches,top_ind,front_ind] = intersect(wt_times,wf_times);

%create new structs with only matches
wtstruct_matched=struct([]);
wfstruct_matched=struct([]);
for mm = 1:length(matches)
    
    wtstruct_matched(mm).x = double(wtstruct(top_ind(mm)).x);
    wtstruct_matched(mm).y = double(wtstruct(top_ind(mm)).y);
    wtstruct_matched(mm).time = double(wtstruct(top_ind(mm)).time);
    
    wfstruct_matched(mm).x = double(wfstruct(front_ind(mm)).x);
    wfstruct_matched(mm).y = double(wfstruct(front_ind(mm)).y);
    wfstruct_matched(mm).time = double(wfstruct(front_ind(mm)).time);
    
end
    