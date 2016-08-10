clear all

%% immobile fly, all dark (v1 experiment)
cviz_1(1).path = '/Volumes/tj-1/az_pl/processed/20160706144253_11f03_OL_stim'
cviz_1(1).notes =  'weird prep, first exp';

cviz_1(2).path = '/Volumes/tj-1/az_pl/processed/20160707114121_11f03_OL_stim'
cviz_1(3).path = '/Volumes/tj-1/az_pl/processed/20160707173839_11f03_OL_stim'
cviz_1(4).path = '/Volumes/tj-1/az_pl/processed/20160708222449_11f03_OL_stim'

%% antenna removed, immobile fly, all dark
cviz_2(1).path = '/Volumes/tj-1/az_pl/processed/20160710142529_11f03-ant_rm_OL_stim'
cviz_2(2).path = '/Volumes/tj-1/az_pl/processed/20160710192847_11f03-ant_rm_OL_stim'
cviz_2(3).path = '/Volumes/tj-1/az_pl/processed/20160711194317_11f03-ant_rm_OL_stim'

%% behaving fly, dark + CL (PL pat)
cviz_3(1).path = '/Volumes/tj-1/az_pl/processed/20160714104717_11f03_OL_stim'
cviz_3(2).path = '/Volumes/tj-1/az_pl/processed/20160714183910_11f03_OL_stim'
cviz_3(3).path = '/Volumes/tj-1/az_pl/processed/20160725_combo_fly_1/20160725172927_11f03_OL_stim'
cviz_3(4).path = '/Volumes/tj-1/az_pl/processed/20160725_combo_fly_2/20160725214714_11f03_OL_stim'

%% behaving fly, dark + CL (opto / uniform)
cviz_4(1).path = '/Volumes/tj-1/az_pl/processed/20160728_combo_fly_1/20160728154602_11f03-uniblocks_OL_stim'
cviz_4(2).path = '/Volumes/tj-1/az_pl/processed/20160728_combo_fly_2/20160728182302_11f03-uniblocks_OL_stim'
cviz_4(3).path = '/Volumes/tj-1/az_pl/processed/20160729_combo_fly_3/20160729204351_11f03-uniblocks_OL_stim'
cviz_4(4).path = '/Volumes/tj-1/az_pl/processed/20160729_combo_fly_2/20160729173026_11f03-uniblocks_OL_stim'
cviz_4(5).path = '/Volumes/tj-1/az_pl/processed/20160729_combo_fly_1/20160729134155_11f03-uniblocks_OL_stim'


%% dark type responses - look at combo fly 2
dark_type(1).path = cviz_3(1).path;
dark_type(1).roi = 5;

dark_type(2).path = cviz_3(3).path;
dark_type(2).roi = 3;

dark_type(3).path = cviz_3(4).path;
dark_type(3).roi = 7;

dark_type(4).path = cviz_4(5).path;
dark_type(4).roi = 3;

dark_type(5).path = cviz_4(2).path;
dark_type(5).roi = 4;

%% light type responses

light_type(1).path = cviz_3(3).path;
light_type(1).roi = 2;

light_type(2).path = cviz_4(5).path;
light_type(2).roi = 1;

light_type(3).path = cviz_4(2).path;
light_type(3).roi = 2;

%% collect experiment data
for c_exp = 1:length(light_type);
    cd(light_type(c_exp).path)

    c_roi = light_type(c_exp).roi;
    pulse_30 = dir('*stim_30*');
    dark_trial = 0;
    light_trial = 0;

    for ii = 1:length(pulse_30)
   
        load(pulse_30(ii).name)
        if isfield(expr.c_trial, 'idata')
            if expr.c_trial.viz_type == 0
                dark_trial = dark_trial+1;
                light_type_summary(c_exp).dark_data{dark_trial} = ...
                expr.c_trial.idata.auto_roi_traces(c_roi,:);
            else
                light_trial = light_trial+1;
                light_type_summary(c_exp).light_data{light_trial} = ...
                expr.c_trial.idata.auto_roi_traces(c_roi,:); 
            end
        end
    
    end

end

%% interpolate to same length to be able to average
tlen = 10000;
dark_summary = nan(length(dark_type), tlen);
light_summary = nan(length(dark_type), tlen);

for c_exp = 1:length(dark_type);

    dark_interp = nan(numel(light_type_summary(c_exp).dark_data), tlen);
    light_interp = nan(numel(light_type_summary(c_exp).light_data), tlen);

    for ii = 1:numel(light_type_summary(c_exp).dark_data)
       
        c_data = light_type_summary(c_exp).dark_data{ii};
        dark_interp(ii,:) = spline(1:length(c_data), c_data,...
                                linspace(1, length(c_data), tlen ));
        
    end

    for ii = 1:numel(light_type_summary(c_exp).light_data)
       
        c_data = light_type_summary(c_exp).light_data{ii};
        light_interp(ii,:) = spline(1:length(c_data), c_data,...
                                linspace(1, length(c_data), tlen ));
        
    end
    
    light_type_summary(c_exp).dark_mean = mean(dark_interp, 1);
    light_type_summary(c_exp).light_mean = mean(light_interp, 1);

    dark_summary(c_exp, :) = mean(dark_interp, 1);
    light_summary(c_exp, :) = mean(light_interp, 1);

end


mean_dark_response = mean(dark_summary);
mean_light_response = mean(light_summary);

close all
print_dir = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160801';

f1 = figure('color', 'w', 'units', 'normalized',...
    'position', [0.0262 0.2210 0.4845 0.6686], 'visible', 'on')

s1 = subplot(3,1,1);
plot([-100000 100000], [0 0], 'k')
for ii = 1:length(dark_type_summary)
   
    hold on
    plot(dark_summary(ii,:), 'color', [.5 .5 .5])
    
end
box off
set(gca, 'XTick', [], 'YTick', [0 .5 1], 'Fontsize', 25)

plot(mean(dark_summary), 'k', 'linewidth', 3);
xlim([0 tlen])
ylim([-.1 .5])

s2 = subplot(3,1,2);
plot([-100000 100000], [0 0], 'k')
for ii = 1:length(dark_type_summary)
   
    hold on
    plot(light_summary(ii,:), 'color', 'b')
    
end

plot(mean(light_summary), 'b', 'linewidth', 3);
xlim([0 tlen])
ylim([-.1 .5])

box off
set(gca, 'XTick', [], 'YTick', [0 .5 1], 'Fontsize', 25)

ylab = ylabel('dF/F', 'Fontsize', 30);
set(ylab, 'Position', get(ylab, 'Position')+[0 1 0]);


s3 = subplot(3,1,3);
plot(expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count), ...
    (expr.c_trial.bdata.laser_power(1:expr.c_trial.bdata.count)+4.99)/5, ...
    'color', 'r', 'linewidth', 3)
box off

xlim([0 120])
set(gca, 'XTick', [30 60 90 ], 'YTick', [0 1], 'Fontsize', 25)
xlabel('time (sec)', 'fontsize', 30)
ylabel('light power', 'fontsize', 30)

cd(print_dir)
prettyprint(f1, 'light_type_+30sec_pulse_response')