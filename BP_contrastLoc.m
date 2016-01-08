vidFile = 'D:\data\2015_09\tracking\rat2015_09_APR_23_VG_C1_t01_Top_F020001F040000.avi';
wT = ;

v= VideoRreader(vidFile);
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
idx = find(abs(dsz)<1.5,1,'first');
xIdx2 = xIdx(idx:end);
yIdx2 = yIdx(idx:end);

plot(xIdx2,yIdx2,'o')
pause(.1)

end

