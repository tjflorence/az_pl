print_dir = 'C:\matlab_root\az_pl\meeting_and_analysis\20160825';

%% file paths for experiments to include in summary
hot_blind(1).path = '\\reiser_nas\tj\az_pl\processed\20160806152517_11f03_OL_stim';
hot_blind(1).roi = 1;
hot_blind(1).ver = 1;

hot_blind(2).path = '\\reiser_nas\tj\az_pl\processed\20160807155741_11f03_OL_stim';
hot_blind(2).roi = 1;
hot_blind(2).ver = 1;

hot_blind(3).path = '\\reiser_nas\tj\az_pl\processed\20160807211859_11f03_OL_stim';
hot_blind(3).roi = 1;
hot_blind(3).ver = 1;

hot_blind(4).path = '\\reiser_nas\tj\az_pl\processed\20160805192338_11f03_OL_stim';
hot_blind(4).roi = 1;
hot_blind(4).ver = 1;

hot_blind(5).path = '\\reiser_nas\tj\az_pl\processed\20160825190814_11f03_OL_stim';
hot_blind(5).roi = 4;
hot_blind(5).ver = 2;

hot_blind(6).path = '\\reiser_nas\tj\az_pl\processed\20160825145626_11f03_OL_stim';
hot_blind(6).roi = 4;
hot_blind(6).ver = 2;

hot_blind(7).path = '\\reiser_nas\tj\az_pl\processed\20160818212641_11f03_OL_stim';
hot_blind(7).roi = 4;
hot_blind(7).ver = 2;

%% information about plotting groups
plot_collections(1).name = 'refVIZ_testNOHEAT';
plot_collections(1).conditions_v1 = [1 3 5 7 9 ];
plot_collections(1).conditions_v2 = [1 4 7 10 13];

plot_collections(2).name = 'refVIZ_testHEAT';
plot_collections(2).conditions_v1 = [2 4 6 8 10];
plot_collections(2).conditions_v2 = [2 5 8 11 14];

plot_collections(3).name = 'refNOHEAT_testVIZ';
plot_collections(3).conditions_v1 = [11 12 13 14 15];
plot_collections(3).conditions_v2 = [16 17 18 19 20];

plot_collections(4).name = 'refHEAT_testVIZ';
plot_collections(4).conditions_v1 = [16 17 18 19 20];
plot_collections(4).conditions_v2 = [21 22 23 24 25];

%% cd to first to collect an example summary struct
for ii = 1:length(plot_collections)
   
    for jj = 1:length(plot_collections(ii).conditions_v1)
       
        plot_collections(ii).trial_data(jj).dFs = [];
        plot_collections(ii).trial_data(jj).i_tstamps = [];
        
        plot_collections(ii).trial_data(jj).viz = [];
        plot_collections(ii).trial_data(jj).therm = [];
        plot_collections(ii).trial_data(jj).b_tstamps = [];
              
    end    
    
end


for ii = 1:length(plot_collections)
   
    for bb = 1:length(hot_blind)
        
        cd(hot_blind(bb).path)
        load('multisense_summary_data.mat')
        
        for jj = 1:length(plot_collections(ii).conditions_v1)
            
            if hot_blind(bb).ver == 1
                c_idx = plot_collections(ii).conditions_v1(jj);
            else
                c_idx = plot_collections(ii).conditions_v2(jj);                
            end
                
                plot_collections(ii).trial_data(jj).dFs = [plot_collections(ii).trial_data(jj).dFs;...
                                                              summary_stim(c_idx).rois(hot_blind(bb).roi).mean_dF];
                                                          
                plot_collections(ii).trial_data(jj).i_tstamps = summary_stim(c_idx).rois(hot_blind(bb).roi).i_tstamp;

                plot_collections(ii).trial_data(jj).viz = summary_stim(c_idx).viz_vec;
                plot_collections(ii).trial_data(jj).therm = summary_stim(c_idx).therm_vec;
                plot_collections(ii).trial_data(jj).b_tstamps = summary_stim(c_idx).s_tstamp;
                
                if bb > 1
                    plot_collections(ii).trial_data(jj).mean_dF = mean(plot_collections(ii).trial_data(jj).dFs);
                    plot_collections(ii).trial_data(jj).std_dF = std(plot_collections(ii).trial_data(jj).dFs)/sqrt(size(plot_collections(ii).trial_data(jj).dFs, 1));
       
                    plot_collections(ii).trial_data(jj).mean_dF = plot_collections(ii).trial_data(jj).mean_dF - mean(plot_collections(ii).trial_data(jj).mean_dF(900:1200));
                end
        
        end

     end
         
end



close all
cd(print_dir);
save('multi_summary_data.mat', 'plot_collections')

%% now plot
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
    for ii = 1:length(plot_collections(collection_num).trial_data)
                
        x_vals = plot_collections(collection_num).trial_data(ii).i_tstamps;
        mean_y_vals = plot_collections(collection_num).trial_data(ii).mean_dF;
        mean_y_vals = mean_y_vals-mean(mean_y_vals(900:1200));

        std_y_vals = plot_collections(collection_num).trial_data(ii).std_dF;
        
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

    b_xval      = plot_collections(collection_num).trial_data(ii).b_tstamps;
    therm_yval  = plot_collections(collection_num).trial_data(ii).therm-min(plot_collections(collection_num).trial_data(ii).therm);
    if max(therm_yval) ~= 0
        therm_yval = therm_yval/max(therm_yval);
    end
    
    hold on
    
    diff_viz_vec = [0 diff(plot_collections(collection_num).trial_data(ii).viz)];
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