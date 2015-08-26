function x = LULU(x,n,varargin)
%% function x = LULU(x,n,inString)
% Performs outlier removal via LULU smoothing
% LULU smoothing takes n+1 combinations of n+1 length subwindows of a
% vector, and finds min(max(window)) and max(min(window)). 
% See: https://en.wikipedia.org/wiki/Lulu_smoothing
% ========================================
% INPUTS:
%         x(vector): timeseries to remove outliers from. Only one dimensional vectors
%         are supported
%
%         n(int): window over which to smooth. Large values of N will result in slowdown
%
%         [inString(string)]: Specifies the order and repitions of the L and U smoothings.
%         e.g. 'LUL' performs lower, then upper, then lower smoothing
% OUTPUTS:
%         x(vector): smoothed timeseries
% =========================================

%% input handling
if length(varargin)==1
    inString = varargin{1};
else
    inString = 'LU';
end

if iscolumn(x);x = x';end
if ~rem(n,1) == 0 ; error('n must be an integer value'); end;
if ~ischar(inString); error('inString must be a string');end

%% Main Loop
for ii =1:length(inString) % for each character in inString, either perform L or U smoothing
    switch inString(ii)
        case 'L'
            seq = LOCAL_getSeq(x,n);
            x = LOCAL_L(seq,n);
        case 'U'
            seq = LOCAL_getSeq(x,n);
            x = LOCAL_U(seq,n);
        otherwise
            error('invalid string input')
    end
end



end


%% Local function to get the sub
function seq = LOCAL_getSeq(x,n)
count = 1;
% Shift the data so that we get a 2n+1 x length matrix st there are n+1
% combinations of n+1 sequential rows that contain the middle row

%e.g. (n=1):
% 23456x
% 123456
% x12345


for ii= -n:n
    if ii<0
        seq(count,:) = [x(1-ii:end) nan(1,abs(ii))];
        count = count+1;
        
    elseif ii>0
        seq(count,:) = [nan(1,ii) x(1:end-ii)];
        count = count+1;
    elseif ii==0
        seq(count,:) = x ;
        count = count+1;
    end
    
end
end
%% perform L smoothing: max(min(subsets))
function y = LOCAL_L(seq,n)
for ii = 1:n+1
    mm(ii,:) = min(seq(ii:ii+n,:));
end

y = max(mm);
end

%% perform U smoothing: min(max(subsets))
function y = LOCAL_U(seq,n)
for ii = 1:n+1
    mm(ii,:) = max(seq(ii:ii+n,:));
end

y = min(mm);
end



