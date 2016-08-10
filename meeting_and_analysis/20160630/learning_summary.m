close all
clear all

print_dir = '/Users/florencet/Documents/matlab_root/az_pl/meeting_and_analysis/20160630';

gmr_11f03(1).path = '/Volumes/tj/az_pl/processed/20160627205056_11F03_az_PL';
gmr_11f03(2).path = '/Volumes/tj/az_pl/processed/20160627164538_11F03_az_PL';
gmr_11f03(3).path = '/Volumes/tj/az_pl/processed/20160624172843_11F03_az_PL';
gmr_11f03(4).path = '/Volumes/tj/az_pl/processed/20160624142329_11F03_az_PL';
gmr_11f03(5).path = '/Volumes/tj/az_pl/processed/20160620180741_11F03_az_PL';
gmr_11f03(6).path = '/Volumes/tj/az_pl/processed/20160620112609_11F03_az_PL';
gmr_11f03(7).path = '/Volumes/tj/az_pl/processed/20160618120700_11F03_az_PL';

gmr_28e01(1).path = '/Volumes/tj/az_pl/processed/20160612131258_28E01x2b_az_PL';
gmr_28e01(2).path = '/Volumes/tj/az_pl/processed/20160612145708_28E01x2b_az_PL';

gmr_57c10(1).path = '/Volumes/tj/az_pl/processed/20160612185116_HC-2b_az_PL';

gmr_60d05(1).path = '/Volumes/tj/az_pl/processed/20160613193450_60D05_az_PL';
gmr_60d05(2).path = '/Volumes/tj/az_pl/processed/20160621113818_60d05_az_PL';

gmr_41b12(1).path = '/Volumes/tj/az_pl/processed/20160621151111_41b12_az_PL';

cMap = [125 125 125;...
        255 240 60;...
        255 141 154;...
        91 113 204;...
        59 178 101; ...
        255 0 0]./255;


for ii = 1:length(gmr_11f03)
   
    cd(gmr_11f03(ii).path)
    test_files = dir('*test*');
    pi_vec = [];
    
    for jj = 1:length(test_files)
        

    
        load(test_files(jj).name);
        
        try
            expr.c_trial.bdata = expr.c_trial.data;
        end
        
        pi_vec = [pi_vec expr.c_trial.bdata.PI_2quad_60];
        
    end
    
    gmr_11f03(ii).pi_vec = pi_vec;
    
end


for ii = 1:length(gmr_28e01)
   
    cd(gmr_28e01(ii).path)
    test_files = dir('*test*');
    pi_vec = [];
    
    for jj = 1:length(test_files)
        

    
        load(test_files(jj).name);
        
        try
            expr.c_trial.bdata = expr.c_trial.data;
        end
        
        pi_vec = [pi_vec expr.c_trial.bdata.PI_2quad_60];
        
    end
    
    gmr_28e01(ii).pi_vec = pi_vec;
    
end

for ii = 1:length(gmr_57c10)
   
    cd(gmr_57c10(ii).path)
    test_files = dir('*test*');
    pi_vec = [];
    
    for jj = 1:length(test_files)
        

    
        load(test_files(jj).name);
        
        try
            expr.c_trial.bdata = expr.c_trial.data;
        end
        
        pi_vec = [pi_vec expr.c_trial.bdata.PI_2quad_60];
        
    end
    
    gmr_57c10(ii).pi_vec = pi_vec;
    
end

for ii = 1:length(gmr_60d05)
   
    cd(gmr_60d05(ii).path)
    test_files = dir('*test*');
    pi_vec = [];
    
    for jj = 1:length(test_files)
        

    
        load(test_files(jj).name);
        
        try
            expr.c_trial.bdata = expr.c_trial.data;
        end
        
        pi_vec = [pi_vec expr.c_trial.bdata.PI_2quad_60];
        
    end
    
    gmr_60d05(ii).pi_vec = pi_vec;
    
end

for ii = 1:length(gmr_41b12)
   
    cd(gmr_41b12(ii).path)
    test_files = dir('*test*');
    pi_vec = [];
    
    for jj = 1:length(test_files)
        

    
        load(test_files(jj).name);
        
        try
            expr.c_trial.bdata = expr.c_trial.data;
        end
        
        pi_vec = [pi_vec expr.c_trial.bdata.PI_2quad_60];
        
    end
    
    gmr_41b12(ii).pi_vec = pi_vec;
    
end

f1 = figure('units', 'normalized', 'position', [0.0244 0.3952 0.4804 0.5133],...
    'color', 'w');
for ii = 1:length(gmr_11f03)
   
    plot(1:length(gmr_11f03(ii).pi_vec), gmr_11f03(ii).pi_vec,...
        'color', cMap(1,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_11f03(ii).pi_vec), gmr_11f03(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(1,:), 'MarkerEdgeColor', 'k');
    
    
end

for ii = 1:length(gmr_28e01)
   
    plot(1:length(gmr_28e01(ii).pi_vec), gmr_28e01(ii).pi_vec,...
        'color', cMap(2,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_28e01(ii).pi_vec), gmr_28e01(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(2,:), 'MarkerEdgeColor', 'k');
    
    
end

for ii = 1:length(gmr_57c10)
   
    plot(1:length(gmr_57c10(ii).pi_vec), gmr_57c10(ii).pi_vec,...
        'color', cMap(3,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_57c10(ii).pi_vec), gmr_57c10(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(3,:), 'MarkerEdgeColor', 'k');
    
    
end

for ii = 1:length(gmr_60d05)
   
    plot(1:length(gmr_60d05(ii).pi_vec), gmr_60d05(ii).pi_vec,...
        'color', cMap(4,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_60d05(ii).pi_vec), gmr_60d05(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(4,:), 'MarkerEdgeColor', 'k');
    
    
end

for ii = 1:length(gmr_41b12)
   
    plot(1:length(gmr_41b12(ii).pi_vec), gmr_41b12(ii).pi_vec,...
        'color', cMap(5,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_41b12(ii).pi_vec), gmr_41b12(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(5,:), 'MarkerEdgeColor', 'k');
    
    
end

box off

plot([.5 5.5], [0 0], 'k')
xlim([.5 5.5])
ylabel('PI', 'fontsize', 30)
xlabel('test #',  'fontsize', 30)

set(gca, 'XTick', [1 2 3 4 5], 'fontsize', 25)

text(4.7, .9, '11f03>GCaMP6m', 'fontsize', 20, 'color', cMap(1,:));
text(4.7, .7, '28e01>GCaMP6m', 'fontsize', 20, 'color', cMap(2,:));
text(4.7, .5, '57c10>GCaMP6m', 'fontsize', 20, 'color', cMap(3,:));
text(4.7, .3, '60d05>GCaMP6m', 'fontsize', 20, 'color', cMap(4,:));
text(4.7, .1, '41b12>GCaMP6m', 'fontsize', 20, 'color', cMap(5,:));

cd(print_dir)

prettyprint(f1, 'learning_summary')


f2 = figure('units', 'normalized', 'position', [0.0244 0.3952 0.4804 0.5133],...
    'color', 'w');
for ii = 1:length(gmr_11f03)
   
    plot(1:length(gmr_11f03(ii).pi_vec), gmr_11f03(ii).pi_vec,...
        'color', cMap(1,:));
    
    hold on
    
    sp1 = scatter(1:length(gmr_11f03(ii).pi_vec), gmr_11f03(ii).pi_vec, 100);
    set(sp1, 'MarkerFaceColor', cMap(1,:), 'MarkerEdgeColor', 'k');
    
    
end

box off

plot([.5 5.5], [0 0], 'k')
xlim([.5 5.5])
ylabel('PI', 'fontsize', 30)
xlabel('test #',  'fontsize', 30)

set(gca, 'XTick', [1 2 3 4 5], 'fontsize', 25)

text(4.7, .9, '11f03>GCaMP6m', 'fontsize', 20, 'color', cMap(1,:));

cd(print_dir)

prettyprint(f2, 'learning_summary_only_11f03')
close all
