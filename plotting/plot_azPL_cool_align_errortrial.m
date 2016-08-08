function plot_azPL_cool_align_errortrial(expdir, is_auto)


    bfiles = dir('env*');

    for ii = 1:length(bfiles)
       
        for jj = 1:length(bfiles)
            
            split_name = strsplit(bfiles(jj).name, '.mat');
            split_part = split_name{1};
            split_num = str2num(split_part(end-2:end));
            
            if split_num == ii
                
                bsort(ii).name = bfiles(jj).name;
                
            end
            
        end
        
    end

trial_files = bsort;

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
lag_seconds = 20;
test_map = [];

for c_roi = 1:length(roi_struct)
    
    aligned_traces = [];
    test_map = [];
    for c_trial = 1:length(trial_files)
       
        load(trial_files(c_trial).name)
        
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
                aligned_traces = [aligned_traces; c_trace];
                                
                if expr.c_trial.is_test
                    
                    test_map = [test_map 1];
                else
                    test_map = [test_map 0];
                    
                end                

            end
            
        end
        end
        
    end
    
    
close all



cMap =  [linspace(0, 1, size(aligned_traces, 1))' zeros(size(aligned_traces,1 ), 1), zeros(size(aligned_traces,1), 1)];

%% first plot - all of them aligned, error trial in blue
f1 = figure('color', 'w', 'units','normalized', 'visible', 'off');

for ii = 1:size(aligned_traces, 1)
   
    if test_map(ii)
        if ii > 1
        plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
            'color', 'b', 'linewidth', 2);
        else
         plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
            'color', 'k', 'linewidth', 2);
        end
    else
        plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
            'color', 'r', 'linewidth', 1);        
    end
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
    prettyprint(f1, ['cool_alighed_error_traces_ROI_' num2str(c_roi) '_sequence'])
    
    cd(expdir)
    
 % second plot - mean train trial, blue error trial   
    f2 = figure('color', 'w', 'units','normalized', 'visible', 'off');
    
    train_trials = find(test_map==0);
    train_align_traces = aligned_traces(train_trials, :);
    
    mean_response = mean(train_align_traces);
    sem_response = std(train_align_traces)/sqrt(numel(train_trials));
    
    confplot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), mean_response, ...
        sem_response, sem_response, 'r')
    
    hold on
    
    for ii = 1:size(aligned_traces, 1)
   
    if test_map(ii)
        if ii > 1
        plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
            'color', 'b', 'linewidth', 2);
        else
         plot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), aligned_traces(ii,:), ...
            'color', 'k', 'linewidth', 2);
        end
    end
    
    end
    
    
    box off
    plot([-1000 1000], [0 0], 'k')
    
    xlim([-lead_seconds lag_seconds])
    set(gca, 'Fontsize', 25)
    xlabel('time to cool entry', 'fontsize', 30)
    ylabel('dF/F', 'fontsize', 30)
    
    mkdir('plots')
    cd('plots')
    prettyprint(f2, ['cool_alighed_mean_error_traces_ROI_' num2str(c_roi) '_sequence'])
    
    close all
    
    cd(expdir)
    
%% third plot - mean of test-1 trial in red, test trial in blue

    f3 = figure('color', 'w', 'units','normalized', 'visible', 'off');
    
    test_trials = find(test_map==1);
    non_naive = test_trials(2:end);
    immediate_previous_train = non_naive-1;
    
    train_align_traces = aligned_traces(immediate_previous_train, :);
    test_align_traces = aligned_traces(non_naive, :);
    
    train_mean_response = mean(train_align_traces);
    train_sem_response = std(train_align_traces)/sqrt(numel(immediate_previous_train));
    
    test_mean_response = mean(test_align_traces);
    test_sem_response = std(test_align_traces)/sqrt(numel(non_naive));
    
    confplot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), train_mean_response, ...
        train_sem_response, train_sem_response, 'r')
    
    hold on
    
    confplot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), test_mean_response, ...
        test_sem_response, test_sem_response, 'b')
    
    
    box off
    plot([-1000 1000], [0 0], 'k')
    
    xlim([-lead_seconds lag_seconds])
    set(gca, 'Fontsize', 25)
    xlabel('time to cool entry', 'fontsize', 30)
    ylabel('dF/F', 'fontsize', 30)
    
    mkdir('plots')
    cd('plots')
    prettyprint(f3, ['cool_alighed_mean_n_minus_1_ROI_' num2str(c_roi) '_sequence'])
    
    close all
    
    cd(expdir)
    
 %% fourth plot - dummy version of n-1 plot

    f4 = figure('color', 'w', 'units','normalized', 'visible', 'off');
    
    
    test_trials = find(test_map==1);
    non_naive = test_trials(2:end);
    
    immediate_previous_train = non_naive-1;
    non_naive = immediate_previous_train-1;
    
    
    train_align_traces = aligned_traces(immediate_previous_train, :);
    test_align_traces = aligned_traces(non_naive, :);
    
    train_mean_response = mean(train_align_traces);
    train_sem_response = std(train_align_traces)/sqrt(numel(immediate_previous_train));
    
    test_mean_response = mean(test_align_traces);
    test_sem_response = std(test_align_traces)/sqrt(numel(non_naive));
    
    confplot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), train_mean_response, ...
        train_sem_response, train_sem_response, 'r')
    
    hold on
    
    confplot(linspace(-lead_seconds,lag_seconds,size(aligned_traces,2)), test_mean_response, ...
        test_sem_response, test_sem_response, 'b')
    
    
    box off
    plot([-1000 1000], [0 0], 'k')
    
    xlim([-lead_seconds lag_seconds])
    set(gca, 'Fontsize', 25)
    xlabel('time to cool entry', 'fontsize', 30)
    ylabel('dF/F', 'fontsize', 30)
    
    mkdir('plots')
    cd('plots')
    prettyprint(f4, ['cool_alighed_dummymean_n_minus_1_ROI_' num2str(c_roi) '_sequence'])
    
    close all
    
    cd(expdir)
    
    
    

end
