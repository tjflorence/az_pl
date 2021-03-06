print_dir = 'C:\matlab_root\az_pl\meeting_and_analysis\20160811';

%% file paths for experiments to include in summary
hot_blind(1).path = '\\reiser_nas\tj\az_pl\processed\20160806152517_11f03_OL_stim';
hot_blind(1).roi = 1;

hot_blind(2).path = '\\reiser_nas\tj\az_pl\processed\20160807155741_11f03_OL_stim';
hot_blind(2).roi = 1;

hot_blind(3).path = '\\reiser_nas\tj\az_pl\processed\20160807211859_11f03_OL_stim';
hot_blind(3).roi = 1;

hot_blind(4).path = '\\reiser_nas\tj\az_pl\processed\20160805192338_11f03_OL_stim';
hot_blind(4).roi = 1;

%% information about plotting groups
plot_collections(1).name = 'refVIZ_testNOHEAT';
plot_collections(1).conditions = [1 3 5 7 9 ];

plot_collections(2).name = 'refVIZ_testHEAT';
plot_collections(2).conditions = [2 4 6 8 10];

plot_collections(3).name = 'refNOHEAT_testVIZ';
plot_collections(3).conditions = [11 12 13 14 15];

plot_collections(4).name = 'refHEAT_testVIZ';
plot_collections(4).conditions = [16 17 18 19 20];

%% cd to first to collect an example summary struct
cd(hot_blind(1).path);
load('multisense_summary_data.mat')
for ii = 1:length(summary_stim)
   
    multi_summary(ii).dF_collect = [];
    multi_summary(ii).ref_name = summary_stim(ii).ref_name;
    multi_summary(ii).test_name = summary_stim(ii).test_name;
    
    multi_summary(ii).viz_vec = summary_stim(ii).viz_vec;
    multi_summary(ii).therm_vec = summary_stim(ii).therm_vec;
    multi_summary(ii).s_tstamp = summary_stim(ii).s_tstamp;
    
end

%% collect dF data for ROI of interest
for ii = 1:length(hot_blind)
   
    cd(hot_blind(ii).path);
    load('multisense_summary_data.mat')
    
    for jj = 1:20
        multi_summary(jj).dF_collect = [multi_summary(jj).dF_collect ;...
                                        summary_stim(jj).rois(hot_blind(ii).roi).mean_dF];
        multi_summary(jj).i_tstamp = summary_stim(jj).rois(hot_blind(ii).roi).i_tstamp;
    end
    
end

%% mean and standard
for jj = 1:20
        
        multi_summary(jj).mean_dF = mean(multi_summary(jj).dF_collect);
        multi_summary(jj).mean_dF = multi_summary(jj).mean_dF -mean(multi_summary(jj).mean_dF(900:1200));
        multi_summary(jj).std_dF = std(multi_summary(jj).dF_collect);  
        
end

close all
cd(print_dir);
save('multi_summary_data.mat', 'multi_summary')

cMap = [0 0 0;...
         123 50 148;...
         44 123 182;...
         230 97 1;...
        215 25 28 ]./255;

for collection_num = 1:length(plot_collections);

    f1 = figure('units', 'normalized',...
        'position', [0.0099    0.1333    0.2974    0.7676], 'color', 'w', ...
        'visible', 'off');
    
    % subplot 1: image of ROI


    
    % subplot 2: traces
    s2 = subplot(3,1,2); 
 
    plot([-10000 10000], [0, 0], 'k')
    for ii = 1:length(plot_collections(collection_num).conditions)
        
        c_collection_idx = plot_collections(collection_num).conditions(ii);
        
        x_vals = multi_summary(c_collection_idx).i_tstamp;
        mean_y_vals = multi_summary(c_collection_idx).mean_dF;
        std_y_vals = multi_summary(c_collection_idx).std_dF/2;
        
        hold on
        confplot(x_vals, mean_y_vals, std_y_vals, std_y_vals, cMap(ii,:))
             
    
    end
    xlim([.1 50])
    ylim([-.1 .6])
    box off
    
    set(gca, 'XTick', [10 20 30 40], 'XTickLabel', {},...
                'YTick', [0 .25 .5], 'YTickLabel', {'0', '25' ,'50'} , 'FontSize', 20)
    ylabel('%dF/F', 'Fontsize', 30)
            
    text(0, .7, 'dark', 'FontSize', 15, 'color', cMap(1,:))
    text(0, .75, 'light', 'FontSize', 15, 'color', cMap(2,:))
    text(0, .8, 'environment: static', 'FontSize', 15, 'color', cMap(3,:))
    text(0, .85, 'environment: open-loop motion', 'FontSize', 15, 'color', cMap(4,:))
    text(0, .9, 'environment: closed-loop motion', 'FontSize', 15, 'color', cMap(5,:))
    
    %subplot 3: stim
    s3 = subplot(3,1,3);
    final_condition = length(plot_collections(collection_num).conditions);
    c_collection_idx = plot_collections(collection_num).conditions(final_condition);
    
    b_xval      = multi_summary(c_collection_idx).s_tstamp;
    therm_yval  = multi_summary(c_collection_idx).therm_vec-min(multi_summary(c_collection_idx).therm_vec);
    if max(therm_yval) ~= 0
        therm_yval = therm_yval/max(therm_yval);
    end
    
    hold on
    
    diff_viz_vec = [0 diff(multi_summary(c_collection_idx).viz_vec)];
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
    
    set(gca, 'XTick', [10 20 30 40], 'YTick', [], 'Fontsize', 20);
    xlabel('time (sec)')
    xlim([0 50])
    

    
    s3_p = get(s3, 'Position');
    set(s3, 'Position', [s3_p(1)+.05 s3_p(2) s3_p(3) s3_p(4)/1.5 ]);
    
    s2_p = get(s2, 'Position');
    set(s2, 'Position', [s2_p(1)+.05 s2_p(2)-.1 s2_p(3) s2_p(4)*2 ]);   
    
    fig_name = ['multiexp_summary_group_' plot_collections(collection_num).name];
                
     cd(print_dir)

     prettyprint(f1, fig_name)
     close all
        
     cd(print_dir)
end