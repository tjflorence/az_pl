expdir = \\reiser_nas\tj\az_pl\processed\20160823105538_11f03_az_PL
%{
    
    plots processed(response versus position) open-loop 
    mapping of ROI responses

%}

cd(expdir);
load('auto_roi_data.mat')
roi_struct = roi_auto_struct;

ol_a = dir('OL_A*');
ol_b = dir('OL_B*');

n_idx = [22 28; 46 52];
s_idx = [28 34; 52 58];
e_idx = [34 40; 58 64];
w_idx = [40 46; 64 70];

 c_roi = 4

    load(ol_a.name)

    whitebg('w'); close all;

   %% commented out is just a sanity check to make sure i'm actually pulling out the response kernels 
  
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

    n_resp_a = mean([n_resp_1'; n_resp_2']);
    e_resp_a = mean([e_resp_1'; e_resp_2']);
    s_resp_a = mean([s_resp_1'; s_resp_2']);
    w_resp_a = mean([w_resp_1'; w_resp_2']);

        load(ol_b.name)

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

    n_resp_b = mean([n_resp_1'; n_resp_2']);
    e_resp_b = mean([e_resp_1'; e_resp_2']);
    s_resp_b = mean([s_resp_1'; s_resp_2']);
    w_resp_b = mean([w_resp_1'; w_resp_2']);

    close all
    hold on
    %plot(w_resp_1, 'g')
    %plot(w_resp_2, 'g')
    plot(mean([w_resp_1'; w_resp_2']), 'g', 'linewidth', 2)

    %plot(e_resp_2, 'r')
    %plot(e_resp_1, 'r')
    plot(mean([e_resp_1; e_resp_2]), 'r', 'linewidth', 2)

    %plot(n_resp_2, 'k')
    %plot(n_resp_1, 'k')
    plot(mean([n_resp_1; n_resp_2]), 'k', 'linewidth', 2)

    %plot(s_resp_2, 'b')
    %plot(s_resp_1, 'b')
    plot(mean([s_resp_1; s_resp_2]), 'b', 'linewidth', 2)

%% here extract response as a fcn of position



 %% create plot   
    f1 = figure('color', 'w', 'units', 'normalized', ...
                    'Position', [0.1025    0.4568    0.4892    0.4531], ...
                    'visible', 'off');

    s1 = subplot(3,2,1:2);
        imagesc(max(expr.c_trial.idata.mcorr_MIP,[], 3));
        colormap(gray)
        axis equal off tight


        hold on

        c_xy = roi_struct(c_roi).xy;

        hold on

        scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
        set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);

        text(-100, 11, 'pre-experiment', 'fontsize', 20, 'color', 'k')
        text(-100, 25, 'post-experiment', 'fontsize', 20, 'color', 'r')

    s2 = subplot(3,2,3:4);

        e1 = errorbar([1:8]-.1, mean_ang_resp_a, std_ang_resp_a, std_ang_resp_a, 'k');
        hold on

        sp1 = scatter([1:8]-.1, mean_ang_resp_a, 100, 'k');
        set(sp1, 'MarkerEdgeColor', 'k', 'markerfacecolor', 'none')

        hold on
        e2 = errorbar(1:8, mean_ang_resp_b, std_ang_resp_b, std_ang_resp_b, 'r');
        sp2 = scatter(1:8, mean_ang_resp_b, 100, 'r');
        set(sp2, 'MarkerEdgeColor', 'r', 'markerfacecolor', 'none')

        axis tight
        box off

       set(gca, 'Xcolor', 'w', 'Fontsize', 20)
       ylabel('dF/F', 'Fontsize', 30)

    s3 = subplot(3,2,5:6);

        bars = fliplr(repmat([zeros(32, 8) ones(32, 8)], [1 2]));
        stripes = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
        diag = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
        for ii = 2:32

            diag(:,ii) = circshift(diag(:,ii), [ii-1 0]);

        end

        boxes = [zeros(4,4) ones(4,4);ones(4,4) zeros(4,4)];
        boxes = repmat(boxes, [4 4]);

        sbd = [stripes bars diag];

    % sbd = [stripes bars diag];
        sbd = circshift(sbd, [0 -16]);
        sbd_r = flipud(fliplr(sbd));

        gcMap = [[0 0 0];...
                 [0 1 0]];

        imagesc(sbd_r);
        colormap(s3, gcMap)

        axis equal off tight
        box off

        s1_p = get(s1, 'Position');
        set(s1, 'Position', [s1_p(1)+.25 s1_p(2:4)])

        s2_p = get(s2, 'Position');
        set(s2, 'Position', [s2_p(1)+.05 s2_p(2:4)])

        s3_p = get(s3, 'Position');
        set(s3, 'Position', [s3_p(1)+.05 s3_p(2:4)])

%% cd and print
    mkdir('plots')
    cd('plots')
    
    fig_name = ['OL_simple_map_processed_ROI_' num2str(c_roi, '%03d')];
    prettyprint(f1, fig_name)
    
    close all
    cd(expdir)
        

