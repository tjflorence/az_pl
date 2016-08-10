clear all 
close all
delete(instrfind)
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'dir_resp';
expi.settings.geno       = 'Gr28.b-LexAx2b';
expi.settings.notes      = 'fly4, intact, R-stim cross';
expi.settings.age        = 4;
expi.settings.date       = datestr(now, 'yyyymmddHHMMSS');
expi.settings.fname      = [expi.settings.date '_' expi.settings.geno '_' ...
                                expi.settings.name];
expi.settings.savedir    = 'C:\hot-dir\';
% parameters
expi.settings.rot_gain       = .02;
expi.settings.fwd_gain       = 1;
expi.settings.hz             = 50;
expi.settings.num_reps       = 5;

expi.settings.viz(1).pnum = nan;
expi.settings.viz(1).name = 'all_off';
expi.settings.viz(1).gains = 0;
expi.settings.viz(1).rando_gains = 0;

expi.settings.viz(2).pnum = 1;
expi.settings.viz(2).name = 'optomotor';
expi.settings.viz(2).gains = [-113 -45 -34 0 34 45 113];
expi.settings.viz(2).rando_gains = nan(expi.settings.num_reps,...
                                    length(expi.settings.viz(2).gains));
for ii = 1:expi.settings.num_reps
   
    expi.settings.viz(2).rando_gains(ii,:) = expi.settings.viz(2).gains(randperm(length(expi.settings.viz(2).gains)));
    
end

expi.settings.viz(3).pnum = 2;
expi.settings.viz(3).name = 'expansion';
expi.settings.viz(3).gains = [34 45 113];
expi.settings.viz(3).rando_gains = nan(expi.settings.num_reps,...
                                    length(expi.settings.viz(3).gains));
for ii = 1:expi.settings.num_reps
   
    expi.settings.viz(3).rando_gains(ii,:) = expi.settings.viz(3).gains(randperm(length(expi.settings.viz(3).gains)));
    
end

expi.settings.viz(4).pnum = 3;
expi.settings.viz(4).name = 'expansion_L05_R1';
expi.settings.viz(4).gains = 34;

expi.settings.viz(5).pnum = 4;
expi.settings.viz(5).name = 'expansion_L02_R1';
expi.settings.viz(5).gains = 34;

expi.settings.viz(6).pnum = 5;
expi.settings.viz(6).name = 'expansion_L01_R1';
expi.settings.viz(6).gains = 34;

expi.settings.viz(7).pnum = 6;
expi.settings.viz(7).name = 'expansion_L1_R05';
expi.settings.viz(7).gains = 34;

expi.settings.viz(8).pnum = 7;
expi.settings.viz(8).name = 'expansion_L1_R02';
expi.settings.viz(8).gains = 34;

expi.settings.viz(9).pnum = 8;
expi.settings.viz(9).name = 'expansion_L1_R01';
expi.settings.viz(9).gains = 34;

expi.settings.stim_settings.complete_vec = [1 2*ones(1,7) 3*ones(1,3) 4 5 6 7 8 9];
expi.settings.stim_settings.rando_vec = nan(expi.settings.num_reps, ...
                                            length(expi.settings.stim_settings.complete_vec));
for ii = 1:expi.settings.num_reps
   
    expi.settings.stim_settings.rando_vec(ii,:) = ...
                    expi.settings.stim_settings.complete_vec(randperm(length(expi.settings.stim_settings.complete_vec)));
    
end


expi.settings.light_power    = [5];
expi.settings.startXYT       = [96 96 0];
expi.settings.dark_time      = 60;
expi.settings.fix_time       = 0;
expi.settings.align_time     = 0;
expi.settings.trial_time     = 18;
expi.settings.reward_time    = Inf;
expi.settings.max_x          = 3424; % (wad length-1.5)*64mo
expi.settings.cool_dist      = [1400 2312];
expi.settings.prefix(1).text = 'env_align';
expi.settings.prefix(2).text = 'env_train';
expi.settings.ball_diameter = 9;
expi.settings.ticks_per_mm = 3.5;
expi.settings.ticks_per_deg = (expi.settings.ball_diameter)*pi*expi.settings.ticks_per_mm/360;
expi.camera.do_capture = 0;

disp('*************************')
disp('*************************')
disp('align fly on ball, then hit space')
disp('reset panel host gui')
disp('*************************')
disp('*************************')
pause()



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
Panel_tcp_com('set_pattern_id', [1])
Panel_tcp_com('stop')

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
app.ao.outputSingleScan([5 0 0 -4.99 0 0 0])


%% now run trials
for aa = 1:expi.settings.num_reps
   
   c_power = expi.settings.light_power;
   opto_idx = 0;
   exp_idx = 0;
   
   for bb = 1:length(expi.settings.stim_settings.complete_vec)
          
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
    
    expi.c_trial.light_vec = [-4.99*ones(1, 19*expi.settings.hz)];
    expi.c_trial.light_vec(1:25) = c_power;
    expi.c_trial.light_vec((6*expi.settings.hz):((6*expi.settings.hz)+25)) = c_power;
    expi.c_trial.light_vec((12*expi.settings.hz):((12*expi.settings.hz)+25)) = c_power;

    disp(['power ' num2str(c_power) ' rep ' (num2str(aa))])
    Panel_tcp_com('all_off')
    pause(12)
   
    %% this is where we put the pattern setting code
    c_pat = expi.settings.stim_settings.rando_vec(aa,bb);
    c_pnum = expi.settings.viz(c_pat).pnum;
    
    if isnan(c_pnum)
        
        Panel_tcp_com('all_off')
        pat_name = 'off';
        c_gain = 'none';
        
    elseif c_pnum == 1
        
        opto_idx = opto_idx+1;
        pat_name = 'optomotor';
        c_gain = expi.settings.viz(c_pat).rando_gains(aa, opto_idx);
        
        Panel_tcp_com('set_pattern_id', 1);
        Panel_tcp_com('set_position', [24, 1]);
        Panel_tcp_com('send_gain_bias', [c_gain, 0, 0, 0])
        Panel_tcp_com('start')
        
    elseif c_pnum == 2
        
        exp_idx = exp_idx+1;
        pat_name = 'expansion';
        c_gain = expi.settings.viz(c_pat).rando_gains(aa, exp_idx);
        
        Panel_tcp_com('set_pattern_id', 2)
        Panel_tcp_com('set_position', [24, 1])
        Panel_tcp_com('send_gain_bias', [0, 0, c_gain, 0])
        Panel_tcp_com('start')
        
    elseif c_pnum > 2
        
        pat_name = expi.settings.viz(c_pat).name;
        c_gain = expi.settings.viz(c_pat).gains;
        
        Panel_tcp_com('set_pattern_id', c_pnum)
        Panel_tcp_com('set_position', [24, 1])
        Panel_tcp_com('send_gain_bias', [0, 0, c_gain, 0])
        Panel_tcp_com('start')
    
    end
    

    expi.c_trial.name = [expi.settings.prefix(2).text '_rep_' sprintf('%02d',aa)...
                                    '_power_' sprintf('%02d', c_power)...
                                    '_pat_' pat_name ...
                                    '_gain_' num2str(c_gain)];
                                
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;
    expi.c_trial.vis_gain        = c_gain;    
    
    disp(['current trial: ' expi.c_trial.name])
    pause(2)
    
    %% run exp trial
    expi = run_thermo_opto_trial(expi, app);
    Panel_tcp_com('stop')
    
    Panel_tcp_com('all_off')
    
   end
   
end
close_tcp();
app.ao.outputSingleScan([5 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\raycast\functional\run_optothermal.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\raycast\functional\run_thermo_opto_trial.m', expi.settings.fullpath)

cd('C:\')
