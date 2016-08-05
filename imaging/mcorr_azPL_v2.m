function mcorr_azPL_v2(exppath)

cd(exppath)

exp_files = dir('env*');
ol_files = dir('OL_*');
num_ol_files = length(ol_files);
num_expfiles = length(exp_files);
mid_expfile = floor(num_expfiles/2);

found_idata = 0;
c_file = 0;
while found_idata == 0
   
    load(exp_files(mid_expfile+c_file).name)
    
    if isfield(expr.c_trial, 'idata')
       
        mid_corr_frame = mean(expr.c_trial.idata.frame_MIP, 3);
        found_idata = 1;
        
        y_vec = mean(mid_corr_frame, 2);
        max_y = max(y_vec);
        max_y_ind = find(y_vec==max_y);
        
    else
        
        c_file = c_file+1;
        
    end
    
end


%for jj = [1 24]

for jj = 1:num_expfiles
    
    load(exp_files(jj).name)
    
    if isfield(expr.c_trial, 'idata')

        %% remove some unused fields
        rm_fields = {'df_frames_4d', 'new_df_mip'};

        if isfield(expr.c_trial, rm_fields{1})
            expr.c_trial.idata = rmfield(expr.c_trial.idata, rm_fields);
        end
        
        
        expr.c_trial.idata.mean_frame_within_trial = mid_corr_frame;
        expr.c_trial.idata.target_y_ind = max_y_ind;
        
        mean_frame =  mean(expr.c_trial.idata.frame_MIP, 3);
        y_vec = mean(mean_frame, 2);
        max_y = max(y_vec);
        cmax_y_ind = find(y_vec==max_y);
        
        expr.c_trial.idata.cmax_y_ind = cmax_y_ind;
        expr.c_trial.idata.diff_y = expr.c_trial.idata.target_y_ind - expr.c_trial.idata.cmax_y_ind;
        
        expr.c_trial.idata.mcorr_dF = circshift(expr.c_trial.idata.df_frames, ...
                                        [round(expr.c_trial.idata.diff_y), 0, 0]);


        save(exp_files(jj).name, 'expr', '-v7.3')
    end
end
    
for jj = 1:num_ol_files
    
    load(ol_files(jj).name)
    
    if isfield(expr.c_trial, 'idata')

        %% remove some unused fields
        rm_fields = {'df_frames_4d', 'new_df_mip'};

        if isfield(expr.c_trial, rm_fields{1})
            expr.c_trial.idata = rmfield(expr.c_trial.idata, rm_fields);
        end
        
        
        expr.c_trial.idata.mean_frame_within_trial = mid_corr_frame;
        expr.c_trial.idata.target_y_ind = max_y_ind;
        
        mean_frame =  mean(expr.c_trial.idata.frame_MIP, 3);
        y_vec = mean(mean_frame, 2);
        max_y = max(y_vec);
        cmax_y_ind = find(y_vec==max_y);
        
        expr.c_trial.idata.cmax_y_ind = cmax_y_ind;
        expr.c_trial.idata.diff_y = expr.c_trial.idata.target_y_ind - expr.c_trial.idata.cmax_y_ind;
        
        expr.c_trial.idata.mcorr_dF = circshift(expr.c_trial.idata.df_frames, ...
                                        [round(expr.c_trial.idata.diff_y), 0, 0]);


        save(ol_files(jj).name, 'expr', '-v7.3')
    end
end