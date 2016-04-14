function wStructOut = applyMaskToWhisker(I,wStruct)
mask = roipoly(I);


BP = nan(length(wStruct),2);
for ii = 1:length(wStruct)
    if ~isempty(wStruct(ii).x)
        BP(ii,:) = [wStruct(ii).x(1) wStruct(ii).y(1)];
    end
end

wStructOut = wStruct;
parfor ii = 1:size(BP,1)
    if mod(ii,1000)==0
        fprintf('\nFrame %i',ii)
    end
    if ~isempty(wStruct(ii).x)
        pt = logical(ones(length(wStruct(ii).x),1));
        a = round([wStruct(ii).x wStruct(ii).y]);
        a(a(:,1)>640,1) = 640;
        a(a(:,2)>480,2) = 480;
        
        a(a(:,1)<=0,1) = 1;
        a(a(:,2)<=0,2) = 1;
        

        for jj = 1:length(wStruct(ii).x)
            if mask(a(jj,2),a(jj,1))
                pt(jj) = 0;
            end
        end
        wStructOut(ii).x = wStructOut(ii).x(pt);
        wStructOut(ii).y = wStructOut(ii).y(pt);
    end
end
                
                