% append two whisker structs for the same whisker,
function tempStruct = appendWStruct(wstruct_a,wstruct_b)
la = length(wstruct_a);
lb = length(wstruct_b);
l = max([la,lb]);
tempStruct  = struct;
numIda = max([wstruct_a.id]);
numIdb = max([wstruct_b.id]);

numId = max([numIda numIdb]);

maxTime = max([[wstruct_a.time] [wstruct_b.time]]);

hundreds = [1:round(maxTime/10):round(maxTime)];
c=0;
for ii = 0:maxTime-1
    if any(ii==hundreds)
        c = c+10;
        disp([num2str(c) '% done'])
    end
    
    aIdx = find([wstruct_a.time] == ii);
    bIdx = find([wstruct_b.time] == ii);
    
    for jj = 0
        
        aIdxID = find([wstruct_a(aIdx).id] == jj);
        bIdxID = find([wstruct_b(bIdx).id] == jj);
        
        tempX = [wstruct_a(aIdx(aIdxID)).x;wstruct_b(bIdx(bIdxID)).x];
        tempY = [wstruct_a(aIdx(aIdxID)).y;wstruct_b(bIdx(bIdxID)).y];
        tempThick = [wstruct_a(aIdx(aIdxID)).thick;wstruct_b(bIdx(bIdxID)).thick];
        tempScores = [wstruct_a(aIdx(aIdxID)).scores;wstruct_b(bIdx(bIdxID)).scores];
        
        tempStruct(jj+1,ii+1).id = jj;
        tempStruct(jj+1,ii+1).time = ii;
        tempStruct(jj+1,ii+1).x = tempX;
        tempStruct(jj+1,ii+1).y = tempY;
        tempStruct(jj+1,ii+1).thick = tempThick;
        tempStruct(jj+1,ii+1).scores = tempScores;
    end
    
end


% 
% wstruct = wstruct_a;
% clear wstruct_a;
% clear wstruct_b
% fprintf('\n\t Ordering chronologically')
% wtimes = double([wstruct.time]);
% 
% [corr_order,indicies] = sort(wtimes);
% thrundreds=300:300:length(wstruct);
% tenths=round(length(wstruct)/10:length(wstruct)/10:length(wstruct));
% 
% % preallocate final_wstruct
% 
% for ii = 1:length(wstruct);
%     final_wstruct(ii) = wstruct(indicies(ii));
%     if ismember(ii,thrundreds)
%         fprintf('.')
%     elseif ismember(ii,tenths)
%         fprintf(['\n',num2str(100*ii/length(wstruct)),' percent complete\n'])
%     end
% end