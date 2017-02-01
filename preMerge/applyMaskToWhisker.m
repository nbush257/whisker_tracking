function wStructOut = applyMaskToWhisker(wStruct,mask)

wStructOut = wStruct;
fprintf('\nApplying mask...')
width = size(mask,2);
height = size(mask,1);
for ii = 1:length(wStruct)
    if mod(ii,10000)==0
        fprintf('Frame %i\n',ii)
    end
    
    if ~isempty(wStruct(ii).x)
        pt = true(length(wStruct(ii).x),1);
        a = round([wStruct(ii).x wStruct(ii).y]);
        a(a(:,1)>width,1) = width;
        a(a(:,2)>height,2) = height;
        
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

                