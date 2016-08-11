function plot_azPL_multisense_summary_group(expdir)


cd(expdir)
load('multisense_summary_data.mat')

pairs(1).name = 'refVIZ_dark';
pairs(1).idx = [1 2];

pairs(2).name = 'refVIZ_light'
pairs(2).idx = [3 4];

pairs(3).name = 'refVIZ_static';
pairs(3).idx = [5 6];

pairs(4).name = 'refVIZ_OL';
pairs(4).idx = [7 8];

pairs(5).name = 'refVIZ_CL';
pairs(5).idx = [9 10];

pairs(6).name = 'testVIZ_dark';
pairs(6).idx = [11 16];

pairs(7).name = 'testVIZ_light';
pairs(7).idx = [12 17];

pairs(8).name = 'testVIZ_static';
pairs(8).idx = [13 18];

pairs(9).name = 'testVIZ_dark';
pairs(9).idx = [14 19];

pairs(10).name = 'testVIZ_dark';
pairs(10).idx = [15 20];


load('auto_roi_data.mat')
roi_struct = roi_auto_struct;

close all

cMap = [0 0 0;...
         1 0 0];

for pair_num = 1:length(pairs);
    for c_roi = 1:length(roi_struct);

    f1 = figure('units', 'normalized',...
        'position', [0.0099 0.1333 0.2974 0.7676], 'color', 'w', ...
        'visible', 'off');
    
    % subplot 1: image of ROI
    s1 = subplot(3,1,1);
    imagesc(roi_struct(c_roi).present_map)
    axis equal off tight
    colormap(gray)
    
    c_xy = roi_struct(c_roi).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);
    
    pair_name = pairs(pair_num).name;
    split_text = strsplit(pair_name, '_');
    condition_type = split_text{2};
    
    text(70, 6, condition_type, 'FontSize', 15, 'color', 'k')
    
    % subplot 2: traces
    s2 = subplot(3,1,2); 
 
    plot([-10000 10000], [0, 0], 'k')
    for ii = 1:length(pairs(pair_num).idx)
        
        c_idx = pairs(pair_num).idx(ii);
        x_vals = summary_stim(c_idx).rois(c_roi).i_tstamp;
        mean_y_val = summary_stim(c_idx).rois(c_roi).mean_dF;
        
        mean_y_val = mean_y_val-mean(mean_y_val(10:100));
        sem_y_val = std(summary_stim(c_idx).rois(c_roi).dFs, [], 2) /sqrt(size(summary_stim(c_idx).rois(c_roi).dFs, 2));
        
        hold on
        confplot(x_vals, mean_y_val, sem_y_val, sem_y_val, cMap(ii,:))
                
    
    end
    xlim([.1 50])
    ylim([-.1 .6])
    box off
    
    set(gca, 'XTick', [10 20 30 40], 'XTickLabel', {},...
                'YTick', [0 .25 .5], 'YTickLabel', {'0', '25' ,'50'} , 'FontSize', 20)
    ylabel('%dF/F', 'Fontsize', 30)
    
    %subplot 3: stim
    s3 = subplot(3,1,3);
    final_condition = length(pairs(pair_num).idx);
    c_collection_idx = pairs(pair_num).idx(final_condition);
    
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
    plot(b_xval, therm_yval,'r--', 'linewidth', 2)
 
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
    
    fig_name = ['pairwise_summary_ROI_' num2str(c_roi, '%03d'),...
                    '_group_' pairs(pair_num).name];
                
     cd(expdir)
     mkdir('plots')
     cd('plots')
     prettyprint(f1, fig_name)
     close all
     cd(expdir)
     
    end
end

end
     