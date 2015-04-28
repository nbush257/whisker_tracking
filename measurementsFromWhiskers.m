cPath = 'D:\data\2015_08\analyzed\C2_top\';
d = dir( [cPath '*.whiskers']);
for ii=1:length(d)
    
    genMeasure = [cPath d(ii).name(1:end-17) '_noClass.measurements'];    
    whiskerMeasureName = [cPath d(ii).name(1:end-17) '_whiskers.measurements'];
    manipMeasureName = [cPath d(ii).name(1:end-17) '_manip.measurements'];
    
    system(['measure --face ' num2str(ceil(bp(1))) ' ' num2str(ceil(bp(2))) ' v ' cPath d(ii).name ' ' genMeasure]);
    system(['classify ' genMeasure ' ' whiskerMeasureName ' ' num2str(ceil(bp(1))) ' ' num2str(ceil(bp(2))) ' v --px2mm .04 -n 1 --follicle ' num2str(bp(1))]);
    system(['reclassify -n 1 ' whiskerMeasureName ' ' whiskerMeasureName]);
    system(['classify ' genMeasure ' ' manipMeasureName ' right --px2mm .04 -n 1 --follicle ' num2str(ceil(bp(1))+10)]);
    system(['reclassify -n 1 ' manipMeasureName ' ' manipMeasureName ]);
end
 
