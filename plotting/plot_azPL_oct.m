%function plot_azPL_oct
expdir = '\\reiser_nas\tj\az_pl\processed\20160826153354_tdc-2; mi4-tdtomato_OL_stim';

cd(expdir)

load('roi_data.mat')
whitebg('w')
close all

expfiles = dir('env*');
load(expfiles(1).name)


        
f1 = figure('color', 'w', 'units', 'normalized',...
        'Position', [0.0339 0.3038 0.5536 0.5905], 'visible', 'on');

s1 = subplot(3,2,1:2);
    imagesc(max(expr.c_trial.idata.frame_MIP,[], 3));
    colormap(gray)
    axis equal off tight
    hold on

    for c_roi = 1:length(roi_struct)
        scat_h = fill(roi_struct(c_roi).xy(:,1), roi_struct(c_roi).xy(:,2), roi_struct(c_roi).cmap);
        set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);
    end

    if isfield(expr.c_trial, 'bdata')
        expr.c_trial.data = expr.c_trial.bdata;
    end

    caxis([115 150])

s2 = subplot(3,2,3:4);

   
    for c_roi = 1:length(roi_struct)
    
            if isfield(expr.c_trial, 'idata')
                
                b_idx = expr.c_trial.idata.img_frame_id(1:end-3);
                tstamps = expr.c_trial.bdata.timestamp(b_idx);
    
                df_vals = expr.c_trial.idata.roi_traces(c_roi,1:length(tstamps));
    
                plot(tstamps, medfilt1(df_vals - mean(df_vals(1:100)), 12), 'color', roi_struct(c_roi).cmap)
    
                hold on
            
            end

    end
    
        plot([-1000 1000], [0 0], 'k')
        xlim([0 120])
      %  ylim([-.1 1.5])
        box off

        set(gca, 'XTick', [], 'Fontsize', 25, 'XColor', 'w', 'YTick', [0 .5 1])
        ylabel('dF/F', 'fontsize', 30)

%         s2 = subplot(2,1,2);
%         tstamps = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);
%         raw_laserpower = expr.c_trial.bdata.laser_power(1:expr.c_trial.bdata.count);
% 
%         zeroed_laserpower = raw_laserpower+4.99;
%         normed_laserpower = zeroed_laserpower./max(zeroed_laserpower);
% 
%         plot(tstamps, normed_laserpower, 'linewidth', 2, 'color', 'r')
%         xlim([0 120])
%         ylim([0 1])
%         box off
% 
%         set(gca, 'XTick', [30 60 90 120], 'YTick', [0 1], 'Fontsize', 25)
%         xlabel('time (sec)', 'fontsize', 30)
%         ylabel('light power', 'fontsize', 30)
% 
%         s2_p = get(s2, 'Position');
%         set(s2, 'Position', [s2_p(1:3) s2_p(4)/2]);
% 
%         s1_p = get(s1, 'Position');
%         set(s1, 'Position', [s1_p(1) s1_p(2)-.2 s1_p(3) s1_p(4)*1.5]);
% 
% 


