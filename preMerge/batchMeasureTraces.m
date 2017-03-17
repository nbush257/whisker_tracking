function batchMeasureTraces(pathspec,bp,fol,direction,n)
%% function batchMeasureTraces(pathspec,bp,fol,direction,n)
bp = round(bp);
fol = round(fol);
d = dir([pathspec '*.whiskers']);
for ii = 1:length(d)
    
%     copyfile(d(ii).name,[d(ii).name(1:end-9) '.whiskers'])
    if ii == 1
        
        measurementsFileName = [d(ii).name(1:end-9) '.measurements'];
        measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName);
        system(measureStr)
        
        classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n %i',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol,n);
        reclassifyStr = sprintf('reclassify %s %s -n %i',measurementsFileName,measurementsFileName,n);

        system(classifyStr);
        system(reclassifyStr);
    end
end
parfor ii = 2:length(d)
    measurementsFileName = [d(ii).name(1:end-9) '.measurements'];
    measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName);
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n %i',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol,n);
    reclassifyStr = sprintf('reclassify %s %s -n %i',measurementsFileName,measurementsFileName,n);
    
    system(classifyStr);
    system(reclassifyStr);
    
end