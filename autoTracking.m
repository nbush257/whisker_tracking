function autoTracking(aviName,varargin)
% takes an avi, traces the whisker, and classifies it. 
%if no bp in
if length(varargin==0)
    v = VideoReader(aviName);
    imshow(read(v,1));
    bp = ginput(1);
    close all
end

% trace every curve
wName = [aviName(1:end-4) '.whiskers'];
mName = [wName(1:end-9) '_noClass.measurements'];
system(['trace ' aviName ' ' wName]);
measureString = ['measure --face ' num2str(bp(1)) ' ' num2str(bp(2)) ' v ' wName ' ' mName];
system(measureString);

% get the whisker
mwName = [wName(1:end-9) '_whisker.measurements']
clString = ['classify ' mName ' ' mwName ' ' num2str(bp(1)) ' ' num2str(bp(2)) ' v --px2mm .04 -n 1 --follicle ' num2str(bp(1)+5)];
system(clString);
system(['reclassify ' mwName ' ' mwName ' -n 1']);

% get the manipulator
mmName  = [wName(1:end-9) '_manip.measurements'];
clManipString = ['classify ' mName ' ' mmName ' right --px2mm .04 -n 1 --follicle ' num2str(bp(1)+10)]; 
system(clManipString);
system(['reclassify ' mmName ' ' mmName ' -n 1']);
