function plot_azPL_OL_characterization_roi_sum(expdir)

cd(expdir)

load('roi_summary_data.mat')
load('roi_data.mat')
whitebg('w')
close all

extend_map = bipolar(7);
extend_map = extend_map(2:end-1,:);
extend_map(1:2,:) = flipud(extend_map(1:2,:));
extend_map(end-1:end,:) = flipud(extend_map(end-1:end,:));


off_map = bipolar(7);
off_map = off_map(2:end-1,:);
off_map(1:2,:) = flipud(off_map(1:2,:));
off_map(end-1:end,:) = flipud(off_map(end-1:end,:));



for c_roi = 1:length(roi_struct);
        
        close all
        
        f1 = figure('color', 'w', 'units', 'normalized',...
                'Position', [0.0339 0.3038 0.5536 0.5905], 'visible', 'off');

        s1 = subplot(2,1,1);

        for c_type = 3:7
                
                df_tstamps = summary_by_roi(c_roi).stim_type(c_type).df_tstamp;
                df_vals = summary_by_roi(c_roi).stim_type(c_type).mean_df_vals;
                df_vals = df_vals-mean(df_vals(100:300));
    
                plot(df_tstamps, df_vals, 'color', extend_map(c_type-2,:), 'linewidth', 1.5)
    
                hold on

        end
        
        plot([-1000 1000], [0 0], 'k')
        xlim([0 120])
      %  ylim([-.5 1.0])
        box off

        set(gca, 'XTick', [], 'Fontsize', 25, 'XColor', 'w', 'YTick', [-.25 0 .25 .5 1])
        ylabel('dF/F', 'fontsize', 30)

        s2 = subplot(2,1,2);
        
        for c_type = 3:7
            
            stim_tstamps = summary_by_roi(c_roi).stim_type(c_type).stim_tstamp;
            stim = summary_by_roi(c_roi).stim_type(c_type).stim;
        
            plot(stim_tstamps, stim, 'linewidth', 1.5, 'color', extend_map(c_type-2,:))
            
            hold on
            
        end
        
        xlim([0 120])
        ylim([0 1])
        box off

        set(gca, 'XTick', [30 60 90 120], 'YTick', [0 1], 'Fontsize', 25)
        xlabel('time (sec)', 'fontsize', 30)
        ylabel('light power', 'fontsize', 30)

        s2_p = get(s2, 'Position');
        set(s2, 'Position', [s2_p(1:3) s2_p(4)/2]);

        s1_p = get(s1, 'Position');
        set(s1, 'Position', [s1_p(1) s1_p(2)-.2 s1_p(3) s1_p(4)*1.5]);

        mkdir('plots')
        cd('plots')

        pname = ['extend_summary_ROI_' num2str(c_roi, '%03d') ];
        prettyprint(f1, pname);
        cd('..')
    
end

for c_roi = 1:length(roi_struct);
        
        close all
        
        f1 = figure('color', 'w', 'units', 'normalized',...
                'Position', [0.0339 0.3038 0.5536 0.5905], 'visible', 'off');

        s1 = subplot(2,1,1);

        for c_type = 7:11
                
                df_tstamps = summary_by_roi(c_roi).stim_type(c_type).df_tstamp;
                df_vals = summary_by_roi(c_roi).stim_type(c_type).mean_df_vals;
                df_vals = df_vals-mean(df_vals(100:300));
    
                plot(df_tstamps, df_vals, 'color', off_map(c_type-6,:), 'linewidth', 1.5)
    
                hold on

        end
        
        plot([-1000 1000], [0 0], 'k')
        xlim([0 120])
        ylim([-.5 1.0])
        box off

        set(gca, 'XTick', [], 'Fontsize', 25, 'XColor', 'w', 'YTick', [0 .5 1])
        ylabel('dF/F', 'fontsize', 30)

        s2 = subplot(2,1,2);
        
        for c_type = 7:11
            
            stim_tstamps = summary_by_roi(c_roi).stim_type(c_type).stim_tstamp;
            stim = summary_by_roi(c_roi).stim_type(c_type).stim;
        
            plot(stim_tstamps, stim, 'linewidth', 1.5, 'color', off_map(c_type-6,:))
            
            hold on

        end
        
        xlim([0 120])
        ylim([0 1])
        box off

        set(gca, 'XTick', [30 60 90 120], 'YTick', [0 1], 'Fontsize', 25)
        xlabel('time (sec)', 'fontsize', 30)
        ylabel('light power', 'fontsize', 30)

        s2_p = get(s2, 'Position');
        set(s2, 'Position', [s2_p(1:3) s2_p(4)/2]);

        s1_p = get(s1, 'Position');
        set(s1, 'Position', [s1_p(1) s1_p(2)-.2 s1_p(3) s1_p(4)*1.5]);

        mkdir('plots')
        cd('plots')

        pname = ['cooling_summary_ROI_' num2str(c_roi, '%03d')];
        prettyprint(f1, pname);
        cd('..')
    
end

