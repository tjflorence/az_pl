function plot_azPL_OL_characterization_by_stim(expdir)

cd(expdir)

load('roi_data.mat')
whitebg('w')
close all

expfiles = dir('env*');
load(expfiles(1).name)

for c_roi = 1:length(roi_struct);
    for c_type = 1:expr.settings.num_stim_types;
        
        c_fname = dir(['*type_' num2str(c_type, '%03d') '*']);

        f1 = figure('color', 'w', 'units', 'normalized',...
                'Position', [0.0339 0.3038 0.5536 0.5905], 'visible', 'off');

        s1 = subplot(2,1,1);

        cMap = [linspace(0,1,length(c_fname))' zeros(length(c_fname), 1) zeros(length(c_fname), 1) ];
        cMap = fliplr(cMap);

        for ii = 1:length(c_fname)
   
            load(c_fname(ii).name);
    
            if isfield(expr.c_trial, 'idata')
                
                b_idx = expr.c_trial.idata.img_frame_id(1:end-3);
                tstamps = expr.c_trial.bdata.timestamp(b_idx);
    
                df_vals = expr.c_trial.idata.roi_traces(c_roi,1:length(tstamps));
    
                plot(tstamps, df_vals, 'color', cMap(ii,:))
    
                hold on
            
            end
        end

        plot([-1000 1000], [0 0], 'k')
        xlim([0 120])
        ylim([-.3 1.2])
        box off

        set(gca, 'XTick', [], 'Fontsize', 25, 'XColor', 'w', 'YTick', [0 .5 1])
        ylabel('dF/F', 'fontsize', 30)

        s2 = subplot(2,1,2);
        tstamps = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);
        raw_laserpower = expr.c_trial.bdata.laser_power(1:expr.c_trial.bdata.count);

        zeroed_laserpower = raw_laserpower+4.99;
        normed_laserpower = zeroed_laserpower./max(zeroed_laserpower);

        plot(tstamps, normed_laserpower, 'linewidth', 2, 'color', 'r')
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

        pname = ['stim_summary_ROI_' num2str(c_roi, '%03d') '_' expr.settings.stim(c_type).name ];
        prettyprint(f1, pname);
        cd('..')
    end
end

