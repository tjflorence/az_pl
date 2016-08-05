clear all 
close all
delete(instrfind)
imaqreset
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'dir_resp';
expi.settings.geno       = 'HC-Gal4x5a';
expi.settings.notes      = 'fly 2 r removed';
expi.settings.img_name   = 'fly 2 r removed';
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

expi.settings.viz(1).pnum = nan;
expi.settings.viz(1).name = 'all_off';
expi.settings.viz(1).gains = 0;
expi.settings.viz(1).rando_gains = 0;

expi.settings.viz(2).pnum = 1;
expi.settings.viz(2).name = 'optomotor';
expi.settings.viz(2).gains = [-34 0 34];
expi.settings.viz(2).rando_gains = nan(expi.settings.num_reps,...
                                    length(expi.settings.viz(2).gains));

expi.settings.light_power    = [-4 -1.5 1 3.5];
expi.settings.startXYT       = [96 96 0];
expi.settings.dark_time      = 60;
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
%init_tcp();
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
   
   c_power = expi.settings.light_power(randperm(length(expi.settings.light_power)));
   c_power = c_power(1);
   opto_idx = 0;
   exp_idx = 0;
   
   tmod = mod(aa, 3);
   if tmod == 0
       tmod = 3;
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
    expi.c_trial.light_vec = [-4.99*ones(1, (expi.settings.trial_time*expi.settings.hz)+100)];
    expi.c_trial.light_vec( (expi.settings.prestim_time*expi.settings.hz):...
                            (floor(expi.settings.hz/2)+(expi.settings.prestim_time*expi.settings.hz))) = c_power;


    disp(['power ' num2str(c_power) ' rep ' (num2str(aa))])
   
    %% this is where we put the pattern setting code    
    pat_name = 'none';
    c_gain = expi.settings.viz(2).gains(tmod);
        
   % Panel_tcp_com('set_pattern_id', 1);
   % Panel_tcp_com('set_position', [24, 1]);
   % Panel_tcp_com('send_gain_bias', [c_gain, 0, 0, 0])
   % Panel_tcp_com('start')

    dither_vec = .1*[0 1];
    dither_vec = dither_vec(randperm(length(dither_vec)));

    expi.c_trial.dither = dither_vec(1)+(.01*randn(1));
    expi.c_trial.name = [expi.settings.prefix(2).text '_tnum_' '_rep_' sprintf('%03d',aa)...
                                    '_power_' sprintf('%02d', c_power)...
                                    '_pat_' pat_name ...
                                    '_gain_' num2str(c_gain)];
                                
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;
    expi.c_trial.vis_gain        = c_gain;    
    
    %disp(['current trial: ' expi.c_trial.name])
    
  % closepreview(vi_m);
    %% run exp trial
    expi = run_thermo_opto_2p_trial(expi, app, vi_m);

 %   preview(vi_m)
 %   Panel_tcp_com('stop')
 %   Panel_tcp_com('all_off')
    app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])
    

    cval = ['rkb'];
    plot(expi.c_trial.data.om, 'Linewidth', 2, 'color', cval(tmod));
    hold off
    
    disp('paused, retrigger w/ spacebar')
    pause()

    
 end
  
close_tcp();
app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\raycast\functional\run_optothermal.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\raycast\functional\run_thermo_opto_trial.m', expi.settings.fullpath)

cd('C:\')
