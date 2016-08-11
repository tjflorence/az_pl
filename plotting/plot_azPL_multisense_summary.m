expdir = '\\reiser_nas\tj\az_pl\processed\20160806152517_11f03_OL_stim';

cd(expdir)
load('multisense_summary_data.mat')

plot_collections(1).name = 'refVIZ_testNOHEAT';
plot_collections(1).conditions = [1 3 5 7 9 ];

plot_collections(2).name = 'refVIZ_testHEAT';
plot_collections(2).conditions = [2 4 6 8 10];

plot_collections(3).name = 'refNOHEAT_testVIZ';
plot_collections(3).conditions = [11 12 13 14 15];

plot_collections(4).name = 'refHEAT_testVIZ';
plot_collections(4).conditions = [16 17 18 19 20];

load('auto_roi_data.mat')
roi_struct = roi_auto_struct;

close all

cMap = [0 0 0;...
         123 50 148;...
         44 123 182;...
         230 97 1;...
        215 25 28 ]./255;

collection_num = 2;
c_roi = 1;

    f1 = figure('units', 'normalized',...
        'position', [0.0099    0.1333    0.2974    0.7676], 'color', 'w', ...
        'visible', 'on');
    
    % subplot 1: image of ROI
    s1 = subplot(3,1,1);
    imagesc(roi_struct(c_roi).present_map)
    axis equal off tight
    colormap(gray)
    
    c_xy = roi_struct(c_roi).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);
    
    text(70, 6, 'dark', 'FontSize', 15, 'color', cMap(1,:))
    text(70, 16, 'light', 'FontSize', 15, 'color', cMap(2,:))
    text(70, 26, 'environment: static', 'FontSize', 15, 'color', cMap(3,:))
    text(70, 36, 'environment: open-loop motion', 'FontSize', 15, 'color', cMap(4,:))
    text(70, 46, 'environment: closed-loop motion', 'FontSize', 15, 'color', cMap(5,:))

    
    % subplot 2: traces
    s2 = subplot(3,1,2); 
 
    plot([-10000 10000], [0, 0], 'k')
    for ii = 1:length(plot_collections(collection_num).conditions)
        
        c_collection_idx = plot_collections(collection_num).conditions(ii);
        x_vals = summary_stim(c_collection_idx).rois(c_roi).i_tstamp;
        y_vals = summary_stim(c_collection_idx).rois(c_roi).mean_dF;
        
        y_vals = y_vals-mean(y_vals(10:100));
        
        hold on
        plot(x_vals, y_vals, 'Color', cMap(ii,:), 'LineWidth', 2)
        
        
    
    end
    xlim([.1 50])
    ylim([-.1 .6])
    box off
    
    set(gca, 'XTick', [10 20 30 40], 'XTickLabel', {},...
                'YTick', [0 .25 .5], 'YTickLabel', {'0', '25' ,'50'} , 'FontSize', 20)
    ylabel('%dF/F', 'Fontsize', 30)
    
    %subplot 3: stim
    s3 = subplot(3,1,3);
    final_condition = length(plot_collections(collection_num).conditions);
    c_collection_idx = plot_collections(collection_num).conditions(final_condition);
    
    b_xval      = summary_stim(c_collection_idx).s_tstamp;
    therm_yval  = summary_stim(c_collection_idx).therm_vec-min(summary_stim(c_collection_idx).therm_vec);
    if max(therm_yval) ~= 0
        therm_yval = therm_yval/max(therm_yval);
    end
    
    hold on
    
    diff_viz_vec = [0 diff(summary_stim(c_collection_idx).viz_vec)];
    if max(diff_viz_vec) ~= 0 
       
        viz_start_idx = find(diff_viz_vec>0, 1, 'first');
        viz_end_idx = find(diff_viz_vec<0, 1, 'first');
        
        start_tstamp    = b_xval(viz_start_idx);
        end_tstamp      = b_xval(viz_end_idx);
        
        z_fill = fill([start_tstamp end_tstamp end_tstamp start_tstamp], ...
                    [0 0 1 1], [.6 .6 .6], 'EdgeColor', 'none');
                
        alpha(z_fill, .5);
        
    end
    plot(b_xval, therm_yval,'color',  'r', 'linewidth', 2)
 
    text(-10, .9, 'heat', 'fontsize', 25, 'color', 'r')
    text(-10, .6, 'visual', 'fontsize', 25, 'color', 'k')
    
    set(gca, 'XTick', [], 'YTick', []);
    xlim([0 50])
    
    s1_p = get(s1, 'Position');
    set(s1, 'Position', [s1_p(1)-.3 s1_p(2:4)]);
    
    s3_p = get(s3, 'Position');
    set(s3, 'Position', [s3_p(1)+.05 s3_p(2)-.1 s3_p(3) s3_p(4)/1.5 ]);
    
    s2_p = get(s2, 'Position');
    set(s2, 'Position', [s2_p(1)+.05 s2_p(2)-.2 s2_p(3) s2_p(4)*2 ]);   
    
    fig_name = ['stimgroup_summary_ROI_' num2str(c_roi, '%03d'),...
                    '_group_' plot_collections(collection_num).name];
                
     cd(expdir)
     mkdir('plots')
     cd('plots')
     prettyprint(f1, fig_name)
     close all
     cd(expdir)
     
     
     