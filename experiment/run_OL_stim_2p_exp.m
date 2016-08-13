clear all 
close all
delete(instrfind)
imaqreset
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'OL_stim';
expi.settings.geno       = '11f03-uniblocks';
expi.settings.notes      = '';
expi.settings.img_name   = 'fly 1';
expi.settings.age        = 4;
expi.settings.date       = datestr(now, 'yyyymmddHHMMSS');
expi.settings.fname      = [expi.settings.date '_' expi.settings.geno '_' ...
                                expi.settings.name];
expi.settings.savedir    = 'C:\hot-dir\';
% parameters
expi.settings.rot_gain       = .4;
expi.settings.fwd_gain       = 1;
expi.settings.hz             = 50; 
expi.settings.num_reps       = 100;
expi.settings.start_theta    = [90 270];
expi.settings.start_xpos     = [24 72];

expi.settings.light_power    = [1];
expi.settings.startXYT       = [96 96 0];
expi.settings.dark_time      = 0; 
expi.settings.fix_time       = 0;
expi.settings.prestim_time   = 60;
expi.settings.poststim_time  = 70;
expi.settings.align_time     = 0;
expi.settings.trial_time     = expi.settings.prestim_time+expi.settings.poststim_time;

e_samples = expi.settings.prestim_time*expi.settings.hz;
expi.settings.stim(1).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(1).name = 'all_off';

expi.settings.stim(2).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(2).heat_vec(1, e_samples:(e_samples+25)) = expi.settings.light_power;
expi.settings.stim(2).name = '05_sec_pulse';

expi.settings.stim(3).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(3).heat_vec(1, e_samples:(e_samples+50)) = expi.settings.light_power;
expi.settings.stim(3).name = '1_sec_pulse';

expi.settings.stim(4).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(4).heat_vec(1, e_samples:(e_samples+250)) = expi.settings.light_power;
expi.settings.stim(4).name = '5_sec_pulse';

expi.settings.stim(5).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(5).heat_vec(1, e_samples:(e_samples+750)) = expi.settings.light_power;
expi.settings.stim(5).name = '15_sec_pulse';

expi.settings.stim(6).heat_vec = -4.99*ones(1, 1.1*expi.settings.trial_time*expi.settings.hz);
expi.settings.stim(6).heat_vec(1, e_samples:(e_samples+1500)) = expi.settings.light_power;
expi.settings.stim(6).name = '30_sec_pulse';

expi.settings.num_stim_types = length(expi.settings.stim);
expi.settings.num_stim_reps = 4;
expi.settings.stim_vec = [];
for ii = 1:expi.settings.num_stim_reps
   
    expi.settings.stim_vec = [expi.settings.stim_vec randperm(expi.settings.num_stim_types)];
    
end

expi.settings.viz_condition = nan(size(expi.settings.stim_vec));
for ii = 1:expi.settings.num_stim_types
   
    presentation_locations = find(expi.settings.stim_vec==ii);
    stim_rand = [ones(1,2) zeros(1,2)];
    stim_rand = stim_rand(randperm(length(stim_rand)));
    
    for jj = 1:length(presentation_locations)
       
        c_location = presentation_locations(jj);
        expi.settings.viz_condition(c_location) = stim_rand(jj);
        
    end
    
end

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
closepreview(vi_m);

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
for aa = 1:length(expi.settings.stim_vec)

   c_viz = expi.settings.viz_condition(aa);
   c_stim = expi.settings.stim_vec(aa);
   light_vec = expi.settings.stim(c_stim).heat_vec;
   c_rand = randperm(2);
   c_rand = c_rand(1);
   
   %% BRIEF
   disp('*************************************')
   disp('running brief pulse')
   
   disp(['rep ' num2str(aa) ' of ' num2str(length(expi.settings.stim_vec))])
   expi = init_memory(expi);

    expi.c_trial.startXYT    = expi.settings.startXYT(1,:);
    expi.c_trial.dark_time   = expi.settings.dark_time;
    expi.c_trial.fix_time    = expi.settings.fix_time;
    expi.c_trial.trial_time  = expi.settings.trial_time;
    expi.c_trial.dark_frames = expi.c_trial.dark_time*expi.settings.hz;
    expi.c_trial.fix_frames  = expi.c_trial.fix_time*expi.settings.hz;
    expi.c_trial.prestim_frames = expi.settings.prestim_time*expi.settings.hz;
    
    expi.c_trial.player.xu   = expi.c_trial.startXYT(1);
    expi.c_trial.player.yu   = expi.c_trial.startXYT(2);
    expi.c_trial.player.th   = expi.c_trial.startXYT(3);
    
    expi.c_trial.light_vec = light_vec;
    expi.c_trial.light_name = expi.settings.stim(c_stim).name;
    expi.c_trial.viz_type = c_viz;
    
    expi.c_trial.player.start_th    = expi.settings.start_theta(c_rand);
    expi.c_trial.player.start_xpos  = expi.settings.start_xpos(c_rand);
    
    if c_viz == 0
        expi.c_trial.viz_name = 'vizOFF';
    else
        expi.c_trial.viz_name = 'vizCL';
    end

    disp([' rep ' (num2str(aa)) ' type '  expi.c_trial.light_name ])

    expi.c_trial.name = ['env_rep_' num2str(aa, '%03d')...
                            '_type_' num2str(c_stim, '%03d')...
                            '_stim_' expi.c_trial.light_name ...
                            '_' expi.c_trial.viz_name];
     disp([  expi.c_trial.name ])                               
    expi.c_trial.rep_num         = aa;

    %% run exp trial
    Panel_tcp_com('all_off')
    expi = run_OL_stim_2p_trial(expi, app, vi_m);

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
