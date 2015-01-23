function whiskerData = smoothBasepoints(whiskerData,useX,sampleRate,lowCut,highCut)

if nargin < 3
    sampleRate = 250;
end

if nargin < 4
    lowCut = 0;
end

if nargin < 5
    highCut = 15;
end

if useX
   % for x-dimension, just take the mean. 
   xBasepoints = [whiskerData.xBase];
%    xBaseMean = nanmean(xBasepoints);
   xBasepointsSmoothed = bwfilt(double(xBasepoints(:)),sampleRate,lowCut,highCut);
   
   % for y-dimension, lpf with bfft
   yBasepoints = [whiskerData.yBase]; 
   %yBasepointsSmoothed = bpfft(yBasepoints,sampleRate,lowCut,highCut);
   yBasepointsSmoothed = bwfilt(double(yBasepoints(:)),sampleRate,lowCut,highCut);
      
   for count = 1:length(whiskerData)
       
       whiskerData(count).xBaseSmoothed = xBasepointsSmoothed(count);
       whiskerData(count).yBaseSmoothed = yBasepointsSmoothed(count);
       
   end
   
else
    
   % for y-dimension, just take the mean. 
   yBasepoints = [whiskerData.yBase];
   yBaseMean = nanmean(yBasepoints);
   
   % for x-dimension, lpf with bfft
   xBasepoints = [whiskerData.xBase]; 
   %xBasepointsSmoothed = bpfft(xBasepoints,sampleRate,lowCut,highCut);
   xBasepointsSmoothed = bwfilt(double(xBasepoints(:)),sampleRate,lowCut,highCut);
   
   for count = 1:length(whiskerData)
       
       whiskerData(count).xBaseSmoothed = xBasepointsSmoothed(count);
       whiskerData(count).yBaseSmoothed = yBaseMean;
       
   end
    
    
end


end % EOF

%{ 
if useX
    % for x-dimension, just take the mean.
    xBasepoints = [whiskerData.xBase];
    xBaseMean = nanmean(xBasepoints);
    
    % for y-dimension, lpf with bfft
    yBasepoints = nan(1,whiskerData(end).time+1);
    
    indexes = [whiskerData.time] + 1;
    
    yBasepoints(indexes) = [whiskerData.yBase];
    
    smoothedYBasepoints = bpfft(yBasepoints,sampleRate,lowCut,highCut);
    
    for count = 1:numel(whiskerData)
        
        thisFrameIndex = whiskerData(count).time + 1; % +1 for matlab indexing
        
        yBasepointsSmoothed(count) = smoothedYBasepoints(thisFrameIndex);
        
    end
    
    for count = 1:length(whiskerData)
        
        whiskerData(count).xBaseSmoothed = xBaseMean;
        whiskerData(count).yBaseSmoothed = yBasepointsSmoothed(count);
        
    end
    
else
    
    % for y-dimension, just take the mean.
    yBasepoints = [whiskerData.yBase];
    yBaseMean = nanmean(yBasepoints);
    
    % for x-dimension, lpf with bfft
    xBasepoints = nan(1,whiskerData(end).time)+1;
    
    indexes = [whiskerData.time] + 1;
    
    xBasepoints(indexes) = [whiskerData.xBase];
    
    smoothedxBasepoints = bpfft(xBasepoints,sampleRate,lowCut,highCut);
    
    for count = 1:numel(whiskerData)
        
        thisFrameIndex = whiskerData(count).time + 1; % +1 for matlab indexing
        
        xBasepointsSmoothed(count) = smoothedxBasepoints(thisFrameIndex);
        
    end
    
    for count = 1:length(whiskerData)
        
        whiskerData(count).xBaseSmoothed = xBasepointsSmoothed(count);
        whiskerData(count).yBaseSmoothed = yBaseMean;
        
    end
    
    
end


end
%}
