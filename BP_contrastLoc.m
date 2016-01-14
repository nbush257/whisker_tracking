vidFile = 'L:\avis\2015_28\rat2015_28_SEP_16_VG_D0_t01_Top_F020001F040000.avi';
wT = ;

v= VideoReader(vidFile);
tic;
for ii = 1:v.NumberOfFrames
    cla
xIdx = round(wT(ii).x+1);
yIdx = round(wT(ii).y+1);
I = rgb2gray(read(v,ii));
d = diag(I(yIdx,xIdx));
dsz = zscore(smoothts(double(d'),'g',length(diag(d)),10));
dsz = abs(dsz);
imshow(I)
hold on
plot(xIdx,yIdx,'.')
idx = find(abs(dsz)<2,1,'first');
xIdx2 = xIdx(idx:end);
yIdx2 = yIdx(idx:end);

% plot(xIdx2,yIdx2,'o')


end
toc

