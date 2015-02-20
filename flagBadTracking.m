% flag poorly tracked frames
% assumes the first 100 frames are very well tracked. Uses these frames to
% calculate the approximate whisker size

function problemFrames = flagBadTracking(dotWhiskersfname,thresh)
problemFrames = [];

if nargin~=2
    thresh = 2;
end


w = LoadWhiskers(dotWhiskersfname);
times = [w.time];
if sum([w.id])~=0;
    warning('Multiple Whiskers tracked in the video!')
end

l=[];
for i = 1:length(w)
    l(i) = length(w(i).x);
end

m = mean(l(1:100));
s = std(l(1:100));
d = diff(l);
sd = std(d);
% % 
tooBig = times(l>(m+thresh*s));
tooSmall = times(l<(m-thresh*s));
% 
% tooBig = times(d>(thresh*sd));
% tooSmall = times(d<-thresh*sd);

% 
problemFrames = sort([tooBig tooSmall]);
% problemFrames = times(abs()>thresh*sd);


end %EOF




