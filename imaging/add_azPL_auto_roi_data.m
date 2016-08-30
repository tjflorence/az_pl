function add_azPL_auto_roi_data(expdir)

cd(expdir)
exp_files = dir('env*');
ol_files = dir('OL*');

load('auto_roi_data.mat')
                 
%% add roi for each trial                             
for aa = 1:length(exp_files)
    
    load(exp_files(aa).name)
    if isfield(expr.c_trial, 'idata')

    expr.c_trial.idata.roi_traces = nan(length(roi_auto_struct), size(expr.c_trial.idata.mcorr_dF,3));
    
    for ii = 1:length(roi_auto_struct)
        for jj = 1:size(expr.c_trial.idata.mcorr_MIP,3)
        
            c_frame = expr.c_trial.idata.mcorr_MIP(:,:,jj);
            roi_pix = c_frame(roi_auto_struct(ii).BW==1);
        
            expr.c_trial.idata.auto_roi_traces(ii,jj) = mean(roi_pix);  
        
        end
        
            expr.c_trial.idata.auto_roi_traces(ii,:) = (expr.c_trial.idata.auto_roi_traces(ii,:)-mean(expr.c_trial.idata.auto_roi_traces(ii,:)) )...
                                                ./prctile(expr.c_trial.idata.auto_roi_traces(ii,:), 10);
    end
    
    save(exp_files(aa).name, 'expr', '-v6')
    end
    
    
end

for aa = 1:length(ol_files)
    
    load(ol_files(aa).name)
    if isfield(expr.c_trial, 'idata')

    expr.c_trial.idata.roi_traces = nan(length(roi_auto_struct), size(expr.c_trial.idata.mcorr_dF,3));
    
    for ii = 1:length(roi_auto_struct)
        for jj = 1:size(expr.c_trial.idata.mcorr_dF,3)
        
            c_frame = expr.c_trial.idata.mcorr_dF(:,:,jj);
            roi_pix = c_frame(roi_auto_struct(ii).BW==1);
        
            expr.c_trial.idata.auto_roi_traces(ii,jj) = mean(roi_pix);  
        
        end
    end
    
    save(ol_files(aa).name, 'expr', '-v6')
    
    end
end
