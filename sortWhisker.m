function [x,y] = sortWhisker(x,y,useX,basepointSmaller)
% function [x,y] = sortWhisker(x,y,useX,basepointSmaller)

if useX
    if basepointSmaller
    [x,indexes] = sort(x(:),1,'ascend');
    else
    [x,indexes] = sort(x(:),1,'descend');    
    end
    y = y(indexes);
else
    if basepointSmaller
    [y,indexes] = sort(y(:),1,'ascend');
    else
    [y,indexes] = sort(y(:),1,'descend');
    end
    x = x(indexes);
end


% JAE 141213
if size(y,1) == 1
    y=y';
end

end % EOF

