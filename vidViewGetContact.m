vName = 'G:\forJasmine\rat2015_14_JUN04_VG_C2_t01_Top_F040001F060000.avi';
V = VideoReader(vName);
C = logical(zeros(20000,1));
count = 1;
if ~exist('video','var')
    video = read(V,[1 inf]);
end
if ndims(video)==4
    video = squeeze(video(:,:,1,:));
end
figure
nFrames = size(video,3);
for ii = 1:nFrames
    
    
    cla
    imshow(video(:,:,count))
    title('C = contact; Space = +10; A = +100 B = -10; V = -100; X = +1; m = Contact+10')
    xlabel({['Contact = ' num2str(C(count))],['Frame ' num2str(count)]})
    
    [~,~,ui] = ginput(1); % 32 is space, 99 is C,97 is A, 98 is B,118 is V;120 is x 114 is R
    switch ui
        case 32
            count = count+10;
        case 99
            count = count+1;
            C(count) =1;
        case 97
            count = count +100;
        case 98
            count = count-10;
        case 118
            count = count-100;
        case 120 
            count = count +1;
        case 109
            C(count:count+9) = 1;
            count = count+10;
        case 114
            C(count) =0;
            count= count + 1;
    
    end
    
end

