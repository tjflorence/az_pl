expdir = '/Volumes/sab_x/2016-08-18/20160818205601_11f03_az_PL';

cd(expdir);

ol_a = dir('OL_A*');
ol_b = dir('OL_B*');

n_idx = [22 28; 46 52];
s_idx = [28 34; 52 58];
e_idx = [34 40; 58 64];
w_idx = [40 46; 64 70];

c_roi = 4;

load(ol_a.name)

whitebg('w'); close all;

f1 = figure('units', 'normalized', 'position', [0.0292 0.0629 0.4744 0.8305], ...
                'color', 'w');
            
load(ol_a.name)

bcount = expr.c_trial.bdata.count;
s1 = subplot(3,1,1);

c_xpos = mod(expr.c_trial.bdata.xpos(1:bcount)+49, 96);
c_xpos(c_xpos==0) = nan;

plot(expr.c_trial.bdata.timestamp(1:bcount), c_xpos);
xlim([0 70])


s2 = subplot(3,1,2);
itstamps = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));

n_range_1 = find(itstamps>n_idx(1,1) & itstamps<(n_idx(1,2)));
n_range_2 = find(itstamps>n_idx(2,1) & itstamps<(n_idx(2,2)));

n_resp_1 = expr.c_trial.idata.auto_roi_traces(c_roi, n_range_1);
n_resp_2 = expr.c_trial.idata.auto_roi_traces(c_roi, n_range_2);

s_range_1 = find(itstamps>s_idx(1,1) & itstamps<(s_idx(1,2)));
s_range_2 = find(itstamps>s_idx(2,1) & itstamps<(s_idx(2,2)));

s_resp_1 = expr.c_trial.idata.auto_roi_traces(c_roi, s_range_1);
s_resp_2 = expr.c_trial.idata.auto_roi_traces(c_roi, s_range_2);

e_range_1 = find(itstamps>e_idx(1,1) & itstamps<(e_idx(1,2)));
e_range_2 = find(itstamps>e_idx(2,1) & itstamps<(e_idx(2,2)));

e_resp_1 = expr.c_trial.idata.auto_roi_traces(c_roi, e_range_1);
e_resp_2 = expr.c_trial.idata.auto_roi_traces(c_roi, e_range_2);

w_range_1 = find(itstamps>w_idx(1,1) & itstamps<(w_idx(1,2)));
w_range_2 = find(itstamps>w_idx(2,1) & itstamps<(w_idx(2,2)));

w_resp_1 = expr.c_trial.idata.auto_roi_traces(c_roi, w_range_1);
w_resp_2 = expr.c_trial.idata.auto_roi_traces(c_roi, w_range_2);


close all
hold on
%plot(w_resp_1, 'g')
%plot(w_resp_2, 'g')
plot(mean([w_resp_1; w_resp_2]), 'g', 'linewidth', 2)

%plot(e_resp_2, 'r')
%plot(e_resp_1, 'r')
plot(mean([e_resp_1; e_resp_2]), 'r', 'linewidth', 2)

%plot(n_resp_2, 'k')
%plot(n_resp_1, 'k')
plot(mean([n_resp_1; n_resp_2]), 'k', 'linewidth', 2)

%plot(s_resp_2, 'b')
%plot(s_resp_1, 'b')
plot(mean([s_resp_1; s_resp_2]), 'b', 'linewidth', 2)

i_xpos_frames = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
i_xpos_frames(1:100) = nan;            
            
load(ol_a.name)

i_xpos_frames = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
i_xpos_frames(1:100) = nan;

mean_ang_resp_a = nan(1,8);
std_ang_resp_a = nan(1,8);

resp_1 = find(i_xpos_frames > 90 | i_xpos_frames<6);
resp_1 = resp_1+5;
mean_ang_resp_a(1) = nanmean(expr.c_trial.idata.auto_roi_traces(c_roi, resp_1));
std_ang_resp_a(1) = nanstd(expr.c_trial.idata.auto_roi_traces(c_roi, resp_1));

ang_vals = [6 18 30 42 54 66 78 90];
for ii = 2:8

    resp_dF = find(i_xpos_frames > ang_vals(ii-1) & i_xpos_frames<ang_vals(ii));
    resp_dF = resp_dF+5;
    mean_ang_resp_a(ii) = nanmean(expr.c_trial.idata.auto_roi_traces(c_roi, resp_dF));
    std_ang_resp_a(ii) = nanstd(expr.c_trial.idata.auto_roi_traces(c_roi, resp_dF));
   
end

load(ol_b.name)

i_xpos_frames = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
i_xpos_frames(1:100) = nan;

mean_ang_resp_b = nan(1,8);
std_ang_resp_b = nan(1,8);

resp_1 = find(i_xpos_frames > 90 | i_xpos_frames<6);
resp_1 = resp_1+5;
mean_ang_resp_b(1) = nanmean(expr.c_trial.idata.auto_roi_traces(c_roi, resp_1));
std_ang_resp_b(1) = nanstd(expr.c_trial.idata.auto_roi_traces(c_roi, resp_1));

ang_vals = [6 18 30 42 54 66 78 90];
for ii = 2:8

    resp_dF = find(i_xpos_frames > ang_vals(ii-1) & i_xpos_frames<ang_vals(ii))
    resp_dF = resp_dF+5;
    mean_ang_resp_b(1,ii) = nanmean(expr.c_trial.idata.auto_roi_traces(c_roi, resp_dF));
    std_ang_resp_b(1,ii) = nanstd(expr.c_trial.idata.auto_roi_traces(c_roi, resp_dF));
   
end

figure
e1 = errorbar([1:8]-.1, mean_ang_resp_a, std_ang_resp_a, std_ang_resp_a, 'k')
hold on

sp1 = scatter([1:8]-.1, mean_ang_resp_a, 100, 'k');
set(sp1, 'MarkerEdgeColor', 'k', 'markerfacecolor', 'none')

hold on
e2 = errorbar(1:8, mean_ang_resp_b, std_ang_resp_b, std_ang_resp_b, 'r')
sp2 = scatter(1:8, mean_ang_resp_b, 100, 'r');
set(sp2, 'MarkerEdgeColor', 'r', 'markerfacecolor', 'none')




