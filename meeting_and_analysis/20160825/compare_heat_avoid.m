clear all

print_dir = 'C:\matlab_root\az_pl\meeting_and_analysis\20160825';

cMap = [0 0 0;...
         123 50 148;...
         44 123 182;...
         230 97 1;...
        215 25 28 ]./255;


ant_rm(1).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-18\20160818160452_11f03_az_PL-ant_rm';
ant_rm(2).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-18\20160818125648_11f03_az_PL_ant_rm';
ant_rm(3).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-18\20160818105640_11f03_az_PL_ant_rm';

wt(1).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-23\20160823093400_VT046828_az_PL';
wt(2).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-22\20160822211425_VT046828_az_PL';
wt(3).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-22\20160822201603_VT046828_az_PL';

ft_11f03(1).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-25\20160825182948_11f03_az_PL';
ft_11f03(2).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-25\20160825142542_11f03_az_PL';
ft_11f03(3).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-23\20160823105538_11f03_az_PL';
ft_11f03(4).path = '\\reiser_nas\tj\az_pl\behavior\2016-08-18\20160818205601_11f03_az_PL';


% for ii = 1:length(wt)
%    
%     process_azPL_experiment(ant_rm(ii).path)
%     process_azPL_experiment(wt(ii).path)
%     
% end
% 
% for ii = 1:length(ft_11f03)
%    
%     process_azPL_experiment(ft_11f03(ii).path)
%     
% end

ant_rm_PI   = nan(length(ant_rm), 5);
wt_PI       = nan(length(wt), 5);
ft_11f03_PI    = nan(length(ft_11f03), 5);

for ii = 1:length(ant_rm)
   
    cd(ant_rm(ii).path)
    load('summary_data.mat')
    
    for jj = 1:5
        if jj == 1

            ant_rm_PI(ii,jj) = summary_data.PI_2quad_60(1);
        
        elseif jj == 5
            
            ant_rm_PI(ii,jj) = summary_data.PI_2quad_60(2);
            
        elseif jj == 2
            
            ant_rm_PI(ii,jj) = mean(summary_data.train_quadPI(1:5));
        
        elseif jj == 3
            
            ant_rm_PI(ii,jj) = mean(summary_data.train_quadPI(6:10));

        elseif jj == 4
            
            ant_rm_PI(ii,jj) = mean(summary_data.train_quadPI(11:15));     

        end
    end
    
    
end
ant_rm_PI(isnan(ant_rm_PI)) = 0;

for ii = 1:length(wt)
   
    cd(wt(ii).path)
    load('summary_data.mat')
    
    for jj = 1:5
        if jj == 1

            wt_PI(ii,jj) = summary_data.PI_2quad_60(1);
        
        elseif jj == 5
            
            wt_PI(ii,jj) = summary_data.PI_2quad_60(2);
            
        elseif jj == 2
            
            wt_PI(ii,jj) = mean(summary_data.train_quadPI(1:5));
        
        elseif jj == 3
            
            wt_PI(ii,jj) = mean(summary_data.train_quadPI(6:10));

        elseif jj == 4
            
            wt_PI(ii,jj) = mean(summary_data.train_quadPI(11:15));     

        end
    end
    
    
end
wt_PI(isnan(wt_PI)) = 0;

for ii = 1:length(ft_11f03)
   
    cd(ft_11f03(ii).path)
    load('summary_data.mat')
    
    for jj = 1:5
        if jj == 1

            ft_11f03_PI(ii,jj) = summary_data.PI_2quad_60(1);
        
        elseif jj == 5
            
            ft_11f03_PI(ii,jj) = summary_data.PI_2quad_60(2);
            
        elseif jj == 2
            
            ft_11f03_PI(ii,jj) = mean(summary_data.train_quadPI(1:5));
        
        elseif jj == 3
            
            ft_11f03_PI(ii,jj) = mean(summary_data.train_quadPI(6:10));

        elseif jj == 4
            
            ft_11f03_PI(ii,jj) = mean(summary_data.train_quadPI(11:15));     

        end
    end
    
    
end
ft_11f03_PI(isnan(ft_11f03_PI)) = 0;

f1 = figure('color', 'w', 'units', 'normalized', 'Position', [0.0730    0.6281    0.3434    0.2625]);

rm_offset = -.1;
for ii = 1:size(ant_rm_PI, 1)
    
        sp_1 = scatter([1:5]+rm_offset, ant_rm_PI(ii,:), 100);
        set(sp_1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'b')
        
        hold on
        plot([1:5]+rm_offset, ant_rm_PI(ii,:), 'color','b')
    
        
end

wt_offset = 0;
for ii = 1:size(wt_PI, 1)
    
        sp_1 = scatter([1:5]+wt_offset, wt_PI(ii,:), 100);
        set(sp_1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'k')
        
        hold on
        plot([1:5]+wt_offset, wt_PI(ii,:), 'color', 'k')
    
        
end

ft_11f03_offset = .1;
for ii = 1:size(ft_11f03_PI, 1)
    
        sp_1 = scatter([1:5]+ft_11f03_offset, ft_11f03_PI(ii,:), 100);
        set(sp_1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cMap(5,:))
        
        hold on
        plot([1:5]+ft_11f03_offset, ft_11f03_PI(ii,:), 'color', cMap(5,:))
    
        
end

plot([-100 100], [0 0], 'k')

xlim([.6 5.4])
ylim([-1 1])
set(gca, 'XTick', [1:5], 'XTickLabel', {'baseline', 'train \newline1:5', ...
                                            'train \newline6:10', 'train \newline11:15', ...
                                            'test'}, 'Fontsize', 20)


cd(print_dir)
prettyprint(f1, 'ant_removed_behavior')































































