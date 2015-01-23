
for ii = 1:13
flnm=['141120_rat1446_E1_top_block',num2str(ii),'.whiskers'];
eval(['wskr_tp_',num2str(ii),'=LoadWhiskers(''',flnm,''');']);
disp(ii);end
for ii = 1:13
flnm=['141120_rat1446_E1_front_block',num2str(ii),'.whiskers'];
eval(['wskr_fr_',num2str(ii),'=LoadWhiskers(''',flnm,''');']);
disp(ii);end

for ii = 1:13
flnm=['141120_rat1446_E1_top_manip_block',num2str(ii),'.whiskers'];
eval(['wskr_tp_manip_',num2str(ii),'=LoadWhiskers(''',flnm,''');']);
disp(ii);end

% for ii = 10:13
% flnm=['141120_rat1446_delta_front_block',num2str(ii),'.whiskers'];
% eval(['wskr_fr_',num2str(ii),'=LoadWhiskers(''',flnm,''');']);
% disp(ii);end
% 
all_top=struct([]);
all_front=struct([]);
top_manip=struct([]);

for ii = 1:13
new_start = (ii-1)*10000;
data=eval(['wskr_tp_',num2str(ii)]);
for kk = 1:length(data)
this_ent = length(all_top)+1;
all_top(this_ent).x = data(kk).x;
all_top(this_ent).y = data(kk).y;
all_top(this_ent).time = data(kk).time+new_start;
end
end
for ii = 1:13
new_start = (ii-1)*10000;
data=eval(['wskr_fr_',num2str(ii)]);
for kk = 1:length(data)
this_ent = length(all_front)+1;
all_front(this_ent).x = data(kk).x;
all_front(this_ent).y = data(kk).y;
all_front(this_ent).time = data(kk).time+new_start;
end
end

for ii = 1:13
new_start = (ii-1)*10000;
data=eval(['wskr_tp_manip_',num2str(ii)]);
for kk = 1:length(data)
this_ent = length(top_manip)+1;
top_manip(this_ent).x = data(kk).x;
top_manip(this_ent).y = data(kk).y;
top_manip(this_ent).time = data(kk).time+new_start;
end
end
