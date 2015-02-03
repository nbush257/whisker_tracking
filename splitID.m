% split ids from whisk
function splitStruct = splitID(wStruct)
numId = max([wStruct.id]);
splitStruct = struct([]);
for ii = 1:numId+1
    count = 0;
    name = ['wStruct_' num2str(ii)];
    for jj = 1:length(wStruct)
        count = count +1;
        if wStruct(ii).id == ii-1
            splitStruct(ii).id(count) = wStruct(ii).id;
            splitStruct(ii).time(count) = wStruct(ii).time;
            splitStruct(ii).x = wStruct(ii).x;
            splitStruct(ii).y= wStruct(ii).y;
            splitStruct(ii).thick = wStruct(ii).thick;
            splitStruct(ii).scores = wStruct(ii).scores;
        end
    end
end
