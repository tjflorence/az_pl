bdir = '/Volumes/Untitled/2016-05-16/20160516211232_HC-Gal4xUAS-Chr, UAS-Gcamp6m_dir_resp';

cd(bdir)

exp_files = dir('env*');

p_n4 = [];
p_n15 = [];
p_01 = [];
p_35 = [];

for ii = 1:40
    
    load(exp_files(ii).name)
    
    if isfield(expr.c_trial, 'idata')
   
        if strfind(expr.c_trial.name, '-4')
            
            p_n4 = [p_n4; expr.c_trial.idata.roi_traces(2,1:80)];
            
        elseif strfind(expr.c_trial.name, '-1.5')

            p_n15 = [p_n15; expr.c_trial.idata.roi_traces(2,1:80)];

        elseif strfind(expr.c_trial.name, '01')
            
            p_01 = [p_01; expr.c_trial.idata.roi_traces(2,1:80)];
            
        elseif strfind(expr.c_trial.name, '3.5')
            
            p_35 = [p_35; expr.c_trial.idata.roi_traces(2,1:80)];

            
        end
        
    end
   
end

close all

for ii = 1:15
   
    hold on
    plot(p_01(ii,:), 'r')
    
end

plot(median(p_01), 'r', 'linewidth', 5)