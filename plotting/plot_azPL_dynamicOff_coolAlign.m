function plot_azPL_dynamicOff_coolAlign(expdir, is_auto)

whitebg('w')
close all

dynamicOff = dir('*type_5*');
vizCL      = dir('*type_3*');

if isempty(is_auto)
    is_auto = 0;
end

if is_auto == 0 
    load('roi_data.mat')
else
    load('auto_roi_data.mat')
    roi_struct = roi_auto_struct;
end

lead_seconds = 5;
lag_seconds = 10;

for c_roi = 1:length(roi_struct)
    
    % first collect cool-aligned responses for dynamic Off
    dynamicOff_aligned_traces = [];
    for c_trial = 1:length(dynamicOff)
       
        load(dynamicOff(c_trial).name)
        
        if isfield(expr.c_trial, 'bdata')
            
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
                dynamicOff_aligned_traces = [dynamicOff_aligned_traces; c_trace];

            end
            
        end
        end
        
    end
 
     % now collect vizCL cool-aligned
    vizCL_aligned_traces = [];
    for c_trial = 1:length(vizCL)
       
        load(vizCL(c_trial).name)
        
        if isfield(expr.c_trial, 'bdata')
            
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
                vizCL_aligned_traces = [vizCL_aligned_traces; c_trace];

            end
            
        end
        end
        
    end
    
    
close all


%% first, plot all trials
f1 = figure('color', 'w', 'units','normalized', 'visible', 'off');
for ii = 1:size(dynamicOff_aligned_traces, 1)
   
    plot(linspace(-lead_seconds,lag_seconds,size(dynamicOff_aligned_traces,2)),...
                                dynamicOff_aligned_traces(ii,:), ...
                                'color', 'k', 'linewidth', 1);
    
    hold on
    
end
    
for ii = 1:size(vizCL_aligned_traces, 1)
   
    plot(linspace(-lead_seconds,lag_seconds,size(vizCL_aligned_traces,2)),...
                                vizCL_aligned_traces(ii,:), ...
                                'color', 'b', 'linewidth', 1);
    
    hold on
    
end
    
    
    box off
    plot([-1000 1000], [0 0], 'k')
    
    xlim([-lead_seconds lag_seconds])
    set(gca, 'Fontsize', 25)
    xlabel('time to cool entry', 'fontsize', 30)
    ylabel('dF/F', 'fontsize', 30)
    
    mkdir('plots')
    cd('plots')
    prettyprint(f1, ['coincidence_cool_alighed_traces_ROI_' num2str(c_roi) '_sequence'])
    
    cd(expdir)
    close all
    
%% second, plot mean + SEM response
f2 = figure('color', 'w', 'units','normalized', 'visible', 'off');

mean_dynOff = mean(dynamicOff_aligned_traces);
mean_dynOff = mean_dynOff-(mean(mean_dynOff(1:10)));
sem_dynOff = std(dynamicOff_aligned_traces)/sqrt(size(dynamicOff_aligned_traces, 1));

mean_vizCL = mean(vizCL_aligned_traces);
mean_vizCL = mean_vizCL-(mean(mean_vizCL(1:10)));
sem_vizCL = std(vizCL_aligned_traces)/sqrt(size(vizCL_aligned_traces, 1));

    confplot(linspace(-lead_seconds,lag_seconds,size(dynamicOff_aligned_traces,2)), mean_dynOff, ...
        sem_dynOff, sem_dynOff, 'k')
    
    hold on
    
     confplot(linspace(-lead_seconds,lag_seconds,size(vizCL_aligned_traces,2)), mean_vizCL, ...
        sem_vizCL, sem_vizCL, 'b')   
    box off
    plot([-1000 1000], [0 0], 'k')
    
    xlim([-lead_seconds lag_seconds])
    set(gca, 'Fontsize', 25)
    xlabel('time to cool entry', 'fontsize', 30)
    ylabel('dF/F', 'fontsize', 30)
    
    mkdir('plots')
    cd('plots')
    prettyprint(f2, ['coincidence_mean_cool_alighed_traces_ROI_' num2str(c_roi) '_sequence'])
    
    cd(expdir)
    
    close all
end

end
