function add_img_to_behav_laptop(bdir, bfile, idir, syncdir)

[frame_4d, frame_MIP, img_frame_id, tstamp] = parse_azPL_imgfile(syncdir, idir, bdir);

load(bfile);

if ~isfield(expr.c_trial, 'bdata')
    expr.c_trial.bdata = expr.c_trial.data;
    expr.c_trial = rmfield(expr.c_trial, 'data');
end

expr.c_trial.idata.frame_4d = frame_4d;
expr.c_trial.idata.frame_MIP = frame_MIP;
expr.c_trial.idata.img_frame_id = img_frame_id;
expr.c_trial.idata.tstamp = tstamp;


expr.c_trial.bdata.c_iframe = nan(1, expr.c_trial.bdata.count);

imgid_idx = 1;
for ii = 1:length(expr.c_trial.bdata.c_iframe)
   
    if imgid_idx <= length(img_frame_id)
        if ii > img_frame_id(imgid_idx)  
            imgid_idx = imgid_idx+1;
        end
    end
    expr.c_trial.bdata.c_iframe(ii) = imgid_idx;
    
end



try
    dark_frames = expr.settings.dark_time*expr.settings.hz;
fix_frames = expr.settings.fix_time*expr.settings.hz;

pretrial_idx = expr.c_trial.bdata.c_iframe((nansum([dark_frames fix_frames])));
bg_4d = expr.c_trial.idata.frame_4d(:,:,:,1:pretrial_idx);
expr.c_trial.idata.bg_4d = mean(bg_4d, 4);
catch
    disp('no pretrial idx')
end

%expr.c_trial.idata.bg_frame = mode(expr.c_trial.idata.frame_MIP(:,:,1:end), 3);
%expr.c_trial.idata.bg_frame = mean(expr.c_trial.idata.frame_MIP(:,:,1:pretrial_idx), 3);
expr.c_trial.idata.bg_frame = prctile(expr.c_trial.idata.frame_MIP, 10, 3);
expr.c_trial.idata.df_frames = nan(size(expr.c_trial.idata.frame_MIP));
expr.c_trial.idata.df_frames_4d = nan(size(expr.c_trial.idata.frame_4d));
expr.c_trial.idata.new_df_mip = nan(size(expr.c_trial.idata.frame_MIP));

for ii = 1:size(expr.c_trial.idata.df_frames, 3)
   
    c_frame = expr.c_trial.idata.frame_MIP(:,:,ii);
    df_frame = (c_frame-expr.c_trial.idata.bg_frame)./expr.c_trial.idata.bg_frame;
    expr.c_trial.idata.df_frames(:,:,ii) = df_frame;
    
    c_stack = expr.c_trial.idata.frame_4d(:,:,:,ii);
    c_dF_stack = nan(size(c_stack));
    
    try
        for jj = 1:size(c_dF_stack, 3)
        
            c_slice = c_stack(:,:, jj);
            c_bg_slice = bg_4d(:,:,jj);
        
            c_dF_stack(:,:,jj) = (c_slice-c_bg_slice)./c_bg_slice;
        
        end
    
        expr.c_trial.idata.df_frames_4d(:,:,:,ii) = c_dF_stack;
        expr.c_trial.idata.new_df_mip(:,:,ii) = max(c_dF_stack, [], 3);
    
    catch
        disp('no 4d frames save')
    end
    
end

save(bfile, 'expr', '-v6');

