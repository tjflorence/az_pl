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

for ii = 1:length(np)
    process_azPL_experiment(np(ii).path)
end