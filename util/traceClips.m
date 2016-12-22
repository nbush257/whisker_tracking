function TAGu = traceClips(aviPath)

avis = dir([aviPath '\*F*F*.avi']);
aviNames = {avis.name};
TAGidx = regexp(aviNames,'_F\d{6}F\d{6}');
TAG = {};
for ii = 1:length(aviNames)
    TAG{ii} = aviNames{ii}(1:TAGidx{ii}-1);
end
[TAGu,first] = unique(TAG);

cd(aviPath)
%% Track
ii=1;% initialize with the first whisker file

wName = [aviPath '\' avis(ii).name(1:end-4) '.whiskers'];
fprintf('tracing whiskers on %s',wName)
system(['trace ' aviPath '\' avis(ii).name ' ' wName ' &']);
pause(30)
parfor ii = 2:length(avis)
    wName = [aviPath '\' avis(ii).name(1:end-4) '.whiskers'];
    fprintf('tracing whiskers on %s',wName)
    system(['trace ' aviPath '\' avis(ii).name ' ' wName ]);
end
