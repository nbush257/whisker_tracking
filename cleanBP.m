function wStructOut = cleanBP(wStruct);
BP = nan(length(wStruct),2);
for ii = 1:length(wStruct)
    if isempty(wStruct(ii))
        continue
    else
        BP(ii,:) = [wStruct(ii).x(1) wStruct(ii).y(1)];
    end
end
        
BPf1 = medfilt1(BP);
BPf2(:,1) = deleteoutliers(BPf1(:,1),.0001,1);
BPf2(:,2) = deleteoutliers(BPf1(:,2),.0001,1);



