function process_azPL_multisense_exp(expdir)

homedir = pwd;

cd(expdir)
load('auto_roi_data.mat')
roi_struct = roi_auto_struct;
num_rois = length(roi_struct);

all_trials = dir('env*');
load(all_trials(1).name);

num_interp_vals = 10000;
num_stim_types = length(expr.settings.stim_struct);
num_reps = expr.settings.num_reps;

%% pre-allocate
for ii = 1:num_stim_types
    
    for jj = 1:num_rois
        summary_stim(ii).rois(jj).dFs = nan(expr.settings.num_reps, num_interp_vals);
        summary_stim(ii).yaw_data = nan(expr.settings.num_reps, num_interp_vals);    
    end
    
end

%% now load interpolated dF vals into structure
for ii = 1:num_stim_types
   
    type_to_search = num2str(ii, '%03d');
    c_type_exp = dir(['*_type_' type_to_search '*']);
    
    
    for jj = 1:length(c_type_exp) % jj for each rep of stim type

        load(c_type_exp(jj).name)
        if isfield(expr.c_trial, 'idata')
            % collect stimulus name etc
            summary_stim(ii).ref_name = expr.settings.stim_struct(ii).ref_name;
            summary_stim(ii).test_name = expr.settings.stim_struct(ii).test_name;
            summary_stim(ii).viz_vec = expr.settings.stim_struct(ii).viz_vec;
            summary_stim(ii).therm_vec = expr.settings.stim_struct(ii).therm_vec;
            summary_stim(ii).s_tstamp = expr.c_trial.bdata.timestamp(1:length(summary_stim(ii).viz_vec));
        
            % collect behavior response (smooth yaw)
            raw_yaw = expr.c_trial.bdata.om(1:expr.c_trial.bdata.count);
            raw_yaw = conv(raw_yaw, ones(25,1)/25, 'same');

            b_timestamp = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);
            tstamp_i = b_timestamp(1);
            tstamp_n = b_timestamp(end);
        
            interp_yaw = spline(b_timestamp, raw_yaw,...
                                linspace(tstamp_i, tstamp_n, num_interp_vals));
        
            summary_stim(ii).yaw_data(jj,:) = interp_yaw;
            summary_stim(ii).b_tstamp = linspace(tstamp_i, tstamp_n, num_interp_vals);
      
            % collect dFs
            img_to_bframe = expr.c_trial.idata.img_frame_id;
            img_to_bframe = img_to_bframe(1:end-1);
            tStamps = expr.c_trial.bdata.timestamp(img_to_bframe); 
            tStamps = tStamps(~isnan(tStamps));
            tStamps = unique(tStamps);
        
            for kk = 1:num_rois
            
                c_dFs = expr.c_trial.idata.auto_roi_traces(kk,1:length(tStamps));
                tstamp_i = tStamps(1);
                tstamp_n = tStamps(end);
            
                interp_dFs = spline(tStamps, c_dFs,...
                                linspace(tstamp_i, tstamp_n, num_interp_vals));
                            
                summary_stim(ii).rois(kk).dFs(jj,:) = interp_dFs;
                summary_stim(ii).rois(kk).i_tstamp    = linspace(tstamp_i, tstamp_n, num_interp_vals);
            end
        
        end 
    end
   
end

for ii = 1:num_stim_types
    for jj = 1:num_rois
       
        summary_stim(ii).rois(jj).mean_dF = nanmean(summary_stim(ii).rois(jj).dFs);
        summary_stim(ii).mean_yaw = nanmean(summary_stim(ii).yaw_data);
        
    end
end
cd(expdir)
save('multisense_summary_data.mat', 'summary_stim')

cd(homedir)
end
