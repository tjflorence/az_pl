function plot_azPL_cool_align_sequence(expdir, is_auto)

train_files = dir('env_train*');
train_files = train_files(1:10);

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
    
    aligned_traces = [];
    for c_trial = 1:length(train_files)
       
        load(train_files(c_trial).name)
        
        first_cool = find(expr.c_trial.bdata.laser_power<-4, 1, 'first');
        
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
                aligned_traces = [aligned_traces; c_trace];

            end
            
        end
        
    end
    
    
close all

cMap =  [linspace(0, 1, size(aligned_traces, 1))' zeros(size(aligned_traces,1 ), 1), zeros(size(aligned_traces,1), 1)];

f1 = figure('color', 'w', 'units','normalized', 'visible', 'off');
for ii = 1:size(aligned_traces, 1)
   
    plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
        'color', cMap(ii,:), 'linewidth', 1);
    
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
    prettyprint(f1, ['cool_alighed_traces_ROI_' num2str(c_roi) '_sequence'])
    
    cd(expdir)
end
