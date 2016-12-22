function compressClips(avis)
%% function compressClips(avis)
% avis is the structure that results from the dir function listing all the
% avis to convert.
for ii = 1:length(avis)
    outName  = [avis(ii).name(1:end-4) '_c.avi'];
    ffString = sprintf(['ffmpeg -i ' avis(ii).name ' -c:v  wmv2 -q 2  ' outName]);
    system(ffString)
    delete(avis(ii).name)
end
newAvis = dir('*_c.avi');
for ii = 1:length(newAvis)
    newOutname = newAvis(ii).name([1:end-6 end-3:end]);
    java.io.File(newAvis(ii).name).renameTo(java.io.File(newOutname));
end