X = X_smooth;

win = 1000;
label_percent =0.15;

% init C and labelled
C = false(size(X_smooth,1),1);
labelled = false(size(C));

clips = [1:win:length(C)];
rand_idx = randperm(length(clips));
clips_rand = clips(rand_idx);
figure;
count = 1;
while sum(labelled)./length(C)<label_percent
    x = 0;
    starts = clips_rand(count);
    stops = starts+win;
    while ~isempty(x)
            clf
            plot(X(starts:stops,:));
            shadeVector(C(starts:stops));
            title_string = sprintf('Frames: %i  to  %i',starts,stops);
            title(title_string)
            
            % get user inputs
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x = floor(x);
            x = x+starts;
            if isempty(x)
                continue
            end
            
            % If left click, add the region to contact. If right click,
            % remove the region from contact
            if but ==1
                C(x(1):x(2)) = 1;
            elseif but==3
                C(x(1):x(2)) = 0;
            end
    end
        count = count+1;
        labelled(starts:stops) = true;
end
C_out = C;