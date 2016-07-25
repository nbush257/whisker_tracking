function wStructOut = applyMaskToWhisker(I,wStruct)
figure
title('apply mask where you want to remove tracked points')
pause(.4)
mask = roipoly(I);
close all
pause(.1)

wStructOut = wStruct;
parfor ii = 1:length(wStruct)
    if mod(ii,1000)==0
        fprintf('\nApplying mask to Frame %i',ii)
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

                