function mcorr_azPL(exppath)

cd(exppath)

exp_files = dir('env*');
num_expfiles = length(exp_files);
mid_expfile = floor(num_expfiles/2);

found_idata = 0;
c_file = 0;
while found_idata == 0
   
    load(exp_files(mid_expfile+c_file).name)
    
    if isfield(expr.c_trial, 'idata')
       
        mid_corr_frame = mean(expr.c_trial.idata.frame_MIP, 3);
        found_idata = 1;
        
    else
        
        c_file = c_file+1;
        
    end
    
end

for jj = 1:num_expfiles
    
    load(exp_files(jj).name)
    
    if isfield(expr.c_trial, 'idata')

        %% remove some unused fields
        rm_fields = {'df_frames_4d', 'new_df_mip'};

        expr.c_trial.idata = rmfield(expr.c_trial.idata, rm_fields);
        expr.c_trial.idata.mean_frame_within_trial = mid_corr_frame;

        %% motion correct
        img_obj = nia_movie();
        img_obj.loadFlatMovie(cat(3, expr.c_trial.idata.mean_frame_within_trial,...
                            expr.c_trial.idata.frame_MIP));
                        

        nia_motionCompensate(img_obj, 1, 1, 1, 1);
        corrected_img = img_obj.exportStruct(); 

        expr.c_trial.idata.mcorr_MIP = nan(size(expr.c_trial.idata.frame_MIP));

        for ii = 2:length(corrected_img.slices)
        
            expr.c_trial.idata.mcorr_MIP(:,:,ii-1) = corrected_img.slices(ii).channels.image;
        
        end

    
        expr.c_trial.idata.mcorr_baseframe = prctile(expr.c_trial.idata.mcorr_MIP, ...
                                        10, 3);
                                    
        expr.c_trial.idata.mcorr_dF = nan(size(expr.c_trial.idata.mcorr_MIP));

        for ii = 1:size(expr.c_trial.idata.mcorr_MIP, 3)

            expr.c_trial.idata.mcorr_dF(:,:,ii) = (expr.c_trial.idata.mcorr_MIP(:,:,ii)- ...
                                            expr.c_trial.idata.mcorr_baseframe)...
                                            ./expr.c_trial.idata.mcorr_baseframe;

        end



        save(exp_files(jj).name, 'expr', '-v7.3')
    end

end