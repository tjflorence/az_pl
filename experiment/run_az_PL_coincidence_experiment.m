clear all 
close all 
delete(instrfind)
imaqreset
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'az_PL-coincidence';
expi.settings.geno       = '11f03';
expi.settings.notes      = '';
expi.settings.img_name   = '';
expi.settings.age        = 4; 
expi.settings.date       = datestr(now, 'yyyymmddHHMMSS');
expi.settings.fname      = [expi.settings.date '_' expi.settings.geno '_' ...
                                expi.settings.name];
expi.settings.savedir    = 'C:\hot-dir\';
% parameters
expi.settings.rot_gain       = .4;
expi.settings.fwd_gain       = 1;
expi.settings.hz             = 50;

expi.settings.num_reps       = 6;
expi.settings.is_control     = 0;
expi.settings.is_imaging     = 1;

expi.settings.light_power    = [1];
expi.settings.start_theta    = [90 270];
expi.settings.start_xpos     = [24 72];

expi.settings.dark_time      = 5;
expi.settings.fix_time       = 0;
expi.settings.trial_time     = 60+(expi.settings.dark_time+expi.settings.fix_time);
expi.settings.reward_time    = Inf;

% make thermal environment 
power_vec = expi.settings.light_power*ones(1,96);
power_vec(36:61) = -4.99;
gaussFilter = gausswin(15);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
power_vec = conv(power_vec, gaussFilter, 'same');
power_vec(1:15) = expi.settings.light_power;
power_vec(80:96) = expi.settings.light_power;
power_vec = circshift(power_vec, [1 48]);
    
expi.settings.thermal_env(1).therm_env = power_vec;
expi.settings.thermal_env(2).therm_env = expi.settings.light_power*ones(1,96);

expi.settings.prefix(1).text = 'env_train';
expi.settings.prefix(2).text = 'env_test';
expi.settings.ball_diameter = 9;
expi.settings.ticks_per_mm = 3.5;
expi.settings.ticks_per_deg = (expi.settings.ball_diameter)*pi*expi.settings.ticks_per_mm/360;

expi.settings.viz_env_names = {'off', 'CL', 'dynamic off'};
expi.settings.therm_env_names = {'cool', 'no cool'};

%% collect conditions
expi.settings.cl_conditions(1).viz_name     = 'off';
expi.settings.cl_conditions(1).therm_name   = 'cool';
expi.settings.cl_conditions(1).therm_env    = expi.settings.thermal_env(1).therm_env;
expi.settings.cl_conditions(1).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.cl_conditions(2).viz_name     = 'off';
expi.settings.cl_conditions(2).therm_name   = 'noCool';
expi.settings.cl_conditions(2).therm_env    = expi.settings.thermal_env(2).therm_env;
expi.settings.cl_conditions(2).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.cl_conditions(3).viz_name     = 'CL';
expi.settings.cl_conditions(3).therm_name   = 'cool';
expi.settings.cl_conditions(3).therm_env    = expi.settings.thermal_env(1).therm_env;
expi.settings.cl_conditions(3).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.cl_conditions(4).viz_name     = 'CL';
expi.settings.cl_conditions(4).therm_name   = 'noCool';
expi.settings.cl_conditions(4).therm_env    = expi.settings.thermal_env(2).therm_env;
expi.settings.cl_conditions(4).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.cl_conditions(5).viz_name     = 'dynamicOff';
expi.settings.cl_conditions(5).therm_name   = 'cool';
expi.settings.cl_conditions(5).therm_env    = expi.settings.thermal_env(1).therm_env;
expi.settings.cl_conditions(5).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.cl_conditions(6).viz_name     = 'dynamicOff';
expi.settings.cl_conditions(6).therm_name   = 'noCool';
expi.settings.cl_conditions(6).therm_env    = expi.settings.thermal_env(2).therm_env;
expi.settings.cl_conditions(6).ref_env      = expi.settings.thermal_env(1).therm_env;

expi.settings.condition_order = repmat([3 5], [1 expi.settings.num_reps]);
expi.settings.condition_order = expi.settings.condition_order(randperm(length(expi.settings.condition_order)));

%for ii = 1:expi.settings.num_reps
   
%    expi.settings.condition_order = [expi.settings.condition_order ...
%                                        randperm(length(expi.settings.cl_conditions))];
    
%end
expi.settings.num_reps = length(expi.settings.condition_order);

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
Panel_tcp_com('set_pattern_id', [1])
Panel_tcp_com('stop')
Panel_tcp_com('all_off')

%% initialize daq 
app.ao = daq.createSession ('ni');
app.ao.addAnalogOutputChannel('Dev1', [0 1 2 3], 'Voltage');
app.ao.addDigitalChannel('Dev1', 'Port1/Line0:2', 'OutputOnly');
app.ao.outputSingleScan([0 0 0 -4.99 0 0 0])


%% get ready!
disp('paused - hit space to continue')
pause


%% start acquisition
app.ao.outputSingleScan([-4.99 0 0 -4.99 0 0 0])

%% now run trials
f1 = figure('color', 'w', 'position', [27 607 727 380]);
for aa = 1:expi.settings.num_reps
   
   c_condition_idx = expi.settings.condition_order(aa);
   c_condition = expi.settings.cl_conditions(c_condition_idx);
   
   try
        expi = rmfield(expi, 'c_trial');
    catch
   end

   %% BRIEF
   disp('*************************************')
   disp('running brief pulse')
   
    disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_reps)])
    expi = init_memory(expi);

    expi.c_trial.rep     =    aa;
    expi.c_trial.dark_time   = expi.settings.dark_time;
    expi.c_trial.fix_time    = expi.settings.fix_time;
    expi.c_trial.trial_time  = expi.settings.trial_time;
    expi.c_trial.reward_time = expi.settings.reward_time;
    expi.c_trial.dark_frames = expi.c_trial.dark_time*expi.settings.hz;
    expi.c_trial.fix_frames  = expi.c_trial.fix_time*expi.settings.hz;
    expi.c_trial.reward_frames  = expi.c_trial.reward_time*expi.settings.hz;

    c_rand = randperm(2);
    c_rand = c_rand(1);
    expi.c_trial.player.start_th    = expi.settings.start_theta(c_rand);
    expi.c_trial.player.start_xpos  = expi.settings.start_xpos(c_rand);

    expi.c_trial.light_vec = c_condition.therm_env;
    expi.c_trial.ref_light_vec = c_condition.ref_env;
    expi.c_trial.viz_name = c_condition.viz_name;
    expi.c_trial.therm_name = c_condition.therm_name;
    expi.c_trial.cl_type = c_condition_idx;
    
    %% this is where we put the pattern setting code
    
    expi.c_trial.name = ['env_rep_' sprintf('%03d',aa)...
                            '_type_' num2str(c_condition_idx) ... 
                            '_viz_' expi.c_trial.viz_name ...
                            '_therm_' expi.c_trial.therm_name];
                        
    expi.c_trial.is_test = 0;
    expi.c_trial.pat_id = 2;
    
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = expi.settings.light_power;
    
    disp(expi.c_trial.name)
    
    %% run exp trial
    expi = run_az_PL_coincidence_trial(expi , app);

    Panel_tcp_com('all_off')
    pause(3)
    app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

    th_exp = expi.c_trial.data.th( ((expi.settings.dark_time+expi.settings.fix_time+1)*50):(expi.c_trial.data.count));
    p1 = numel(find(th_exp>315));
    p2 = numel(find(th_exp<45));
    p4 = numel(find(th_exp<225 & th_exp>135));
    p_i = ((p1+p2)-p4)/(p1+p2+p4);
    disp(p_i)     
    
    hold on
    
    scatter(aa, p_i)
    plot([-100 100], [0 0], 'k')
    xlim([0.5 aa+.5])
    ylim([[-1 1]])
    if aa == 1
        disp('is < .25?')
        pause()
    else
        if expi.settings.is_imaging == 1
            disp('hit space to continue')
            pause()
        else
            pause(10)
        end
    end
    
end

close_tcp();
app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\az_pl\experiment\run_az_PL_error_experiment.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\az_pl\experiment\run_az_PL_error_trial.m', expi.settings.fullpath)


cd('C:\')
