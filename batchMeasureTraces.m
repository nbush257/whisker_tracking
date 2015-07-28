d = dir('*Gamma*Top*.whiskers');
bp(1) = 186;
bp(2) = 317;
fol = 204;
parfor ii = 1:length(d)
    
    measurementsFileName = [d(ii).name(1:end-9) '_whisker.measurements'];
    measureStr = sprintf('measure --face %i %i v %s %s',bp(1),bp(2),d(ii).name,measurementsFileName)
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i v --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),fol)
    reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
    
    system(classifyStr)
    system(reclassifyStr)
    
end
