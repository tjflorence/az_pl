clear all
close all

homedir = pwd;

cl(1).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-19/20160419154922_HC-Gal4x5a_az_PL';
cl(2).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420132338_HC-Gal4x5a_az_PL';
cl(3).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420140218_HC-Gal4x5a_az_PL';
cl(4).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420153628_HC-Gal4x5a_az_PL';
cl(5).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420165304_HC-Gal4x5a_az_PL';

ucl(1).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-19/20160419171114_HC-Gal4x5a_az_PL';
ucl(2).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420122722_HC-Gal4x5a_az_PL';
ucl(3).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420125033_HC-Gal4x5a_az_PL';
ucl(4).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420143203_HC-Gal4x5a_az_PL';
ucl(5).path = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160421/data/behavior/2016-04-20/20160420172347_HC-Gal4x5a_az_PL';

hcl(1).path = '/Volumes/Untitled/behavior_only/2016-04-25/20160425122134_HC-Gal4x2b_az_PL';
hcl(2).path = '/Volumes/Untitled/behavior_only/2016-04-25/20160425142238_HC-Gal4x2b_az_PL';
hcl(3).path = '/Volumes/Untitled/behavior_only/2016-04-25/20160425165827_HC-Gal4x2b_az_PL';
hcl(4).path = '/Volumes/Untitled/behavior_only/2016-05-02/20160502155938_HC-Gal4x2b_az_PL';

cl_vals = nan(length(cl), 2);
hcl_vals = nan(length(hcl), 2);
ucl_vals = nan(length(ucl), 2);


for ii = 1:length(cl)
   
    cd(cl(ii).path)
    load('summary_data.mat')
    
    cl_vals(ii,1) = summary_data.out_tQ(1)/60;
    cl_vals(ii,2) = summary_data.out_tQ(2)/60;
    
end

for ii = 1:length(hcl)
   
    cd(hcl(ii).path)
    load('summary_data.mat')
    
    hcl_vals(ii,1) = summary_data.out_tQ(1)/60;
    hcl_vals(ii,2) = summary_data.out_tQ(2)/60;
    
end

for ii = 1:length(ucl)
   
    cd(ucl(ii).path)
    load('summary_data.mat')
    
    ucl_vals(ii,1) = summary_data.out_tQ(1)/60;
    ucl_vals(ii,2) = summary_data.out_tQ(2)/60;
    
end

f1 = figure('color', 'w', 'position', [112 278 559 657]);

cl_offset = -.1;
hcl_offset = 0;
ucl_offset = .1;

plot([-100 100], [0 0], 'k')

for ii = 1:length(cl)
   
    hold on
    
    PI_vals = cl_vals(ii,:);
    plot([1 2]+cl_offset, PI_vals, 'r');
    
    c1 = scatter([1 2]+cl_offset, PI_vals, 200);
    set(c1, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');
    
    
end

for ii = 1:length(hcl)
   
    hold on
    
    PI_vals = hcl_vals(ii,:);
    plot([1 2]+hcl_offset, PI_vals, 'b');
    
    c1 = scatter([1 2]+hcl_offset, PI_vals, 200);
    set(c1, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none');
    
    
end

for ii = 1:length(ucl)
   
    hold on
    
    PI_vals = ucl_vals(ii,:);
    plot([1 2]+ucl_offset, PI_vals, 'k');
    
    c1 = scatter([1 2]+ucl_offset, PI_vals, 200);
    set(c1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');
    
    
end

xlim([.5 2.5])
%ylim([-1 1])

% plot cl mean
plot([.8 1.2]+cl_offset, mean(cl_vals(:,1))*ones(1,2), 'r', 'linewidth', 5)
c1 = scatter(mean([.8 1.2]+cl_offset), mean(cl_vals(:,1)), 300);
set(c1, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'LineWidth', 5)

plot([1.8 2.2]+cl_offset, mean(cl_vals(:,2))*ones(1,2), 'r', 'linewidth', 5)
c1 = scatter(mean([1.8 2.2]+cl_offset), mean(cl_vals(:,2)), 300);
set(c1, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'LineWidth', 5)

% plot hcl mean
plot([.8 1.2]+hcl_offset, mean(hcl_vals(:,1))*ones(1,2), 'b', 'linewidth', 5)
c1 = scatter(mean([.8 1.2]+hcl_offset), mean(hcl_vals(:,1)), 300);
set(c1, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none', 'LineWidth', 5)

plot([1.8 2.2]+hcl_offset, mean(hcl_vals(:,2))*ones(1,2), 'b', 'linewidth', 5)
c1 = scatter(mean([1.8 2.2]+hcl_offset), mean(hcl_vals(:,2)), 300);
set(c1, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none', 'LineWidth', 5)

% plot ucl mean
plot([.8 1.2]+ucl_offset, mean(ucl_vals(:,1))*ones(1,2), 'k', 'linewidth', 5)
c1 = scatter(mean([.8 1.2]+ucl_offset), mean(ucl_vals(:,1)), 300);
set(c1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineWidth', 5)

plot([1.8 2.2]+ucl_offset, mean(ucl_vals(:,2))*ones(1,2), 'k', 'linewidth', 5)
c1 = scatter(mean([1.8 2.2]+ucl_offset), mean(ucl_vals(:,2)), 300);
set(c1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineWidth', 5)


set(gca, 'XColor', 'k', 'XTick', [1 2], 'XTickLabels', {'pre-test', 'post-test'}, ...
    'YTick', [0 .5 1], 'YTickLabel', {'0', '30', '60'},'Fontsize', 25)
box off

ylabel('  time outside\newlinetarget quadrant')
ylim([.3 1])
cd(homedir)

prettyprint(f1,'learning_measure_timeout_idx')
close all


