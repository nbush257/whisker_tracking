function [C,tip] = semisupervisedContact(w,varargin)
%% function [C,tip] = semisupervisedContact(w,varargin)
% ===================================================
% Classifies a frame as either contact or non contact. First asks the user
% to label a small percentage of the data manually, then uses those labels
% to train an SVM. The user then views all the data to ensure that contact
% is good. The SVM fit is updated everytime the user changes the contact
% variable.
%%
% if we don't have a labelled C variable, do some preliminary labelling
if length(varargin)>0
    C_man = varargin{1};
else
    [C_man,tip] = labelContactSample(w);
end


tip_clean = clean3D_tip(w);
bsStim = basisFactory.makeNonlinearRaisedCos(8,1,[0 50],1);
X = basisFactory.convBasis(tip_clean,bsStim);
X = featureScaling(X);
close all
fprintf('training the classifier...\n')
labelled = isfinite(C_man);
svm_obj = svmtrain(X(labelled,:),C_man(labelled),'kernel_function','rbf');
C_svm = svmclassify(svm_obj,X);
fprintf('classifier trained!\n')
C = LOCAL_inspectContact(tip_clean,C_man,C_svm,X);


close all
end



function C_out = LOCAL_inspectContact(tip_clean,C_man,C_svm,X)
C_out = C_man;
tip_clean = featureScaling(tip_clean);
winsize = 1000;
% get first point
longfig;
plot(tip_clean)
zoom on
title('click on first contact frame')
pause

[xInit,~] = ginput(1);
starts = round(xInit);
stops = winsize+starts;

while starts<length(C_svm)
    % x is the ginput x positions. Init to allow for a while loop in a
    % few lines
    x = 0;
    
    % prevent indexing past the length of the trace
    if stops>length(C_svm)
        stops = length(C_svm);
    end
    
    % stay on this window until no inputs.
    no_click = true;
    try
        while ~isempty(x)
            clf
            plot(tip_clean(starts:stops,:),'k.-','linewidth',2);
            shadeVector(C_svm(starts:stops))
            
            % get user inputs
            [x,~,but] = ginput(2);
            x = sort(x);
            x(x<1)=1;
            x = round(x);
            x = x+starts;
            if isempty(x)
                continue
            end
            
            % If left click, add the region to contact. If right click,
            % remove the region from contact
            if but ==1
                C_svm(x(1):x(2)) = 1;
                no_click = false;
            elseif but==3
                C_svm(x(1):x(2)) = 0;
                no_click = false;
            end
        end
        
        C_out(1:stops) = C_svm(1:stops);
        labelled = isfinite(C_out);
        
        if ~no_click
            svm_obj = svmtrain(X(labelled,:),C_out(labelled),'kernel_function','rbf');
            C_svm(stops:end) = svmclassify(svm_obj,X(stops:end,:));
        end
        
        hold off
        % get the next window
        starts = stops;
        stops = starts+winsize;
    catch
        fprintf(repmat('=',20,1))
        fprintf('\nFunction errored out. Returning C variable\n')
        return
    end
end