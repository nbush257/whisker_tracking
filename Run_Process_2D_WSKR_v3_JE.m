%% Run_Process_2D_WSKR_v3.m
% -------------------------------------------------------------------------
% (xs,ys) - spline-fit whisker
% C - Contact binary
% CP - (x,y) coordinate of contact point estimate
% BP - (x,y) coordinate of base-point estimate
% TH - angle estimate of whisker base
% THw_head - whisker angle in RatMap coordinates 
%   -> (computed separately from TH for elastica2D)
% -------------------------------------------------------------------------
% Brian Quist
% July 23, 2012
disp('Run_Process_2D_WSKR ...');
TGL_plot = 1;
TGL_plotsteps = 0;

%% Load data
% cd(PT.save);
% eval(['load VG_DATA_WSKR_T',PT.TAG,'.mat']);

%% Load front camera whisker points
% JAE addition 140416

% cd(PT.save);
% load summary_PT_shifted_0_4300
% xw={};
% yw={};
% warning('off','all')
% for ii = 1:length(summary_PT)
%     pfit = polyfit(summary_PT{ii}.Axc,summary_PT{ii}.Ayc,3);
%     if summary_PT{ii}.Axc(1) > summary_PT{ii}.Axc(end)
%         xw{length(xw)+1} = [summary_PT{ii}.Axc(end):summary_PT{ii}.Axc(1)]';
%     else
%         xw{length(xw)+1} = [summary_PT{ii}.Axc(1):summary_PT{ii}.Axc(end)]';
%     end
%     yw{length(yw)+1} = polyval(pfit,xw{end});
% 
% end
% warning('on')

%% Buffer
% C = false(length(xw),1);
% CP = NaN(length(xw),2);
BP = NaN(length(xw),2);
BPxy = NaN(length(xw),2);
BPxz = NaN(length(xw),2);
TH = NaN(length(xw),1);
PHI = NaN(length(xw),1);

%% Process_FitSpline
% disp('Process: Fit Spline');
% [xs,ys] = Process_FitSpline_v2(xw,yw,PT,TGL_plotsteps);
% [xs,zs] = Process_FitSpline_v2(xw,zw,PT,TGL_plotsteps);
xs = xw; ys = yw; zs = zw;

% if isempty(xs{1})
%     disp('empty xs')
% end

%% Contact Point / Contact Binary
% disp('Process: CP, C');
% [C,CP] = Process_CP_C_v4(xs,ys,C,CP,PT,TGL_plot);

%% Compute BP and TH
disp('Process: BP, TH');
[BPxy,TH,TH_raw] = Process_BP_TH_v5_JE(C,xw,xs,yw,ys,PT,BP, ...
    TH,TGL_plotsteps,TGL_plot);
disp('Process: BP, PHI');
[BPxz,PHI,PHI_raw] = Process_BP_PHI_v5_JE(C,xw,xs,zw,zs,PT,BP, ...
    PHI,TGL_plotsteps,TGL_plot);

%% Save
disp('Saving.');
cd(PT.save);
eval(['save Vg_DATA_PROC_T',PT.TAG ...
    ,' xs ys ', ...
    'C CP ', ...
    'BPxy TH TH_raw']);
eval(['save Vg_DATA_PROC_PHI',PT.TAG ...
    ,' xs zs ', ...
    'C CP ', ...
    'BPxz PHI PHI_raw']); 