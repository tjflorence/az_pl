close all

bdir = '/Volumes/Untitled/2016-05-16/20160516211232_HC-Gal4xUAS-Chr, UAS-Gcamp6m_dir_resp';

cd(bdir)

exp_files = dir('env*');


p_01 = [];


for ii = 1:40
    
    load(exp_files(ii).name)
    
    if isfield(expr.c_trial, 'idata')
   
        trace = expr.c_trial.idata.roi_traces(1,1:80);
        max_val = max(trace);
        
        if max_val > .1 && (find(trace==max_val, 1, 'first') > 40 ...
                && find(trace==max_val, 1, 'first') < 60)
            
            p_01 = [p_01; trace];
            
        end

        
    end
   
end

close all

f1 = figure('color', 'w', 'units', 'normalized',...
    'position',  [0.0250    0.5352    0.4065 0.3714]);
xvals = linspace(0,6,80);

plot([-100 100], [0 0], 'k')
for ii = 1:size(p_01, 1)
   
    hold on
    plot(xvals, p_01(ii,:), 'r')
    
end

plot(xvals, mean(p_01), 'r', 'linewidth', 5)
ylim([-.1 .2])
xlim([0 6])

box off
set(gca, 'xtick', [0 3 6], 'ytick', [-.1 0 .1 .2], 'fontsize', 20)
xlabel('time', 'fontsize', 25)
ylabel('dF/F', 'fontsize', 25)

mkdir('plots')
cd('plots')
prettyprint(f1, 'df_summary')
cd('..')