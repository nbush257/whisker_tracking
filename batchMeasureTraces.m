
d = dir('*.whiskers');
bp(1) = 90;
bp(2) = 332;
fol =122;
direction = 'v';
for ii = 1:length(d)
    copyfile(d(ii).name,[d(ii).name(1:end-9) '_whisker.whiskers'])
    if ii == 1
        
        measurementsFileName = [d(ii).name(1:end-9) '_whisker.measurements'];
        measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName)
        system(measureStr)
        
        classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol)
        reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
        
        system(classifyStr)
        system(reclassifyStr)
    end
end
parfor ii = 2:length(d)
    measurementsFileName = [d(ii).name(1:end-9) '_whisker.measurements'];
    measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName)
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol)
    reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
    
    system(classifyStr)
    system(reclassifyStr)
    
end