function mcorr_azPL(exppath, ref_img)

if nargin < 2
    ref_img = [];
end

cd(exppath)

exp_files = dir('env*');
ol_files = dir('OL*');
all_files = [exp_files;ol_files];

num_expfiles = length(all_files);
mid_expfile = floor(num_expfiles/2);

if isempty(ref_img)
    
    found_idata = 0;
    c_file = 0;

    while found_idata == 0
   
        load(exp_files(mid_expfile+c_file).name)
    
        if isfield(expr.c_trial, 'idata')
        
            disp('building reference image')
            img_obj = nia_movie();
            img_obj.loadFlatMovie(expr.c_trial.idata.frame_MIP);
            [found_displ, export_ref_img] = nia_motionCompensate(img_obj, 1, 1, ...
                                            1, 1, [], []);
                                        
            ref_img = export_ref_img;
            
            y_vec = mean(ref_img, 2);
            max_y = max(y_vec);
            max_y_ind = find(y_vec==max_y);
        
            found_idata = 1;
        
            clear img_obj
        
        else
        
            c_file = c_file+1;
        
        end
    
    end
    
else
    
            y_vec = mean(ref_img, 2);
            max_y = max(y_vec);
            max_y_ind = find(y_vec==max_y);
    

end


for jj = 1:num_expfiles
    
    load(all_files(jj).name)
    
    if isfield(expr.c_trial, 'idata')

        %% remove some unused fields
        rm_fields = {'df_frames_4d', 'new_df_mip'};

        if isfield(expr.c_trial, rm_fields{1})
            expr.c_trial.idata = rmfield(expr.c_trial.idata, rm_fields);
        end
        
        expr.c_trial.idata.global_ref_img = ref_img;
        
        mean_frame =  mean(expr.c_trial.idata.frame_MIP, 3);
        
        y_vec = mean(mean_frame, 2);
        max_y = max(y_vec);
        cmax_y_ind = find(y_vec==max_y);
        
        expr.c_trial.idata.cmax_y_ind = cmax_y_ind;
        expr.c_trial.idata.target_y_ind = max_y_ind;
        expr.c_trial.idata.diff_y = expr.c_trial.idata.target_y_ind - expr.c_trial.idata.cmax_y_ind;
        
        pre_correct_shift = circshift(expr.c_trial.idata.frame_MIP, ...
                                        [round(expr.c_trial.idata.diff_y), 0, 0]);
                                    
        %% motion correct
        img_obj = nia_movie();
        img_obj.loadFlatMovie(pre_correct_shift);
                        

        nia_motionCompensate(img_obj, 1, 1, 1, 1, [], ref_img);
        corrected_img = img_obj.exportStruct(); 

        expr.c_trial.idata.mcorr_MIP = nan(size(expr.c_trial.idata.frame_MIP));

        for ii = 1:size(expr.c_trial.idata.mcorr_MIP, 3)
        
            expr.c_trial.idata.mcorr_MIP(:,:,ii) = corrected_img.slices(ii).channels.image;
        
        end

        clear img_obj
    
        expr.c_trial.idata.mcorr_baseframe = prctile(expr.c_trial.idata.mcorr_MIP, ...
                                        10, 3);
                                    
        expr.c_trial.idata.mcorr_dF = nan(size(expr.c_trial.idata.mcorr_MIP));

        for ii = 1:size(expr.c_trial.idata.mcorr_MIP, 3)

            expr.c_trial.idata.mcorr_dF(:,:,ii) = (expr.c_trial.idata.mcorr_MIP(:,:,ii)- ...
                                            expr.c_trial.idata.mcorr_baseframe)...
                                            ./expr.c_trial.idata.mcorr_baseframe;

        end



        save(all_files(jj).name, 'expr', '-v6')
    end

end