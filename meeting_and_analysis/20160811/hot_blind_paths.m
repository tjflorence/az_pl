print_dir = 'C:\matlab_root\az_pl\meeting_and_analysis\20160811';

%% file paths for experiments to include in summary
hot_blind(1).path = '\\reiser_nas\tj\az_pl\processed\20160806152517_11f03_OL_stim';
hot_blind(1).roi = 1;

hot_blind(2).path = '\\reiser_nas\tj\az_pl\processed\20160807155741_11f03_OL_stim';
hot_blind(2).roi = 1;

hot_blind(3).path = '\\reiser_nas\tj\az_pl\processed\20160807211859_11f03_OL_stim';
hot_blind(3).roi = 1;

hot_blind(4).path = '\\reiser_nas\tj\az_pl\processed\20160805192338_11f03_OL_stim';
hot_blind(4).roi = 1;

for ii = 1 : length(hot_blind)
   plot_azPL_motor_or_thermal(hot_blind(ii).path) 
end