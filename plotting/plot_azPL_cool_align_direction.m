function plot_azPL_cool_align_direction(expdir, is_auto)

train_files = dir('env_train*');
%train_files = train_files(1:10);

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
lag_seconds = 10;

for c_roi = 1:length(roi_struct)
    
    aligned_traces = [];
    from_right = [];
    
    for c_trial = 1:length(train_files)
       
        load(train_files(c_trial).name)
        
        if isfield(expr.c_trial, 'bdata')
            yvals = (mod(expr.c_trial.bdata.th(1:expr.c_trial.bdata.count)+180, 360)/360)*96;
            cool_half_second = zeros(1,length(expr.c_trial.bdata.laser_power)-25);
            
            for ii = 1:(length(expr.c_trial.bdata.laser_power)-25)
                test_vec = expr.c_trial.bdata.laser_power(ii:ii+25);
                num_cool_frames = numel(find(test_vec<expr.settings.light_power));
                
                if num_cool_frames == length(test_vec)
                    
                    cool_half_second(ii) = 1;
                end
                
            end
         
        first_cool = find(cool_half_second==1,1, 'first');
        mean_lead_idx = mean(yvals((first_cool-10):first_cool));
        
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
                c_trace = c_trace-mean(c_trace(1:10));
                aligned_traces = [aligned_traces; c_trace];
                
                if mean_lead_idx > 48
                    from_right = [from_right; 1];
                else
                    from_right = [from_right; 0];
                end

            end
            
        end
        end
        
    end
    
    
close all

cMap =  [linspace(0, 1, size(aligned_traces, 1))' zeros(size(aligned_traces,1 ), 1), zeros(size(aligned_traces,1), 1)];

f1 = figure('color', 'w', 'units','normalized', 'visible', 'off');
for ii = 1:size(aligned_traces, 1)
   
    if from_right(ii) == 1
        trace_color = 'r';
    else
        trace_color = 'b';
    end
    
    plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
        'color',trace_color, 'linewidth', 1);
    
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
    prettyprint(f1, ['cool_alighed_direction_traces_ROI_' num2str(c_roi) '_sequence'])
    
    cd(expdir)
end
