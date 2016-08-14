clear all 
close all
delete(instrfind)
imaqreset
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'dir_resp';
expi.settings.geno       = 'tdc2-gal4, UAS-Gcamp6m';
expi.settings.notes      = 'ST exp1';
expi.settings.img_name   = 'fly 1';
expi.settings.age        = 4;
expi.settings.date       = datestr(now, 'yyyymmddHHMMSS');
expi.settings.fname      = [expi.settings.date '_' expi.settings.geno '_' ...
                                expi.settings.name];
expi.settings.savedir    = 'C:\hot-dir\';
% parameters
expi.settings.rot_gain       = .02;
expi.settings.fwd_gain       = 1;
expi.settings.hz             = 10; 
expi.settings.num_reps       = 100;

expi.settings.viz(1).stim_num = 1;
expi.settings.viz(1).pat_num = nan;
expi.settings.viz(1).name = 'flick_on';
expi.settings.viz(1).gains_hz = 0;
expi.settings.viz(1).gains_pat = 0;

expi.settings.viz(2).stim_num = 2;
expi.settings.viz(2).pat_num = nan;
expi.settings.viz(2).name = 'flick_off';
expi.settings.viz(2).gains_hz = 0;
expi.settings.viz(2).gains_pat = 0;

expi.settings.viz(3).stim_num = 3;
expi.settings.viz(3).pat_num = 1;
expi.settings.viz(3).name = 'optomotor'; 
expi.settings.viz(3).pix_width = 16;
expi.settings.viz(3).gains_hz = [-50, -5, -1, -.5,  0, .5, 1, 5, 50];
expi.settings.viz(3).gains_pat = expi.settings.viz(3).gains_hz*expi.settings.viz(3).pix_width;

expi.settings.light_power    = [1];
expi.settings.startXYT       = [96 96 0];
expi.settings.dark_time      = 0;
expi.settings.fix_time       = 0;
expi.settings.prestim_time   = 3;
expi.settings.poststim_time = 3;
expi.settings.align_time     = 0;
expi.settings.trial_time     = expi.settings.prestim_time+expi.settings.poststim_time;
expi.settings.reward_time    = Inf;
expi.settings.max_x          = 3424; % (wad length-1.5)*64mo
expi.settings.cool_dist      = [1400 2312];
expi.settings.prefix(1).text = 'env_align';
expi.settings.prefix(2).text = 'env_train';
expi.settings.ball_diameter = 9;
expi.settings.ticks_per_mm = 3.5;
expi.settings.ticks_per_deg = (expi.settings.ball_diameter)*pi*expi.settings.ticks_per_mm/360;
expi.camera.do_capture = 0;

vi_m = videoinput('pointgrey', 1);
vi_l = videoinput('pointgrey', 2);

prev_vi_l = preview(vi_l);
prev_vi_m = preview(vi_m);

disp('*************************')
disp('*************************')
disp('align fly on ball, then hit space')
disp('reset panel host gui')
disp('*************************')
disp('*************************')
pause()

closepreview(vi_l);

expi.settings.m_view = getsnapshot(vi_m);
expi.settings.l_view = getsnapshot(vi_l);

%% set up folder
cd(expi.settings.savedir)
mkdir(datestr(now, 'yyyy-mm-dd'))

cd(datestr(now, 'yyyy-mm-dd'))
mkdir(expi.settings.fname)
cd(expi.settings.fname)
expi.settings.fullpath = pwd;

%% save expi do C:\, so other instance can load
save('C:\meta_expi.mat', 'expi')

%% initialize cxn to panel host
init_tcp();
%Panel_tcp_com('set_pattern_id', [1])
%Panel_tcp_com('stop')

%% initialize daq 
app.ao = daq.createSession ('ni');
app.ao.addAnalogOutputChannel('Dev1', [0 1 2 3], 'Voltage');
app.ao.addDigitalChannel('Dev1', 'Port1/Line0:2', 'OutputOnly');
app.ao.outputSingleScan([0 0 0 -4.99 0 0 0])

%% init screen and render properties
trial_num = 1;
fix_aligned = 0;
aligned_trial = 0;

%% get ready!
disp('paused - hit space to continue')
pause


%% start acquisition
app.ao.outputSingleScan([-4.99 0 0 -4.99 0 0 0])

blank_datavec = nan(1, (expi.settings.trial_time*expi.settings.hz)+100);
blank_datamat = blank_datavec;

%% now run trials
f1 = figure('color', 'w', 'position', [27 607 727 380]);
for aa = 1:(expi.settings.num_reps*3)

   half_trial_samples = expi.settings.prestim_time*expi.settings.hz;

   %% visual stimulus control vec
   exp_stimulus_vec = [zeros(1, half_trial_samples) 1 zeros(1, 1.1*half_trial_samples)];
   
   %% visual selection
   viz_selection_vec = [1 2 3*ones(1,9)];
   viz_selection_vec = viz_selection_vec(randperm(length(viz_selection_vec)));
   c_vis_type = viz_selection_vec(1); 
   
   if c_vis_type == 1
        
       viz_name = 'flick_on';
       
       c_gain_hz = 0;
       c_gain_pat = 0;
             
   elseif c_vis_type == 2
       
       viz_name = 'flick_off';

       c_gain_hz = 0;
       c_gain_pat = 0;
       
   elseif c_vis_type == 3
       
       viz_name = 'optomotor';
       rand_gain_vec = randperm(9);
       c_gain_idx = rand_gain_vec(1);
       
       c_gain_hz = expi.settings.viz(3).gains_hz(c_gain_idx);
       c_gain_pat = expi.settings.viz(3).gains_pat(c_gain_idx);

   end
   
   %% hot light selection
   hot_selection_vec = [0 1];
   hot_selection_vec = randperm(length(hot_selection_vec));
   c_hot_type = hot_selection_vec(1);
   
    if c_hot_type == 0
    
        light_vec = -4.99*ones(1, 2.2*half_trial_samples);
        hot_name = 'hot_0';
        
    else
        
        light_vec = [-4.99*ones(1, half_trial_samples) expi.settings.light_power*ones(1, 1.1*half_trial_samples)];
        hot_name = 'hot_1';   
        
    end
        
   try
        expi = rmfield(expi, 'c_trial');
    catch
   end

   %% BRIEF
   disp('*************************************')
   disp('running brief pulse')
   
   disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_reps)])
   expi = init_memory(expi);

    expi.c_trial.startXYT    = expi.settings.startXYT(1,:);
    expi.c_trial.dark_time   = expi.settings.dark_time;
    expi.c_trial.fix_time    = expi.settings.fix_time;
    expi.c_trial.trial_time  = expi.settings.trial_time;
    expi.c_trial.reward_time = expi.settings.reward_time;
    expi.c_trial.dark_frames = expi.c_trial.dark_time*expi.settings.hz;
    expi.c_trial.fix_frames  = expi.c_trial.fix_time*expi.settings.hz;
    expi.c_trial.reward_frames  = expi.c_trial.reward_time*expi.settings.hz;

    expi.c_trial.player.xu   = expi.c_trial.startXYT(1);
    expi.c_trial.player.yu   = expi.c_trial.startXYT(2);
    expi.c_trial.player.th   = expi.c_trial.startXYT(3);

    expi.c_trial.data.video_frames = nan(1024/2, 1280/2, (expi.c_trial.trial_time*expi.settings.hz)+100);
    
    expi.c_trial.hot = c_hot_type;
    expi.c_trial.light_vec = light_vec;
    
    expi.c_trial.viz_name = viz_name;
    expi.c_trial.viz_type = c_vis_type;
    expi.c_trial.c_gain_hz = c_gain_hz;
    expi.c_trial.c_gain_pat = c_gain_pat;
    expi.c_trial.stimulus_vec = exp_stimulus_vec;

    disp([' rep ' (num2str(aa)) ' type ' viz_name ' gain ' num2str(c_gain_hz) ' ' hot_name])

    expi.c_trial.name = ['env_rep_' num2str(aa, '%03d')...
                                    '_pat_' expi.c_trial.viz_name ...
                                    '_hot_' num2str(c_hot_type) ...                                 
                                    '_gain_' num2str(c_gain_hz)];
                                
    expi.c_trial.rep_num         = aa;

    %% run exp trial
    expi = run_thermo_opto_2p_trial(expi, app, vi_m);

	Panel_tcp_com('stop')
	Panel_tcp_com('all_off')
    app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])
    
    cval = ['rkb'];
    plot(expi.c_trial.data.om, 'Linewidth', 2, 'color', 'r');
    hold off
    
    disp('paused, retrigger w/ spacebar')
    pause()

    
 end
  
close_tcp();
app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\raycast\functional\run_optothermal.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\raycast\functional\run_thermo_opto_trial.m', expi.settings.fullpath)

cd('C:\')
