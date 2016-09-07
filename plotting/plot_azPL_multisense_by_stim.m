function plot_azPL_multisense_by_stim(expdir, is_auto)

cd(expdir)

load('multisense_summary_data.mat')
if is_auto == 1
    
    load('auto_roi_data.mat')
    roi_struct = roi_auto_struct;

else
    
    load('roi_data.mat')
    load('auto_roi_data.mat')

end
cMap = [zeros(3,1) zeros(3, 1) linspace(0,1,3)'];

whitebg('w')
close all

for c_roi = 1:length(roi_struct);
    for stim_num = 1:length(summary_stim)

        close all
        
    f1 = figure('units', 'normalized',...
        'position', [-0.0208    1.0048    0.3446    0.9171], 'color', 'w', ...
        'visible', 'off');

    % subplot 1: image of ROI
    s1 = subplot(4,1,1);
    imagesc(roi_auto_struct(c_roi).present_map)
    axis equal off tight
    colormap(gray)
    
    c_xy = roi_struct(c_roi).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);
    
    % subplot 2: traces
    s2 = subplot(4,1,2);
    x_data = summary_stim(stim_num).rois(c_roi).i_tstamp;
    raw_dF_data = summary_stim(stim_num).rois(c_roi).dFs;
    
    for ii = 1:size(raw_dF_data, 1);
   
        plot(x_data, raw_dF_data(ii,:)-mean(raw_dF_data(ii,500:1000)), 'color', cMap(ii,:))
        hold on
    
    end
    plot([-100 100], [0 0], 'k')
    plot(x_data, summary_stim(stim_num).rois(c_roi).mean_dF-mean(summary_stim(stim_num).rois(c_roi).mean_dF(500:1000)), 'k', 'linewidth', 2);
    xlim([0 50])
    ylim([-.1 1.5])
    
    set(gca, 'XTick', [], 'Fontsize', 25)
    box off
    ylabel('dF/F', 'Fontsize', 30)
    
    text(20, 1.3, ['REF: ' summary_stim(stim_num).ref_name], 'Fontsize', 25 )
    text(20, 1.15, ['TEST: ' summary_stim(stim_num).test_name], 'Fontsize', 25 )
    text(20, 1, ['ROI: ' num2str(c_roi)], 'Fontsize', 25 )

    %subplot 3: stim
    s3 = subplot(4,1,3);
    b_xval      = summary_stim(stim_num).s_tstamp;
    therm_yval  = summary_stim(stim_num).therm_vec-min(summary_stim(stim_num).therm_vec);
    if max(therm_yval) ~= 0
        therm_yval = therm_yval/max(therm_yval);
    end
    
    hold on
    
    diff_viz_vec = [0 diff(summary_stim(stim_num).viz_vec)];
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
 
    text(2, .9, 'heat', 'fontsize', 25, 'color', 'r')
    text(2, .7, 'visual', 'fontsize', 25, 'color', 'k')
    
    set(gca, 'XTick', [], 'YTick', []);
    xlim([0 50])
    
    % subplot 4: behavior
    s4 = subplot(4,1,4);
    x_data = summary_stim(stim_num).b_tstamp;
    raw_yaw_data = summary_stim(stim_num).yaw_data;
    
    for ii = 1:size(raw_yaw_data, 1)
    
        plot(x_data, raw_yaw_data(ii,:), 'color', cMap(ii,:))
        hold on
    
    end
    plot([-100 100], [0 0], 'k')
    plot(x_data, summary_stim(stim_num).mean_yaw, 'k', 'linewidth', 2);
    xlim([0 50])
    ylim([-1 1])
    
    set(gca, 'XTick', [0 10 20 30 40 50], 'Fontsize', 25)
    box off
    ylabel('yaw', 'Fontsize', 30)
    
    s1_p = get(s1, 'Position');
    set(s1, 'Position', [s1_p(1)-.3 s1_p(2:4)]);
    
    s3_p = get(s3, 'Position');
    set(s3, 'Position', [s3_p(1) s3_p(2)+.1 s3_p(3) s3_p(4)/1.5 ]);
    

    s4_p = get(s4, 'Position');
    set(s4, 'Position', [s4_p(1) s4_p(2)+.15 s4_p(3) s4_p(4)/1.2 ]);
    
    xlabel('time (sec)', 'FontSize', 30)
    
    mkdir('plots')
    cd('plots')
    
    if is_auto
        plot_name = ['stim_summary_ROI_' num2str(c_roi, '%03d') ...
                    '_STIM_' num2str(stim_num, '%03d')];
    else
       plot_name = ['stim_summary_hand_ROI_' num2str(c_roi, '%03d') ...
                    '_STIM_' num2str(stim_num, '%03d')];
    end
    
    prettyprint(f1, plot_name);
    close all
    cd(expdir)
    
    end
end

end