% append two whisker structs for the same whisker
function final_wstruct = appendWStruct(wstruct_a,wstruct_b);
la = length(wstruct_a);

for i = 1:length(wstruct_b)
    wstruct_a(la+i) = wstruct_b(i);
end
wstruct = wstruct_a;
clear wstruct_a;
clear wstruct_b
fprintf('\n\t Ordering chronologically')
wtimes = double([wstruct.time]);

[corr_order,indicies] = sort(wtimes);
thrundreds=300:300:length(wstruct);
tenths=round(length(wstruct)/10:length(wstruct)/10:length(wstruct));
for ii = 1:length(wstruct);
    final_wstruct(ii) = wstruct(indicies(ii));
     if ismember(ii,thrundreds)
        fprintf('.')
    elseif ismember(ii,tenths)
        fprintf(['\n',num2str(100*ii/length(wstruct)),' percent complete\n'])
    end
end