hot_blind(1).path = '\\reiser_nas\tj\az_pl\processed\20160806152517_11f03_OL_stim';
hot_blind(1).roi = 1;

hot_blind(2).path = '\\reiser_nas\tj\az_pl\processed\20160807155741_11f03_OL_stim';
hot_blind(2).roi = 1;

hot_blind(3).path = '\\reiser_nas\tj\az_pl\processed\20160807211859_11f03_OL_stim';
hot_blind(3).roi = 1;

hot_blind(4).path = '\\reiser_nas\tj\az_pl\processed\20160805192338_11f03_OL_stim';
hot_blind(4).roi = 1;

cd(hot_blind(1).path);
load('multisense_summary_data.mat')
for ii = 1:length(summary_stim)
   
    multi_summary(ii).dF_collect = [];
    multi_summary(ii).ref_name = summary_stim(ii).ref_name;
    multi_summary(ii).test_name = summary_stim(ii).test_name;
    
    multi_summary(ii).viz_vec = summary_stim(ii).viz_vec;
    multi_summary(ii).therm_vec = summary_stim(ii).therm_vec;
    multi_summary(ii).s_tstamp = summary_stim(ii).s_tstamp;
    
end

for ii = 1:length(hot_blind)
   
    cd(hot_blind(ii).path);
    load('multisense_summary_data.mat')
    
    for jj = 1:20
        multi_summary(jj).dF_collect = [multi_summary(jj).dF_collect ;...
                                        summary_stim(jj).rois(hot_blind(ii).roi).mean_dF];
        multi_summary(jj).i_tstamp = summary_stim(jj).rois(hot_blind(ii).roi).i_tstamp;
    end
    
end

for jj = 1:20
        
        multi_summary(jj).mean_dF = mean(multi_summary(jj).dF_collect);
        multi_summary(jj).mean_dF = mean(multi_summary(jj).mean_dF(900:1200));
        multi_summary(jj).std_dF = std(multi_summary(jj).dF_collect);  
        
end