function adaptation_idx(expdir, is_auto)

cd(expdir)

train_files = dir('env_train*');

if isempty(is_auto)
    is_auto = 0;
end

if is_auto == 0 
    load('roi_data.mat')
else
    load('auto_roi_data.mat')
    roi_struct = roi_auto_struct;
end

lead_seconds = 3;
lag_seconds = 5;

for c_roi = 1:length(roi_struct)
    
    early_peak = [];
    for c_trial = 1:3
       
        load(train_files(c_trial).name)
        
        if isfield(expr.c_trial, 'idata')
            
            cool_half_second = zeros(1,length(expr.c_trial.bdata.laser_power)-25);
            for ii = 1:(length(expr.c_trial.bdata.laser_power)-25)
                test_vec = expr.c_trial.bdata.laser_power(ii:ii+25);
                num_cool_frames = numel(find(test_vec<expr.settings.light_power));
                
                if num_cool_frames == length(test_vec)
                    
                    cool_half_second(ii) = 1;
                end
                
            end
        first_cool = find(cool_half_second==1,1, 'first');
        
        if ~isempty(first_cool)
           
            lead_idx = first_cool-(lead_seconds*expr.settings.hz);
            lag_idx = first_cool+(lag_seconds*expr.settings.hz);
            
            if lead_idx > 1 && lag_idx < expr.c_trial.bdata.count
               
                first_trace_idx = expr.c_trial.bdata.c_iframe(lead_idx);
                last_trace_idx = expr.c_trial.bdata.c_iframe(lag_idx);
                
                if is_auto == 0
                    c_trace = expr.c_trial.idata.roi_traces(c_roi, first_trace_idx:last_trace_idx);
                else
                    c_trace = expr.c_trial.idata.auto_roi_traces(c_roi, first_trace_idx:last_trace_idx);
                end
                
                expected_hz = floor(length(expr.c_trial.idata.roi_traces)/expr.settings.trial_time);
                c_trace = c_trace(1:(expected_hz*(lead_seconds+lag_seconds)));
                early_peak = [early_peak; max(c_trace)];

            end
            
        end
        end
    end
    
    late_peak = [];
    for c_trial = (length(train_files)-3):length(train_files)
       
        load(train_files(c_trial).name)
        if isfield(expr.c_trial, 'idata')
            
            cool_half_second = zeros(1,length(expr.c_trial.bdata.laser_power)-25);
            for ii = 1:(length(expr.c_trial.bdata.laser_power)-25)
                test_vec = expr.c_trial.bdata.laser_power(ii:ii+25);
                num_cool_frames = numel(find(test_vec<expr.settings.light_power));
                
                if num_cool_frames == length(test_vec)
                    
                    cool_half_second(ii) = 1;
                end
                
            end
        first_cool = find(cool_half_second==1,1, 'first');
        
        if ~isempty(first_cool)
           
            lead_idx = first_cool-(lead_seconds*expr.settings.hz);
            lag_idx = first_cool+(lag_seconds*expr.settings.hz);
            
            if lead_idx > 1 && lag_idx < expr.c_trial.bdata.count
               
                first_trace_idx = expr.c_trial.bdata.c_iframe(lead_idx);
                last_trace_idx = expr.c_trial.bdata.c_iframe(lag_idx);
                
                if is_auto == 0
                    c_trace = expr.c_trial.idata.roi_traces(c_roi, first_trace_idx:last_trace_idx);
                else
                    c_trace = expr.c_trial.idata.auto_roi_traces(c_roi, first_trace_idx:last_trace_idx);
                end
                
                expected_hz = floor(length(expr.c_trial.idata.roi_traces)/expr.settings.trial_time);
                c_trace = c_trace(1:(expected_hz*(lead_seconds+lag_seconds)));
                late_peak = [late_peak; max(c_trace)];

            end
        end
        end
        
    end
    
    cool_adapt(c_roi).early_peaks = early_peak;
    cool_adapt(c_roi).late_peaks = late_peak;
    cool_adapt(c_roi).adapt_idx = (mean(early_peak)-mean(late_peak))/...
                                     (mean(early_peak)+mean(late_peak));
    

end

save('cool_adapation_summary.mat', 'cool_adapt')