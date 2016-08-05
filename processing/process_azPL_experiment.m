function process_azPL_experiment(expdir)

homedir = pwd;
cd(expdir);

exp_files = dir('env*');

% load first exp file to get params
load(exp_files(1).name)

% extract trial-level data
for ii = 1:length(exp_files)
    
    load(exp_files(ii).name)
    try 
        expr.c_trial.data = expr.c_trial.bdata;
    catch
    end
    
    expr = get_orient_stats(expr);
    expr = get_smooth_ball_stats(expr);
    expr = find_cool_time(expr);
    expr = get_PI_stats(expr);
    expr = get_circVec_stats(expr);
    
    save(exp_files(ii).name, 'expr')
    
end

% extract experiment-level data, save to summary mat
test_files = dir('*test*');
num_test_files = length(test_files);
summary_data.PI_2quad_30 = nan(1,num_test_files);
summary_data.PI_2quad_60 = nan(1,num_test_files);
summary_data.PI_allQuad_30 = nan(1,num_test_files);
summary_data.PI_allQuad_60 = nan(1,num_test_files);
summary_data.fix_Idx = nan(1, num_test_files);
summary_data.out_tQ = nan(1, num_test_files);
summary_data.norm_out = nan(1, num_test_files);

summary_data.vfwd_quad_idx = nan(1, num_test_files);
summary_data.vsum_quad_idx = nan(1, num_test_files);


train_files = dir('*train*');
num_train_files = length(train_files);

summary_data.cool_time = nan(1,num_train_files);
summary_data.time_to_cool = nan(1,num_train_files);
summary_data.left_cool = nan(1,num_train_files);
summary_data.time_to_leave = nan(1,num_train_files);


for ii = 1:num_test_files
    
    load(test_files(ii).name)
    summary_data.PI_2quad_30(ii) = expr.c_trial.data.PI_2quad_30;
    summary_data.PI_2quad_60(ii) = expr.c_trial.data.PI_2quad_60;
    summary_data.PI_allQuad_30(ii) = expr.c_trial.data.PI_allQuad_30;
    summary_data.PI_allQuad_60(ii) = expr.c_trial.data.PI_allQuad_60;

    summary_data.fix_Idx(ii) = expr.c_trial.data.circ_fixIdx;
    summary_data.out_tQ(ii) =  expr.c_trial.data.outside_tQ_time;
    summary_data.norm_out(ii) = expr.c_trial.data.PI_normOutside;
    
    summary_data.vfwd_quad_idx(ii) = expr.c_trial.data.vfwd_quad_idx;
    summary_data.vsum_quad_idx(ii) = expr.c_trial.data.vsum_quad_idx;
end

train_files = dir('*train*');
for ii = 1:length(train_files)
    
    load(train_files(ii).name)
    summary_data.cool_time(ii) = expr.c_trial.data.cool_time;
    summary_data.time_to_cool(ii) = expr.c_trial.data.time_to_cool;
    summary_data.left_cool(ii) = expr.c_trial.data.left_cool;
    summary_data.time_to_leave(ii) = expr.c_trial.data.time_to_leave;
    
end



save('summary_data.mat', 'summary_data')
cd(homedir)


end

function expr = find_cool_time(expr)
%% get time-related experiment stats
% cool time: time spent in cool zone
% time to cool: latency to cool zone
% left cool: did fly leave cool zone after locating it?
% time to leave: latency to leave cool zone after finding it

    cool_frames = find(expr.c_trial.data.laser_power < expr.settings.light_power);
    if ~isempty(cool_frames)
        cool_time = numel(cool_frames)/expr.settings.hz;
    
        first_cool_frame = cool_frames(1)-...
                        ((expr.settings.dark_time+expr.settings.fix_time)*expr.settings.hz);
                    
        time_to_cool = first_cool_frame/expr.settings.hz;
        
        diff_cool_frames = diff(cool_frames);
        left_frames = find(diff_cool_frames>1, 1, 'first');
        
        if ~isempty(left_frames)
            left_cool = 1;
            frames_to_leave = left_frames-first_cool_frame;
            time_to_leave = frames_to_leave/expr.settings.hz;
        else
            left_cool = 0;
            frames_to_leave = expr.c_trial.data.count-first_cool_frame;
            time_to_leave = frames_to_leave/expr.settings.hz;
        end
        
    else
        cool_time = nan;
        time_to_cool = nan;
        left_cool = nan;
        time_to_leave = nan;
    end
    
    % now, find time outside target quadrant
    th = expr.c_trial.data.trial_th;
    pi_1a = numel(find(th>315));
    pi_1b = numel(find(th<45));
    target_samples = pi_1a+pi_1b;
    tQ_time = target_samples/expr.settings.hz;
    
    expr.c_trial.data.cool_time = cool_time;
    expr.c_trial.data.time_to_cool = time_to_cool;
    expr.c_trial.data.left_cool = left_cool;
    expr.c_trial.data.time_to_leave = time_to_leave;
    
    expr.c_trial.data.tQ_time = tQ_time;
    expr.c_trial.data.outside_tQ_time = (expr.c_trial.trial_time - (expr.c_trial.dark_time+expr.c_trial.fix_time))-tQ_time;
end

function expr = get_smooth_ball_stats(expr)
%% smooth raw ball features
    
     dark_frames = expr.settings.dark_time*expr.settings.hz;
     fix_frames = expr.settings.fix_time*expr.settings.hz;
     trial_th = expr.c_trial.data.th( (1+dark_frames+fix_frames):expr.c_trial.data.count);
    
     trial_vfwd = expr.c_trial.data.vfwd( (1+dark_frames+fix_frames):expr.c_trial.data.count);
     trial_vss = expr.c_trial.data.vss( (1+dark_frames+fix_frames):expr.c_trial.data.count);
     trial_om = expr.c_trial.data.om( (1+dark_frames+fix_frames):expr.c_trial.data.count);

     sm_trial_vfwd = conv(trial_vfwd, ones(25,1)/25, 'same');
     sm_trial_vss = conv(trial_vss, ones(25,1)/25, 'same');
     sm_trial_om = conv(trial_om, ones(25,1)/25, 'same');
     
     sm_trial_vsum = abs(sm_trial_vfwd)+abs(sm_trial_vss)+abs(sm_trial_om);

     ang_vals = 0:10:350;
     vfwd_by_ang = [];
     vss_by_ang = [];
     vsum_by_ang = [];
     vss_abs_by_ang = [];
     for ii = 0:10:350;
         
         th_idx = find( (trial_th > ii) & (trial_th < (ii+10)) );
         if ~isempty(th_idx)
             
            vfwd_by_ang = [vfwd_by_ang mean(sm_trial_vfwd(th_idx))];
            vss_by_ang = [vss_by_ang mean(sm_trial_vss(th_idx))];
            vss_abs_by_ang = [vss_abs_by_ang mean(abs(sm_trial_vss(th_idx)))];
            vsum_by_ang = [vsum_by_ang mean(sm_trial_vsum(th_idx))];

         else
             
            vfwd_by_ang = [vfwd_by_ang nan];
            vss_by_ang = [vss_by_ang nan];
            vss_abs_by_ang = [vss_abs_by_ang nan];
            vsum_by_ang = [vsum_by_ang nan];
             
         end
         
         
     end
     
     expr.c_trial.data.sm_trial_vfwd = sm_trial_vfwd;
     expr.c_trial.data.sm_trial_vss = sm_trial_vss;
     expr.c_trial.data.sm_trial_om = sm_trial_om;
     expr.c_trial.data.sm_trial_vsum = sm_trial_vsum;
     
     expr.c_trial.data.vfwd_by_ang = vfwd_by_ang;
     expr.c_trial.data.vss_by_ang = vss_by_ang;
     expr.c_trial.data.vss_abs_by_ang = vss_abs_by_ang;
     expr.c_trial.data.vsum_by_ang = vsum_by_ang;
     expr.c_trial.data.ang_vals = ang_vals;
     
     %% now calculate quad idx
     % first, vfwd idx
     t1a = expr.c_trial.data.sm_trial_vfwd(trial_th<45);
     t2a = expr.c_trial.data.sm_trial_vfwd(trial_th>315);
     
     if ~isempty([t1a; t2a])
     
        t1 = mean([t1a; t2a]);
     
     else
        
        t1 = nan;
     
     end
     
     oIdx = find(trial_th>135 & trial_th<225);
     if ~isempty(oIdx)
        
         o1 = mean(expr.c_trial.data.sm_trial_vfwd(oIdx));
         
     else
         
         o1 = nan;
         
     end
     
     expr.c_trial.data.vfwd_quad_idx = t1;
     
     % second, vSum
     t1a = expr.c_trial.data.sm_trial_vsum(trial_th<45);
     t2a = expr.c_trial.data.sm_trial_vsum(trial_th>315);
     
     if ~isempty([t1a ;t2a])
     
        t1 = mean([t1a ;t2a]);
     
     else
        
        t1 = nan;
     
     end
     
     oIdx = find(trial_th>135 & trial_th<225);
     if ~isempty(oIdx)
        
         o1 = mean(expr.c_trial.data.sm_trial_vsum(oIdx));
         
     else
         
         o1 = nan;
         
     end
     
     expr.c_trial.data.vsum_quad_idx = (t1-o1)/(t1+o1);     
    

end


function expr = get_orient_stats(expr)
%% parses stats related to orientation
    dark_frames = expr.settings.dark_time*expr.settings.hz;
    fix_frames = expr.settings.fix_time*expr.settings.hz;

    dark_th = expr.c_trial.data.th(1:dark_frames);
    fix_th = expr.c_trial.data.th( (1+dark_frames): (dark_frames+fix_frames));
    trial_th = expr.c_trial.data.th( (1+dark_frames+fix_frames):expr.c_trial.data.count);

    dark_dTh = [0 diff(dark_th')];
    dark_dTh = fix_gap(dark_dTh);

    fix_dTh = [0 diff(fix_th')];
    fix_dTh = fix_gap(fix_dTh);

    trial_dTh = [0 diff(trial_th')];
    trial_dTh = fix_gap(trial_dTh);

    expr.c_trial.data.dark_th = dark_th;
    expr.c_trial.data.dark_dTh = dark_dTh;
    expr.c_trial.data.fix_th = fix_th;
    expr.c_trial.data.fix_dTh = fix_dTh;
    expr.c_trial.data.trial_th = trial_th;
    expr.c_trial.data.trial_dTh = trial_dTh;


end

function expr = get_PI_stats(expr)
%% produces preference index stats on per-trial basis
% PI_2quad_30 = PI for N/S quadrant for 30 sec;
% PI_2quad_60 = PI for N/S quadrant for 60 sec;
% PI_allQuad_30 = PI for N vs (all other)/3, 30;
% PI_allQuad_60 = PI for N vs (all other)/3, 60;

% first, PI_2quad_60
th = expr.c_trial.data.trial_th;

pi_1a = numel(find(th>315));
pi_1b = numel(find(th<45));
pi_1 = pi_1a+pi_1b;

pi_2 = numel(find(th>135 & th < 225));


PI_2quad_60 = (pi_1-pi_2)/(pi_1+pi_2);
PI_normOutside = (pi_2)/(pi_1+pi_2);

% second, PI_2quad_30;
th = expr.c_trial.data.trial_th(1:(30*expr.settings.hz));

pi_1a = numel(find(th>315));
pi_1b = numel(find(th<45));
pi_1 = pi_1a+pi_1b;

pi_2 = numel(find(th>135 & th < 225));

PI_2quad_30 = (pi_1-pi_2)/(pi_1+pi_2);

% third, PI_allQuad_30;
th = expr.c_trial.data.trial_th(1:(30*expr.settings.hz));

pi_1a = numel(find(th>315));
pi_1b = numel(find(th<45));
pi_1 = pi_1a+pi_1b;

pi_2 = (numel(th)-pi_1)/3;

PI_allQuad_30 = (pi_1-pi_2)/(pi_1+pi_2);


% finally, PI_allQuad_60;
th = expr.c_trial.data.trial_th;

pi_1a = numel(find(th>315));
pi_1b = numel(find(th<45));
pi_1 = pi_1a+pi_1b;

pi_2 = (numel(th)-pi_1)/3;

PI_allQuad_60 = (pi_1-pi_2)/(pi_1+pi_2);

expr.c_trial.data.PI_2quad_30 = PI_2quad_30;
expr.c_trial.data.PI_2quad_60 = PI_2quad_60;
expr.c_trial.data.PI_allQuad_30 = PI_allQuad_30;
expr.c_trial.data.PI_allQuad_60 = PI_allQuad_60;
expr.c_trial.data.PI_normOutside = PI_normOutside;

end

function expr = get_circVec_stats(expr)

    % set constant parameters
    box_length = 5;
    cutoff = .7;

    sample_length = box_length*expr.settings.hz;
    
    th = (expr.c_trial.data.trial_th)/360*2*pi; % convert to radians for circstats tbox

    circMean = [];
    circRad = [];
    
    for ii = 1:(length(th)-sample_length)
    
        c_data = th(ii: (ii+(sample_length-1)));
    
        c_mean = circ_mean(c_data);
        c_r = circ_r(c_data);
    
        circMean = [circMean, c_mean];
        circRad = [circRad, c_r];
    
    end

    % now, calculate an index
    tIdx = 0;
    for ii = 1:length(circMean)
   
        if circRad(ii) > cutoff
     
            if (circMean(ii) > -.78 && circMean(ii) < 0) ||...
                ( circMean(ii) < .78 && circMean(ii) > 0 )
                tIdx = tIdx+1;
            end
        
        end
    
    end

    oIdx = 0;
    for ii = 1:length(circMean)
   
        if circRad(ii) > cutoff
     
            if circMean(ii) > 2.356 || circMean(ii) < -2.356
                oIdx = oIdx+1;
            end
        
        end
    
    end
    fixIdx = (tIdx-oIdx)/(tIdx+oIdx);
    
    expr.c_trial.data.circCutoff    = cutoff;
    expr.c_trial.data.circMean      = circMean;
    expr.c_trial.data.circRad       = circRad;
    expr.c_trial.data.circ_fixIdx   = fixIdx;

end

function dTh_vals = fix_gap(dTh_vals)

    gap_inds = find(abs(dTh_vals)>359);
    for ii = 1:length(gap_inds)
       
        gap_val = dTh_vals(gap_inds(ii));
        if gap_val < 0
            corrected_val = gap_val+360;
        elseif gap_val > 0
            corrected_val = gap_val-360;
        end
        
        dTh_vals(gap_inds(ii)) = corrected_val;
        
        
    end
    
end