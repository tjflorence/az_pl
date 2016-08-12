%load('env_rep_006_type_016_REF_heat_TEST_dark.mat')

expdir = '\\reiser_nas\tj\az_pl\processed\20160805192338_11f03_OL_stim';

cd(expdir)
load('auto_roi_data.mat')

parfor exp_types = 1:20;
   for c_roi = 1:length(roi_auto_struct);
       
        cd(expdir)
        close all

        f1 = figure('color', 'w', 'units', 'normalized', ...
                      'Position', [0.0120 0.3861 0.3526 0.4907], 'visible', 'off');
         
        type_name = ['*type_' num2str(exp_types, '%03d'), '*'];
        type_files = dir(type_name);
        
        hold on
        
        plot([-100 100], [0 0], 'k')
        plot([0 0], [-100 100], 'k')

        for jj = 1:length(type_files)
            
            expr = expr_load_helper(type_files(jj).name);
            if isfield(expr.c_trial, 'idata')
                dF_data = expr.c_trial.idata.auto_roi_traces(c_roi, :);
                dF_data = dF_data(1:end-1);

                dF_b_idx = expr.c_trial.idata.img_frame_id;
                dF_b_idx = dF_b_idx(1:end-1);

                raw_yaw = expr.c_trial.bdata.om;
                sm_yaw = conv(raw_yaw, ones(25,1)/25, 'same');

                i_yaw = sm_yaw(dF_b_idx);
                i_light = expr.c_trial.bdata.laser_power(dF_b_idx);


                for ii = 1:length(dF_data)

                    sc1 = scatter(i_yaw(ii), dF_data(ii), 50);

                    if i_light(ii) == 1
                        sColor = 'r';
                    else
                        sColor = 'b';
                    end

                    set(sc1, 'MarkerEdgeColor', 'None', 'MarkerFaceColor', sColor);
                    alpha(sc1, .2)
                    hold on

                end       
            end
        end
        
        set(gca, 'FontSize', 25)
        xlim([-4 4])
        ylim([-.5 .5])
        
        xlabel('yaw', 'FontSize', 30)
        ylabel('dF/F', 'FontSize', 30)
        
        mkdir('plots')
        cd('plots')
        
        fig_name = ['therm_or_motor_ROI_' num2str(c_roi, '%03d') '_exptype_' num2str(exp_types, '%03d')];
        prettyprint(f1, fig_name)
    end
end