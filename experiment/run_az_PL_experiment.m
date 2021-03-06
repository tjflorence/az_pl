clear all 
close all 
delete(instrfind)
imaqreset
daqreset

%% experiment level settings
%  names
expi.settings.name       = 'az_PL';
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

expi.settings.num_trials     = 10;
expi.settings.num_mock       = 4;
expi.settings.is_control     = 0;
expi.settings.is_dynamic_off = 1;
expi.settings.is_imaging     = 1;

expi.settings.light_power    = [1];
expi.settings.start_theta    = [90 270];
expi.settings.start_xpos     = [24 72];

expi.settings.dark_time      = 5;
expi.settings.fix_time       = 0;
expi.settings.trial_time     = 60+(expi.settings.dark_time+expi.settings.fix_time);
expi.settings.reward_time    = Inf;

expi.settings.prefix(1).text = 'env_train';
expi.settings.prefix(2).text = 'env_test';
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
for aa = 1

  c_power = expi.settings.light_power(randperm(length(expi.settings.light_power)));
  c_power = c_power(1);
          
  power_vec = -4.99*ones(1,96);
        
  try
       expi = rmfield(expi, 'c_trial');
   catch
  end


    %% BRIEF
    disp('*************************************')
    disp('running pretest OL mapping')
   
    disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_trials)])
    expi = init_memory(expi);

    expi.c_trial.rep     =    aa;
    expi.c_trial.dark_time   = 22;
    expi.c_trial.fix_time    = nan;
    expi.c_trial.trial_time  = 70;
    expi.c_trial.reward_time = nan;
    expi.c_trial.dark_frames = expi.settings.hz*expi.settings.dark_time;
    expi.c_trial.fix_frames  = nan;
    expi.c_trial.reward_frames  = nan;
    
    expi.c_trial.pos_vec = make_OL_map_posvec(expi.settings.hz);
    
   c_rand = randperm(2);
   c_rand = c_rand(1);
   expi.c_trial.player.start_th    = expi.settings.start_theta(c_rand);
   expi.c_trial.player.start_xpos  = expi.settings.start_xpos(c_rand);

   expi.c_trial.light_vec = power_vec;

   disp(['trial  ' (num2str(aa))])
   
    %% this is where we put the pattern setting code     
    expi.c_trial.name = ['OL_A_' num2str(aa)]; 
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;

   
   expi.c_trial.rep_num         = aa;
   expi.c_trial.light_power     = c_power;
    
    %% run exp trial
   expi = run_az_PL_OL_trial(expi, app);

   Panel_tcp_com('all_off')
   pause(3)
  app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

   if expi.settings.is_imaging == 1
       disp('hit space to continue')
       pause()
   else
       pause(10)
   end
    
end

%% now run trials
f1 = figure('color', 'w', 'position', [27 607 727 380]);
for aa = 1:12
   
   c_power = expi.settings.light_power(randperm(length(expi.settings.light_power)));
   c_power = c_power(1);
   
   if (aa == 1) || (aa == 12)
       
    power_vec = c_power*ones(1,96);
   
   else
       
    power_vec = c_power*ones(1,96);
    power_vec(36:61) = -4.99;
    gaussFilter = gausswin(15);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
    power_vec = conv(power_vec, gaussFilter, 'same');
    power_vec(1:15) = c_power;
    power_vec(80:96) = c_power;

    power_vec = circshift(power_vec, [1 48]);

   end

        
   try
        expi = rmfield(expi, 'c_trial');
    catch
   end

   %% BRIEF
   disp('*************************************')
   disp('running brief pulse')
   
    disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_trials)])
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

    expi.c_trial.light_vec = power_vec;

    disp(['trial  ' (num2str(aa))])
   
    %% this is where we put the pattern setting code    
   if (aa == 1) || (aa == 12)

        expi.c_trial.name = [expi.settings.prefix(2).text  '_rep_' sprintf('%03d',aa)];
        expi.c_trial.is_test = 1;

   else
       
       expi.c_trial.name = [expi.settings.prefix(1).text  '_rep_' sprintf('%03d',aa)];
        expi.c_trial.is_test = 0;
   
   end
   
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;
    
    
    %% run exp trial
    expi = run_az_PL_trial(expi , app);

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
    xlim([0.5 expi.settings.num_trials+expi.settings.num_mock+.5])
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

for aa = 13:100
   
   c_power = expi.settings.light_power(randperm(length(expi.settings.light_power)));
   c_power = c_power(1);
   
   if mod(aa-12, 6) == 0
       
    power_vec = c_power*ones(1,96);
   
   else
       
    power_vec = c_power*ones(1,96);
    power_vec(36:61) = -4.99;
    gaussFilter = gausswin(15);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
    power_vec = conv(power_vec, gaussFilter, 'same');
    power_vec(1:15) = c_power;
    power_vec(80:96) = c_power;

    power_vec = circshift(power_vec, [1 48]);

   end

        
   try
        expi = rmfield(expi, 'c_trial');
    catch
   end

   %% BRIEF
   disp('*************************************')
   disp('running brief pulse')
   
    disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_trials)])
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

    expi.c_trial.light_vec = power_vec;

    disp(['trial  ' (num2str(aa))])
   
    %% this is where we put the pattern setting code    
   if mod(aa-12, 6) == 0

        expi.c_trial.name = [expi.settings.prefix(2).text  '_rep_' sprintf('%03d',aa)];
        expi.c_trial.is_test = 1;
   else
       
       expi.c_trial.name = [expi.settings.prefix(1).text  '_rep_' sprintf('%03d',aa)];
       expi.c_trial.is_test = 0;

   end
   
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;
    
    
    %% run exp trial
    expi = run_az_PL_trial(expi, app);

    Panel_tcp_com('all_off')
    pause(3)
    app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

    th_exp = expi.c_trial.data.th( ((expi.settings.dark_time+expi.settings.fix_time+1)*50):(expi.c_trial.data.count-(15*45)));
    p1 = numel(find(th_exp>315));
    p2 = numel(find(th_exp<45));
    p4 = numel(find(th_exp<225 & th_exp>135));
    p_i = ((p1+p2)-p4)/(p1+p2+p4);
    disp(p_i)    
    
    
    hold on
    
    scatter(aa, p_i)
    plot([-100 100], [0 0], 'k')
    xlim([0.5 expi.settings.num_trials+expi.settings.num_mock+.5])
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


%%%%%%%%%%
%%%%%%%%%
% here is the open loop mapping
for aa = 1

  c_power = expi.settings.light_power(randperm(length(expi.settings.light_power)));
  c_power = c_power(1);
          
  power_vec = -4.99*ones(1,96);
        
  try
       expi = rmfield(expi, 'c_trial');
   catch
  end


    %% BRIEF
    disp('*************************************')
    disp('running posttest OL mapping')
   
    disp(['rep ' num2str(aa) ' of ' num2str(expi.settings.num_trials)])
    expi = init_memory(expi);

    expi.c_trial.rep     =    aa;
    expi.c_trial.dark_time   = 22;
    expi.c_trial.fix_time    = nan;
    expi.c_trial.trial_time  = 70;
    expi.c_trial.reward_time = nan;
    expi.c_trial.dark_frames = expi.settings.hz*expi.settings.dark_time;
    expi.c_trial.fix_frames  = nan;
    expi.c_trial.reward_frames  = nan;
    
    expi.c_trial.pos_vec = make_OL_map_posvec(expi.settings.hz);
    
   c_rand = randperm(2);
   c_rand = c_rand(1);
   expi.c_trial.player.start_th    = expi.settings.start_theta(c_rand);
   expi.c_trial.player.start_xpos  = expi.settings.start_xpos(c_rand);

   expi.c_trial.light_vec = power_vec;

   disp(['trial  ' (num2str(aa))])
   
    %% this is where we put the pattern setting code     
    expi.c_trial.rep_num         = aa;
    expi.c_trial.light_power     = c_power;
    expi.c_trial.name = ['OL_B_' num2str(aa)];

   expi.c_trial.rep_num         = aa;
   expi.c_trial.light_power     = c_power;
    
    %% run exp trial
   expi = run_az_PL_OL_trial(expi, app);

   Panel_tcp_com('all_off')
   pause(3)
  app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

   if expi.settings.is_imaging == 1
       disp('hit space to continue')
       pause()
   else
       pause(10)
   end
    
end


close_tcp();
app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\az_pl\experiment\run_az_PL_experiment.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\az_pl\experiment\run_az_PL_trial.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\az_pl\experiment\run_az_PL_OL_trial.m', expi.settings.fullpath)


cd('C:\')
