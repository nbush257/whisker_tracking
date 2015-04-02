%data_QA
lastwarn('none')

%% Whisker
nanWskr = [];
diffBP = [];
for ii = 1:length(tracked_3D)
    x = tracked_3D(ii).x;
    y = tracked_3D(ii).y;
    z = tracked_3D(ii).z;
    
%     if any([x(1) y(1) z(1)]-BP(ii,:)>2)% check to see if basepoint is off by more than 2 pixels
%         difference = num2str(sum([x(1) y(1) z(1)]-BP(ii,:)));
%         warning(['BP is different than the first node by ' difference 'at frame ' num2str(ii)])
%         diffBP = [diffBP ii];
%     end
    
    if any(isnan(x)) | any(isnan(y)) | any(isnan(z))
        warning('NaNs found in the whisker. Fix them')
        nanWskr = [nanWskr ii];
    end
    
    xw3d{ii,1} = x;
    yw3d{ii,1} = y;
    zw3d{ii,1} = z;
    clear x y z;
end

%% C
if ~islogical(C)
    error('C is not a logical')
end

if ~isvector(C)
    error('C is not a vector')
elseif ~iscolumn(C)
    C = C';
end
  
if length(C)~=length(tracked_3D)
    warning('C is not the same length as the number of frames. Check the dimensions of C');
end
if any(any(isnan(C)))
    error('NaNs found in C')
end


%% CP
if size(CP,2)~=3
    if size(CP,1) == 3 & size(CP,2)==length(tracked_3D)
        CP =CP';
        warning('Transposed CP.')
    else
        error('Problem with the size of CP.')
    end
elseif size(CP,2) == 3 & size(CP,1)~=length(tracked_3D)
    error('Length of CP is Incorrect. May need to alter')
end

%% TH
% 
% if size(TH,2)~=1
%     if size(TH,1) == 1 & size(TH,2)==length(tracked_3D)
%         TH =TH';
%         warning('Transposed TH.')
%     else
%         error('Problem with the size of TH.')
%     end
% elseif size(TH,2) == 1 & size(TH,1)~=length(tracked3D)
%     error('Length of TH is Incorrect. May need to alter')
% end
% if any(any(isnan(TH)))
%     error('NaNs found in TH')
% end




%% BP
% 
% if any(any(isnan(BP)))
%     error('NaNs found in BP');
% end
% 
% if size(BP,2)~=3
%     if size(BP,1) == 3 & size(BP,2)==length(tracked_3D)
%         BP =BP';
%         warning('Transposed BP.')
%     else
%         error('Problem with the size of BP.')
%     end
% elseif size(BP,2) == 3 & size(BP,1)~=length(tracked_3D)
%     error('Length of BP is Incorrect. May need to alter')
% end



if strcmp(lastwarn,'none')
    fprintf('Congratulations!! \nYour data is acceptable to E3D. Go grab a beer. \n')
end


    

%% PHI


