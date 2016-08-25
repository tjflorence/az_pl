function plot_test_tuning(expdir)

cd(expdir);
load('auto_roi_data.mat')

load('env_test_rep_001.mat')

expr.c_trial.bdata = expr.c_trial.data;

pre_xvals = expr.c_trial.bdata.trial_th;
pre_iframes = expr.c_trial.bdata.c_iframe(251:end);
pre_roi_data = expr.c_trial.idata.auto_roi_traces;

load('env_test_rep_017.mat')

expr.c_trial.bdata = expr.c_trial.data;
post_xvals = expr.c_trial.bdata.trial_th;
post_iframes = expr.c_trial.bdata.c_iframe(251:end);
post_roi_data = expr.c_trial.idata.auto_roi_traces;

img_hz = (1/mean(diff(expr.c_trial.idata.tstamp)));
behavior_hz = expr.settings.hz;

hz_ratio = behavior_hz/img_hz;

div_size = 30;

bin_i = div_size:div_size:360;
bin_n = bin_i-div_size;

bin_c = mean([bin_i;bin_n]);


for c_roi = 1:length(roi_auto_struct);


    pre_y_vals = nan(size(bin_c));
    pre_var = nan(size(bin_c));

    post_y_vals = nan(size(bin_c));
    post_var = nan(size(bin_c));

    for ii = 1:length(bin_i)
   
        c_bin_i = bin_i(ii);
        c_bin_n = bin_n(ii);
    
        pre_c_idx = find(pre_xvals<c_bin_i & pre_xvals>c_bin_n);
        post_c_idx = find(post_xvals<c_bin_i & post_xvals>c_bin_n);
   
        c_pre_roi = pre_roi_data(c_roi, :);
        c_post_roi = post_roi_data(c_roi, :);
    
        pre_y_vals(ii) = mean(c_pre_roi(pre_iframes(pre_c_idx)));
        post_y_vals(ii) = mean(c_post_roi(post_iframes(post_c_idx)));
    
        pre_var(ii) = nanstd(c_pre_roi(pre_iframes(pre_c_idx)))/sqrt(numel(pre_c_idx)/hz_ratio);    
        post_var(ii) = nanstd(c_post_roi(post_iframes(post_c_idx)))/sqrt(numel(post_c_idx)/hz_ratio);    
    
    
    end

    post_var
    half_xvec = length(bin_c)/2;

    pre_y_vals = circshift(pre_y_vals, [0 half_xvec]);
    post_y_vals = circshift(post_y_vals, [0 half_xvec]);

    pre_lowVal = prctile(pre_y_vals, 10);
    post_lowVal = prctile(post_y_vals, 10);

    pre_var = circshift(pre_var, [0 half_xvec]);
    post_var = circshift(post_var, [0 half_xvec]);

    close all
    f1 = figure('units', 'normalized',...
                'position', [0.0518 0.4162 0.4720 0.4610], ...
                'color', 'w', 'visible', 'off');
            
    confplot(bin_c,pre_y_vals-pre_lowVal,pre_var,pre_var, 'k')
    hold on
    confplot(bin_c,post_y_vals-post_lowVal,post_var,post_var, 'r')

    plot([-1000 1000], [0 0], 'k')
    xlim([0 360])

    box off
    set(gca, 'XTick', [90 180 270], 'XTickLabel', {'-90', '0', '+90'}, ...
        'Fontsize', 30)

    ylabel('mean dF/F', 'FontSize', 35)
    xlabel('orientation', 'Fontsize', 35)

    mkdir('plots')
    cd('plots')
    fname = ['test_tuning_ROI_' num2str(c_roi, '%02d')];

    prettyprint(f1, fname)
    close all

    cd(expdir)

end

end