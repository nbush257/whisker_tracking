function [ManipOut,ManipOutAllPixels]= clipGetManip(seqObj,initialROI,startFrame,endFrame);
%% want to add functionality that only looks for lines in an angle close to the previous angle of the manipulator.
%frame numbers are referenced to entire video, the first frame indexes at
%1;
N = 10; %size to dilate the ROI
ManipROI = initialROI;


for ii = startFrame+1:endFrame
    seqObj.seek(ii-1);
    FrameN = seqObj.getframe();
    
    
    s = regionprops(ManipROI,'pixellist');
    xvals = min(s.PixelList(:,1)):max(s.PixelList(:,1)); % if this throws an error you can try increasing your ROI dilation.
    yvals = min(s.PixelList(:,2)):max(s.PixelList(:,2));
    xoffset = min(xvals); yoffset = min(yvals);
    FrameN_Manip = FrameN(yvals,xvals);
    
%     foobar = edge(gpuArray(FrameN_Manip),'sobel');
%     foobar = gather(foobar);
    
    foobar = edge(FrameN_Manip,'canny');
    foobar = foobar.*ManipROI(yvals,xvals);
    [h,t,r]=hough(foobar);
    
    
    p = houghpeaks(h,2);
    lines = houghlines(foobar,t,r,p);
    counter = 0;
    
    if length(lines)>1
        l = [];
        for jj =1:length(lines)
            l(jj) = sqrt((lines(jj).point1(1) - lines(jj).point2(1))^2 + (lines(jj).point1(2) - lines(jj).point2(2))^2);
        end
        [~,idx] = max(l);
        lines = lines(idx);
    end
    if ~isempty(lines) % not 100% sure what happens when there is no line
        xm = [lines.point1(:,1) lines.point2(:,1)];
        ym = [lines.point1(:,2) lines.point2(:,2)];
        xm = xm + xoffset - 1;
        ym = ym +yoffset - 1;
        p = polyfit(xm,ym,1);
        
        xmsmooth = (min(xm):.1:max(xm));
        ymsmooth = round(polyval(p,xmsmooth));
        xmsmooth = round(xmsmooth);
        mask = zeros(size(FrameN));
        %%% There must be a better way to do these next three lines
        for k = 1:length(xmsmooth)
            mask(ymsmooth(k),xmsmooth(k)) = 1;
        end;
        
        bw = logical(mask);
        
        se = strel('disk',N);
        bw = imdilate(bw,se);
               
        s = regionprops(mask,'pixellist');
        ManipROI = bw;
        
        xm = s.PixelList(:,1); ym = s.PixelList(:,2);
        ManipOutAllPixels{ii} = [xm';ym'];
        p = polyfit(xm,ym,1);
        xmm = round(min(xm)):.5:round(max(xm));
        ymm = polyval(p,xmm);
        ManipOut{ii} = [xmm;ymm];
        
    else
        ManipOut{ii} = [];
        ManipOutAllPixels{ii} = [];
    end
end














