close all

homedir = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160709';

expf(1).path = '/Volumes/sab_x/20160708222449_11f03_OL_stim';
expf(1).roi = 1;

expf(2).path = '/Volumes/sab_x/20160707173839_11f03_OL_stim';
expf(2).roi = 2;

expf(3).path = '/Volumes/sab_x/20160707114121_11f03_OL_stim';
expf(3).roi = 1;


cvals = ['rbk'];
x_vals = [0 .1 .5 1 5 15 30];

for ii = 1:3
    
    cd(expf(ii).path);
    load('roi_summary_data.mat')
    
    expf(ii).yval = [];
    
    for jj = 1:7
       
       expf(ii).yval = [expf(ii).yval summary_by_roi(expf(ii).roi).stim_type(jj).floor_to_peak];
        
    end
    
end


f1 = figure('units', 'normalized',...
    'Position', [0.0470 0.4095 0.4250 0.4781], ...
    'Color', 'w');
for ii = 1:3
    

    plot(x_vals, expf(ii).yval-(expf(ii).yval(1)), cvals(ii))
    hold on
    s1_p = scatter(x_vals, expf(ii).yval-(expf(ii).yval(1)), 200);
    
    set(s1_p, 'MarkerEdgeColor', cvals(ii), 'MarkerFaceColor', cvals(ii))
    
    hold on
    
end

plot([-100 100], [0 0], 'k:')
xlim([0 30])

set(gca, 'Fontsize', 30, 'YTick', [-.2 0 .2 .4])
xlabel('heat pulse length   \newline          (sec)', 'fontsize', 35)
ylabel('       dF/F \newline floor to peak')

box off

cd(homedir)
prettyprint(f1, 'floor_to_peak')