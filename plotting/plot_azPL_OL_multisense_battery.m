
cd(expdir)

load('auto_roi_data.mat')
whitebg('w')
close all

roi_struct = roi_auto_struct;

expfiles = dir('env*');
load(expfiles(1).name)

for c_roi = 3%1:length(roi_struct);
    for c_type = 1:expr.settings.num_stim_types;
        
        c_fname = dir(['*type_' num2str(c_type, '%03d') '*']);

        f1 = figure('color', 'w', 'units', 'normalized',...
                'Position', [0.0339 0.3038 0.5536 0.5905], 'visible', 'off');

    s3 = subplot(3,1,1);
    present_map = roi_auto_struct(c_roi).present_map;
    imagesc(present_map);
    
    axis equal off

    min_val = min(min(present_map(4:end-3, 4:end-3)));
    max_val = max(max(present_map(4:end-3, 4:end-3)));
    caxis([min_val max_val]);

    colormap([0,0,0; 0,0,0; gray(2^8)])
    axis equal off

    c_xy = roi_auto_struct(c_roi).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_auto_struct(c_roi).cmap);
 

            
        s1 = subplot(3,1,2);

        cMap = [linspace(0,1,length(c_fname))' zeros(length(c_fname), 1) zeros(length(c_fname), 1) ];
        cMap = fliplr(cMap);

        for ii = 1:length(c_fname)
   
            load(c_fname(ii).name);
    
            if isfield(expr.c_trial, 'idata')
                
                b_idx = expr.c_trial.idata.img_frame_id(1:end-3);
                tstamps = expr.c_trial.bdata.timestamp(b_idx);
    
                df_vals = expr.c_trial.idata.auto_roi_traces(c_roi,1:length(tstamps));
                
                if expr.c_trial.viz_type == 0
                    cColor = 'k';
                else
                    cColor = 'b';
                end
                    
    
                plot(tstamps, df_vals, 'color', cColor)
    
                hold on
                
                btstamps = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);
                raw_laserpower = expr.c_trial.bdata.laser_power(1:expr.c_trial.bdata.count);

            
            end
        end

        plot([-1000 1000], [0 0], 'k')
        xlim([0 120])
        ylim([-.3 2])
        box off

        set(gca, 'XTick', [], 'Fontsize', 25, 'XColor', 'w', 'YTick', [0  1])
        ylabel('dF/F', 'fontsize', 30)

        s2 = subplot(3,1,3);

        zeroed_laserpower = raw_laserpower+4.99;
        normed_laserpower = zeroed_laserpower./max(zeroed_laserpower);

        plot(btstamps, normed_laserpower, 'linewidth', 2, 'color', 'r')
        xlim([0 120])
        ylim([0 1])
        box off

        set(gca, 'XTick', [30 60 90 120], 'YTick', [0 1], 'Fontsize', 25)
        xlabel('time (sec)', 'fontsize', 30)
        ylabel('light power', 'fontsize', 30)

        s2_p = get(s2, 'Position');
        set(s2, 'Position', [s2_p(1:3) s2_p(4)/2]);

        s1_p = get(s1, 'Position');
        set(s1, 'Position', [s1_p(1) s1_p(2)-.1 s1_p(3) s1_p(4)*1.5]);

        s3_p = get(s3, 'Position');
        set(s3, 'position', [s3_p(1)-.3 s3_p(2:4)]);
        
        mkdir('plots')
        cd('plots')

        pname = ['stim_viz_summary_ROI_' num2str(c_roi, '%03d') '_' expr.settings.stim(c_type).name ];
        prettyprint(f1, pname);
        cd('..')
        
    end
end

