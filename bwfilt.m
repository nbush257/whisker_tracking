function d = bwfilt(v,rate,fo,f1,varargin)
% function d = bwfilt(v,rate,fo,f1,varargin)
% Using same input structure as bpfft, applies the butterworth filter to
% the columns of data in matrix v.
% Default order of filter is 1, can be changed
% filter implementation is filtfilt function from MATLAB
%
% inputs:
%   v - Matrix of data, one signal per column
%   rate - sample rate of data
%   fo - lower bound of band pass filter - if fo <= 0 the filter will be
%   changed to a low-pass filter
%   f1 - upper bound of band pass filter - if f1 >= 1/2*sample rate the
%   filter will be changed to a high-pass filter
%   varargin - if a scalar is entered here, it will change the order of the
%   butterworth filter (default is 1); if the string 'stop' is entered, it
%   will become a bandstop filter
%
% outputs:
%   d - the filtered data from v
%
% Lucie Huet
% Oct. 22, 2014

% make v a column if a vector
if size(v,1)==1, v=v'; end

% Make default values
bmode = 'bandpass';
border = 1;

for ii = 1:length(varargin)
    if isnumeric(varargin{ii}), border = varargin{ii}; end
    if ischar(varargin{ii}), bmode = varargin{ii}; end
end

% make correct rates and check for low or high pass filter
ffo = fo/(rate/2);
ff1 = f1/(rate/2);
Wn = [ffo ff1];
if ffo <= 0,
    Wn = Wn(2);
    bmode = 'low';
elseif ff1 >= 1
    Wn = Wn(1);
    bmode = 'high';
end

% make filter
[filtz,filtp] = butter(border,Wn,bmode);

d = nan(size(v));
for ii = 1:size(v,2)
    d(:,ii) = filtfilt(filtz,filtp,v(:,ii));
end