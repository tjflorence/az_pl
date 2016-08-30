function plot_azPL_test_az_tuning(expdir)
%{

    plots angular tuning of calcium spikes

%}

cd(expdir);
load('auto_roi_data.mat')

test_trials = dir('*test*');

load(test_trials(1).name)

%expr.c_trial.bdata = expr.c_trial.data;

pre_th_vals = expr.c_trial.bdata.th(expr.c_trial.idata.img_frame_id(1:end-10));
pre_b2i_frames = expr.c_trial.bdata.c_iframe(251:end);
pre_i2b_frames = expr.c_trial.idata.img_frame_id;
pre_roi_data = expr.c_trial.idata.auto_roi_traces;

load(test_trials(2).name)

%expr.c_trial.bdata = expr.c_trial.data;

post_th_vals = expr.c_trial.bdata.th(expr.c_trial.idata.img_frame_id(1:end-10));
post_b2i_frames = expr.c_trial.bdata.c_iframe(251:end);
post_i2b_frames = expr.c_trial.idata.img_frame_id;
post_roi_data = expr.c_trial.idata.auto_roi_traces;

for c_roi = 1:length(roi_auto_struct);

    c_pre_trace     = pre_roi_data(c_roi, :);
    c_post_trace    = post_roi_data(c_roi, :);

    % calc framerate
    c_hz = 1/nanmean(diff(expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-5))));

    %% calc vals for pre peakfinding
    pre_mean = nanmean(c_pre_trace);
    pre_std = .75*nanstd(c_pre_trace);
    pre_thresh = pre_mean+pre_std;

    [pre_val, pre_loc] = findpeaks(medfilt1(c_pre_trace, 3), 'minpeakheight', pre_thresh, 'minpeakdistance', .5*c_hz);

    %% calc vals for pre peakfinding
    post_mean = nanmean(c_post_trace);
    post_std = .75*nanstd(c_post_trace);
    post_thresh = post_mean+post_std;

    [post_val, post_loc] = findpeaks(medfilt1(c_post_trace, 3), 'minpeakheight', post_thresh, 'minpeakdistance', .5*c_hz);


    pre_xvals = nan(length(pre_loc), 1);
    pre_yvals = nan(length(pre_loc), 1);

    pre_loc = pre_loc(find(pre_loc<length(pre_th_vals)));
    for ii = 1:length(pre_loc)

            c_peak_dF   = c_pre_trace(pre_loc(ii));
            c_th        = pre_th_vals(pre_loc(ii));


        pre_xvals(ii) =  c_peak_dF*cosd(c_th);
        pre_yvals(ii) =  c_peak_dF*sind(c_th);

    end

    pre_mean = circ_mean(deg2rad(pre_th_vals(pre_loc)), c_pre_trace(pre_loc)');
    pre_r = circ_r(deg2rad(pre_th_vals(pre_loc)), c_pre_trace(pre_loc)');

    pre_mean_x = pre_r*cos(pre_mean);
    pre_mean_y = pre_r*sin(pre_mean);

    post_xvals = nan(length(post_loc), 1);
    post_yvals = nan(length(post_loc), 1);

    post_loc = post_loc(find(post_loc<length(post_th_vals)));
    for ii = 1:length(post_loc)

        c_peak_dF = c_post_trace(post_loc(ii));
        c_th        = post_th_vals(post_loc(ii));

        post_xvals(ii) =  c_peak_dF*cosd(c_th);
        post_yvals(ii) =  c_peak_dF*sind(c_th);

    end

    post_mean = circ_mean(deg2rad(post_th_vals(post_loc)), c_post_trace(post_loc)');
    post_r = circ_r(deg2rad(post_th_vals(post_loc)), c_post_trace(post_loc)');

    post_mean_x = post_r*cos(post_mean);
    post_mean_y = post_r*sin(post_mean);

    f1 = figure('color', 'w', 'visible', 'off');

    for ii = 1:8

        plot([0 pre_xvals(ii,1)], [0 -pre_yvals(ii,1)], 'b')
            hold on

        scatter(pre_xvals(ii,1), -pre_yvals(ii,1), 'b')
        hold on


    end
    xlim([-1 1])
    ylim([-1 1])

    plot([0 pre_mean_x], [0 -pre_mean_y], 'b', 'linewidth', 2)
    s1_p = scatter(pre_mean_x, -pre_mean_y, 'b', 'linewidth', 2);
    set(s1_p, 'MarkerFaceColor', 'b')

    for ii = 1:8

        hold on

        plot([0 post_xvals(ii)], [0 -post_yvals(ii)], 'r')

        scatter(post_xvals(ii), -post_yvals(ii), 'r')
        hold on



    end
    xlim([-1 1])
    ylim([-1 1])

    plot([0 post_mean_x], [0 -post_mean_y], 'r', 'linewidth', 2)
    s2_p = scatter(post_mean_x, -post_mean_y, 'r', 'linewidth', 2);
    set(s2_p, 'MarkerFaceColor', 'r')

    [X,Y]=circle([0 0],1,1000);
    plot(X,Y, 'k')

    cool_x = cosd(45);
    cool_y = sind(45);
    plot([0 cool_x], [0 cool_y], 'k--')

    cool_x = cosd(-45);
    cool_y = sind(-45);
    plot([0 cool_x], [0 cool_y], 'k--')

    hold on
    axis equal off tight

    text(-1, 1, 'pre-test spikes', 'color', 'b', 'fontsize', 18)
    text(-1,  .8, 'post-test spikes', 'color', 'r', 'fontsize', 18)

    mkdir('plots')
    cd('plots')

    fig_name = ['az_spike_tuning_ROI_' num2str(c_roi, '%03d')];

    prettyprint(f1, fig_name)

    close all
    cd(expdir)

end
