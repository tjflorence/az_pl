clear all
close all

homedir = pwd;

np(1).path = '/Volumes/Untitled/behavior_only/2016-05-04/20160504113734_HC-Gal4x2b_az_PL';
np(2).path = '/Volumes/Untitled/behavior_only/2016-05-04/20160504140005_HC-Gal4x2b_az_PL';
np(3).path = '/Volumes/Untitled/behavior_only/2016-05-04/20160504171502_HC-Gal4x2b_az_PL';
np(4).path = '/Volumes/Untitled/behavior_only/2016-05-10/20160510130756_HC-Gal4x2b_az_PL';
np(5).path = '/Volumes/Untitled/behavior_only/2016-05-10/20160510155310_HC-Gal4x2b_az_PL';
np(6).path = '/Volumes/Untitled/behavior_only/2016-05-16/20160516131211_HC-Gal4x2b_az_PL';
np(7).path = '/Volumes/Untitled/behavior_only/2016-05-16/20160516170734_HC-Gal4x2b_az_PL';
np(8).path = '/Volumes/Untitled/behavior_only/2016-05-16/20160516174623_HC-Gal4x2b_az_PL';
np(9).path = '/Volumes/Untitled/behavior_only/2016-05-18/20160518122039_HC-Gal4x2b_az_PL';
np(10).path = '/Volumes/Untitled/behavior_only/2016-05-18/20160518133849_HC-Gal4x2b_az_PL';
np(11).path = '/Volumes/Untitled/behavior_only/2016-05-18/20160518164717_HC-Gal4x2b_az_PL';


np_vals = nan(length(np), 5);


for ii = 1:length(np)
   
    cd(np(ii).path)
    load('summary_data.mat')
    
    for jj = 1:5
        try
        np_vals(ii,jj) = summary_data.fix_Idx(jj);
        catch
        end
    end
end

f1 = figure('color', 'w', 'units', 'normalized', ...
    'Position', [.0357 .5219 .5661 .3762]);

plot([-100 100], [0 0], 'k')
cl_offset = 0;
for ii = 1:length(np)
   
    hold on
    
    PI_vals = np_vals(ii,:);
    plot([1 2 3 4 5]+cl_offset, PI_vals, 'r');
    
    c1 = scatter([1 2 3 4 5]+cl_offset, PI_vals, 200);
    set(c1, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');
    
    
end


xlim([.5 5.5])
%ylim([-1 1])

% plot cl mean
for ii = 1:5
    
    plot([ii-.2 ii+.2]+cl_offset, nanmean(np_vals(:,ii))*ones(1,2), 'r', 'linewidth', 5)
    c1 = scatter(nanmean([ii-.2 ii+.2]+cl_offset), nanmean(np_vals(:,ii)), 300);
    set(c1, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'LineWidth', 5)

end

set(gca, 'XColor', 'k', 'XTick', [1 2 3 4 5], 'YTick', [-1 -.5 0 .5 1], 'Fontsize', 25)
box off

ylabel('preference index')
xlabel('test #')

cd(homedir)
prettyprint(f1,'learning_measure_new_pref_idx')
close all


