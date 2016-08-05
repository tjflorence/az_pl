expdir = '/Volumes/Untitled/2016-06-21/20160621151111_41b12_az_PL';
cd(expdir)

train_files = dir('*train*');
figure

trace_num = 4;

acor_l_mat = [];
acor_b_mat = [];

close all

for ii = 1:length(train_files)
    
    load(train_files(ii).name)
    if isfield(expr.c_trial, 'idata')
    c_trace = expr.c_trial.idata.roi_traces(trace_num,:);
    trace_bdata_res = c_trace(expr.c_trial.bdata.c_iframe);
    trace_bdata_res = trace_bdata_res(501:end);

    
    light_power = expr.c_trial.bdata.laser_power(501:expr.c_trial.bdata.count)+5;
    ball_movement = expr.c_trial.bdata.sm_trial_vsum;

  %  norm_trace_bdata_res = ()./()
    norm_light_power = (light_power-min(light_power))./(max(light_power)-min(light_power));
    norm_ball_movement = (ball_movement-min(ball_movement))./(max(ball_movement)-min(ball_movement));

    [acor_l, lag_l] = xcorr(norm_light_power, trace_bdata_res, [2000]);
    [acor_b, lag_b] = xcorr(norm_ball_movement, trace_bdata_res, [2000]);
    
    acor_l_mat = [acor_l_mat; acor_l'];
    acor_b_mat = [acor_b_mat; acor_b'];
    
    hold on
    plot(lag_l, acor_l, 'r')
    plot(lag_b, acor_b, 'b')
    hold on
    end
end

mean_acor_l = mean(acor_l_mat);
mean_acor_b = mean(acor_b_mat);

plot(lag_l, mean_acor_l, 'r', 'linewidth', 5);
plot(lag_l, mean_acor_b, 'b', 'linewidth', 5);
