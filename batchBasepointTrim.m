% the purpose of this script is to merge a top and a front file as well as
% do the initial basepoint trimming
dT = dir('*Top*.mat')
dF= dir('*Front*.mat')
dTim = dir('*Top*.tiff')
dFim= dir('*Front*.tiff')


for ii = 1:length(dT)
    load(dT(ii).name)
    outfilename = [dT(ii).name(1:27) '_toMerge'];
    
    tW = allWhisker;
    twM = allWMeasure;
    
    clear all*
    load(dF(ii).name)
    
    fW = allWhisker;
    fwM = allWMeasure;
    
    clear all*
    It = imread(dTim(ii).name);
    If = imread(dFim(ii).name);
    
    
    tws = BP_lineMatch(tW,It);
    fws = BP_lineMatch(fW,If);
    save(outfilename,'tws','fws','twM','fwM');
end
    