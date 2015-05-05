d = dir('*noClass*.whiskers');
bp(1) = 56;
bp(2) = 293;
fol = bp(1)+7;
for ii = 1:length(d)
    
    measurementsFileName = [d(ii).name(1:end-17) '_whisker.measurements'];
    measureStr = sprintf('measure --face %i %i v %s %s',bp(1),bp(2),d(ii).name,measurementsFileName)
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i v --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),fol)
    reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
    
    system(classifyStr)
    system(reclassifyStr)
    
end
