function trackClips(avi_path)
%% function trackClips(avi_path)
% takes all the avis in a path and traces them. This function is taken from
% the seqProcessor in an effort to better chunk the code
%       INPUTS: avi_path - location of all the avis. The .whiskers will be
%       saved in the same location as avi_path in order to easily load in
%       to the WHISK GUI
% NEB 2017_01_23
%%
whisker_path = avi_path;

avis = dir([avi_path '\*F*F*.avi']);
if track_TGL
    cd(avi_path)
    ii=1;% initialize with the first whisker file so default.parameters file can be written

    whiskers_name = [whisker_path '\' avis(ii).name(1:end-4) '.whiskers'];
    fprintf('tracing whiskers on %s',whiskers_name)
    system(['trace ' avi_path '\' avis(ii).name ' ' whiskers_name ' &']);
    pause(30) % pause is necesarry to allow for the default parameters file to be written
    
    parfor ii = 2:length(avis)
        whiskers_name = [whisker_path '\' avis(ii).name(1:end-4) '.whiskers'];
        fprintf('tracing whiskers on %s',whiskers_name)
        system(['trace ' avi_path '\' avis(ii).name ' ' whiskers_name ]);
    end
end