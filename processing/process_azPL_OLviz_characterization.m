function process_azPL_OLviz_characterization(expdir)

cd(expdir)
load('roi_data.mat')


for c_roi = 1:length(roi_struct)
   for c_type = 1:11
      
       summary_by_roi(c_roi).stim_type(c_type).df_vals = [];
       summary_by_roi(c_roi).stim_type(c_type).df_tstamp = [];
       
       summary_by_roi(c_roi).stim_type(c_type).stim = [];
       summary_by_roi(c_roi).stim_type(c_type).stim_tstamp = [];   
       
   end
end


for c_roi = 1:length(roi_struct);
    for c_type = 1:11;
        
        c_fname = dir(['*type_' num2str(c_type, '%03d') '*']);

        for ii = 1:length(c_fname)
   
            load(c_fname(ii).name);
    
            if isfield(expr.c_trial, 'idata')
                
                b_idx = expr.c_trial.idata.img_frame_id(1:end-3);
                tstamps = expr.c_trial.bdata.timestamp(b_idx);
    
                df_vals = expr.c_trial.idata.roi_traces(c_roi,1:length(tstamps));
                
                summary_by_roi(c_roi).stim_type(c_type).df_vals = [summary_by_roi(c_roi).stim_type(c_type).df_vals;...
                                                                    df_vals];                
 
                summary_by_roi(c_roi).stim_type(c_type).df_tstamp  = tstamps;

                stim_tstamps = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);
                raw_laserpower = expr.c_trial.bdata.laser_power(1:expr.c_trial.bdata.count);                
            
                zeroed_laserpower = raw_laserpower+4.99;
                normed_laserpower = zeroed_laserpower./max(zeroed_laserpower);

                summary_by_roi(c_roi).stim_type(c_type).stim = normed_laserpower;
                summary_by_roi(c_roi).stim_type(c_type).stim_tstamp = stim_tstamps;                
                
            end
        end
        
       summary_by_roi(c_roi).stim_type(c_type).mean_df_vals = mean(summary_by_roi(c_roi).stim_type(c_type).df_vals);
       
       half_length = floor(length(summary_by_roi(c_roi).stim_type(c_type).mean_df_vals)/2);       
       tenP_half_length = floor(1.1*length(summary_by_roi(c_roi).stim_type(c_type).mean_df_vals)/2);       
       twentyP_half_length = floor(1.2*length(summary_by_roi(c_roi).stim_type(c_type).mean_df_vals)/2);
       
       summary_by_roi(c_roi).stim_type(c_type).peak_resp = max(summary_by_roi(c_roi).stim_type(c_type).mean_df_vals(tenP_half_length:end));
       summary_by_roi(c_roi).stim_type(c_type).nadir = min(summary_by_roi(c_roi).stim_type(c_type).mean_df_vals(half_length:twentyP_half_length));

       summary_by_roi(c_roi).stim_type(c_type).floor_to_peak = summary_by_roi(c_roi).stim_type(c_type).peak_resp - ...
                                                                   summary_by_roi(c_roi).stim_type(c_type).nadir ;
       
                                                               
    end
end

save('roi_summary_data.mat', 'summary_by_roi')
