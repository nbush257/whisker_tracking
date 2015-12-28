function whisk2merge_v2()
frontVidName = '';
topVidName = '';
frontTracked = '.mat'
topTracked = '.mat'
%% load in data
error('This is code is being refactored')
% Nick Bush 2015_11_23
% load front data
load(frontTracked)
fw = w;
fwM = wM;
fm = m;
fmM = mM;
clear w wM m mM
% load top data
load(topTracked)
tw = w;
twM = wM;
tm = m;
tmM = mM;
clear m w mM wM
%% Trim to the basepoint
tw = trackBP(tVidName,tw);
fw = trackBP(fVidName,fw);
%% Smooth basepoint
fw = cleanBP(fw);
tw = cleanBP(tw);

%% Smooth whisker shape
tw = smooth2D_whisker(tw);
fw = smooth2D_whisker(fw);

%% view to verify the basepoint tracking

sample = randi(length(tw),length(tw),1);
for ii = 1:800
    subplot(121)
    if isempty(fw(sample(ii)).x) ||  isempty(tw(sample(ii)).x)
        continue
    end
    
    plot(fw(sample(ii)).x,fw(sample(ii)).y,'k')
    ho
    plot(fw(sample(ii)).x(1),fw(sample(ii)).y(1),'r*')
    
    subplot(122)
    plot(tw(sample(ii)).x,tw(sample(ii)).y,'k')
    ho
    plot(tw(sample(ii)).x(1),tw(sample(ii)).y(1),'r*')
end
%% Get contact 
