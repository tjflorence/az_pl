function plot_azPL_sawtooth_map_raw(expdir)

%{ 
    raw plot of OL mapping experiment that preceeds and follows the azPL
    experiment

%}



cd(expdir);

load('auto_roi_data.mat')
roi_struct = roi_auto_struct;

ol_a = dir('OL_A*');
ol_b = dir('OL_B*');

for c_roi = 1:length(roi_struct);

    load(ol_a.name)

    whitebg('w'); close all;

    f1 = figure('units', 'normalized', 'position', [-0.9917 0.1964 0.8692 0.7193], ...
                    'color', 'w', 'visible', 'off');

    load(ol_a.name)

    s1 = subplot(4,2,1:2);
            imagesc(max(expr.c_trial.idata.mcorr_MIP,[], 3));
            colormap(gray)
            axis equal off tight


            hold on

            c_xy = roi_struct(c_roi).xy;

            hold on

            scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
            set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(c_roi).cmap);


    s2 = subplot(4,2,3:4);

        bcount = expr.c_trial.bdata.count;

        c_xpos = mod(expr.c_trial.bdata.xpos(1:bcount)+49, 96);
        c_xpos(c_xpos==0) = nan;
        c_xpos(1:400) = nan;

        plot(expr.c_trial.bdata.timestamp(1:bcount), c_xpos, 'k');
        hold on
        xlim([0 70])
        box off

        set(gca, 'XColor', 'w', 'Fontsize', 25)
        ylabel('position (pixel)')
        ylim([1 96])

    s3 = subplot(4,2,5:6);
        itstamps = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
        c_dF = expr.c_trial.idata.auto_roi_traces(c_roi, 1:end-1);
        plot(itstamps, c_dF, 'color', roi_struct(c_roi).cmap)
        hold on
        plot([- 1000 1000], [0 0 ], 'k')

        xlim([0 70])
        ylim([0 .8])
        set(gca, 'XColor', 'w', 'Fontsize', 25)
        box off

    s4 = subplot(4,2,7:8);
        load(ol_b.name)

    itstamps = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
        c_dF = expr.c_trial.idata.auto_roi_traces(c_roi, 1:end-1);
        plot(itstamps, c_dF, 'color', roi_struct(c_roi).cmap)
        xlim([0 70])
        ylim([0 .8])

        hold on
        plot([- 1000 1000], [0 0 ], 'k')

        xlim([0 70])
        ylim([0 .8])
        set(gca, 'Fontsize', 25)
        box off

        xlabel('time (sec)', 'Fontsize', 30)
        y1 = ylabel('dF/F', 'Fontsize', 30);
        y1_p = get(y1, 'position');
        set(y1, 'position', [y1_p(1) y1_p(2)+.6 ]);

    s1_p = get(s1, 'Position');
        set(s1, 'position', [s1_p(1)-.3 s1_p(2:4)])


        mkdir('plots')
        cd('plots')

        fig_name = ['OL_map_raw_ROI_' num2str(c_roi, '%03d')];

        prettyprint(f1, fig_name)
        close all
        cd(expdir)
    
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    