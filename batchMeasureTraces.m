
d = dir('*E3*.whiskers');
bp(1) = 224;
bp(2) = 229;
fol =260;
direction = 'v';
for ii = 1
%     copyfile(d(ii).name,[d(ii).name(1:end-9) '.whiskers'])
    if ii == 1
        
        measurementsFileName = [d(ii).name(1:end-9) '.measurements'];
        measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName)
        system(measureStr)
        
        classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol)
        reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
        
        system(classifyStr)
        system(reclassifyStr)
    end
end
pause(10)
parfor ii = 2:length(d)
    measurementsFileName = [d(ii).name(1:end-9) '.measurements'];
    measureStr = sprintf('measure --face %i %i %s %s %s',bp(1),bp(2),direction,d(ii).name,measurementsFileName)
    system(measureStr)
    
    classifyStr = sprintf('classify %s %s %i %i %s --px2mm .04 --follicle %i -n 1',measurementsFileName,measurementsFileName,bp(1),bp(2),direction,fol)
    reclassifyStr = sprintf('reclassify %s %s -n 1',measurementsFileName,measurementsFileName);
    
    system(classifyStr)
    system(reclassifyStr)
    
end