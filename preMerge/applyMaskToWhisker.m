function wStructOut = applyMaskToWhisker(wStruct,mask)

wStructOut = wStruct;
fprintf('\nApplying mask...')
for ii = 1:length(wStruct)
    if mod(ii,10000)==0
        fprintf('Frame %i\n',ii)
    end
    
    if ~isempty(wStruct(ii).x)
        pt = true(length(wStruct(ii).x),1);
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

                