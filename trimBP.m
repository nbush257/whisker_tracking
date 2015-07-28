function wStruct = trimBP(wStruct,V)
%% function wStruct = trimBP(wStruct,V)
for ii = 1:length(wStruct)
    if isempty(wStruct(ii).x)
        continue
    end
    if ~exist('lim','var')
        I = read(V,5000);
        imshow(I)
        title('zoom')
        zoom on;pause;
        title('Click on the leftmost limit of the basepoint')
        lim = ginput(1);
        lim = lim(1);
    end
    toRM = wStruct(ii).x<lim;
    wStruct(ii).x(toRM) = [];
    wStruct(ii).y(toRM) = [];
end

