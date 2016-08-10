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

for ii = 1:5
   plot_azPl_experiment_summary(cl(ii).path);
   plot_azPl_experiment_summary(ucl(ii).path);
end

for ii = 1:4
   plot_azPl_experiment_summary(hcl(ii).path); 
end
    