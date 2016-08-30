function add_azPL_oct_roi_data(expdir, trial)

cd(expdir)
exp_files = dir('env*');
ol_files = dir('OL*');

load('roi_data.mat')

                 
%% add roi for each trial                             
for aa = trial
    
    load(exp_files(aa).name)
    if isfield(expr.c_trial, 'idata')

    expr.c_trial.idata.roi_traces = nan(length(roi_struct), size(expr.c_trial.idata.df_frames,3));
    
    for ii = 1:length(roi_struct)
        for jj = 1:size(expr.c_trial.idata.df_frames,3)
        
            c_frame = expr.c_trial.idata.mcorr_MIP(:,:,jj);
            roi_pix = c_frame(roi_struct(ii).mask==1);
        
            expr.c_trial.idata.roi_traces(ii,jj) = mean(roi_pix);  
        
        end
        
            expr.c_trial.idata.roi_traces(ii,:) = (expr.c_trial.idata.roi_traces(ii,:)-mean(expr.c_trial.idata.roi_traces(ii,:)) )...
                                                ./prctile(expr.c_trial.idata.roi_traces(ii,:), 10);
                                            
    end
    

    save(exp_files(aa).name, 'expr', '-v7.3')
    end
    
    
end

for aa = 1:length(ol_files)
    
    load(ol_files(aa).name)
    if isfield(expr.c_trial, 'idata')

    expr.c_trial.idata.roi_traces = nan(length(roi_struct), size(expr.c_trial.idata.mcorr_dF,3));
    
    for ii = 1:length(roi_struct)
        for jj = 1:size(expr.c_trial.idata.mcorr_dF,3)
        
            c_frame = expr.c_trial.idata.frame_MIP(:,:,jj);
            roi_pix = c_frame(roi_struct(ii).mask==1);
        
            expr.c_trial.idata.roi_traces(ii,jj) = (mean(roi_pix)-mean(prctile(roi_pix, 10)))/mean(prctile(roi_pix, 10));  
        
        end
    end
    
    save(ol_files(aa).name, 'expr', '-v7')
    
    end
end
