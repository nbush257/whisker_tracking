d = dir('L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\tempManip\*top*.mat');
allClipManipOut = struct([]);
for i = 1:length(d)
    load(['L:\raw\2015_06\rat2105_06_0226_FEB26_vg_B2\tempManip\' d(i).name])
    clipManipOut = extendManip(clipManipOut);
    for j = 1:length(clipManipOut)
        if isempty(clipManipOut(j).x);
            continue
        else
            allClipManipOut(j).x=clipManipOut(j).x;
            allClipManipOut(j).y=clipManipOut(j).y;
            allClipManipOut(j).time=clipManipOut(j).time;
        end
    end
end
