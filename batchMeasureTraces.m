d = dir('*.whiskers');
bp(1) = 550;
bp(2) = 400;
fol = 350;
for ii = 1:length(d)
    
    measurementsFileName = [d(ii).name(1:end-9) '_whisker.measurements'];
    measureStr = sprintf('measure --face %i %i h %s %s',bp(1),bp(2),d(ii).name,measurementsFileName)
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i h --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),fol)
    reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
    
    system(classifyStr)
    system(reclassifyStr)
    
end
