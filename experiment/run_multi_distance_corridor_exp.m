clear all 
close all
delete(instrfind)
daqreset
%% initialize daq 
app.ao = daq.createSession ('ni');
app.ao.addAnalogOutputChannel('Dev1', [0 1 2 3], 'Voltage');
app.ao.addDigitalChannel('Dev1', 'Port1/Line0:2', 'OutputOnly');
app.ao.outputSingleScan([0 0 0 -4.995 0 0 0])

%% experiment level settings
%  names
expi.settings.name       = 'multi_dist';
expi.settings.geno       = '11f03';
expi.settings.notes      = 'day 1: 201602261435; day 2: 201602271035';
expi.settings.age        = 4;
expi.settings.date       = datestr(now, 'yyyymmddHHMMSS');
expi.settings.fname      = [expi.settings.date '_' expi.settings.geno '_' ...
                                expi.settings.name];
expi.settings.savedir    = 'C:\hot_trench\';
% parameters
expi.settings.rot_gain       = 0;
expi.settings.fwd_gain       = 1;
expi.settings.hz             = 50;
expi.settings.light_power    = [1];
expi.settings.num_trials     = 15;
expi.settings.startXYT       = [96 96 0];
expi.settings.dark_time      = 30;
expi.settings.trial_time     = 120;
expi.settings.reward_time    = Inf;
expi.settings.max_x          = 3424; % (wad length-1.5)*64mo
expi.settings.cool_dist      = [472 1384;
                                1400 2312;
                                2328 3240];
                            
expi.settings.prefix(1).text = 'env_align';
expi.settings.prefix(2).text = 'env_train';
expi.settings.ball_diameter = 9;
expi.settings.ticks_per_mm = 3.5;
expi.settings.ticks_per_deg = (expi.settings.ball_diameter)*pi*expi.settings.ticks_per_mm/360;
expi.camera.do_capture = 0;

expi.settings.thermal_env_order = [];
for ii = 1:(expi.settings.num_trials/3)
   
    expi.settings.thermal_env_order = [expi.settings.thermal_env_order randperm(3)];
    
end

%% make training thermal environments
for ii = 1:size(expi.settings.cool_dist, 1)

    expi.settings.thermal_landscape_train(ii).scape = expi.settings.light_power*ones(1,expi.settings.max_x+10);
    min_cool_x = expi.settings.cool_dist(ii,1);
    max_cool_x = expi.settings.cool_dist(ii,2);
    
    expi.settings.thermal_landscape_train(ii).scape(min_cool_x:max_cool_x) = -4.99;
    
    gaussFilter = gausswin(floor([max_cool_x-min_cool_x]/4));
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
    expi.settings.thermal_landscape_train(ii).scape = conv(expi.settings.thermal_landscape_train(ii).scape,...
                                                            gaussFilter, 'same');

    expi.settings.thermal_landscape_train(ii).scape(1:200) = expi.settings.light_power;
    expi.settings.thermal_landscape_train(ii).scape(3320:end) = expi.settings.light_power;
end

expi.settings.thermal_landscape_probe = expi.settings.light_power*ones(1, expi.settings.max_x+10);

% environment
expi.world.wad           = ones(3, 56);
expi.world.min_xy        = [1 1];
expi.world.max_xy        = [size(expi.world.wad, 2) size(expi.world.wad, 1)];
expi.world.floor_texture = 4;
expi.world.map_unit      = 64;
expi.world.texture_dir   = 'C:\MatlabRoot\raycast\textures\uniform';
expi.world.textures.img = [];

for  aa = 1:2:56 
    expi.world.wad(:,aa+1)        = 1;
end
for  aa = 2:2:56 
    expi.world.wad(:,aa+1)        = 2;
end

expi.world.wad(2,1) = 3;
expi.world.wad(2,56) = 3;
expi.world.wad(2,2:55) = 0;

% load textures
cd(expi.world.texture_dir)
f_textures = dir('*.png');
disp('loading textures')
for aa = 1:length(f_textures)
    
    png_img = imread(f_textures(aa).name);
    expi.world.textures(aa).img = imresize(png_img(:,:,2), [64 64]); 
    
end
disp('......loaded!')
clear png_img f_textures aa
expi = init_screen_render(expi, 56, 32, 180);

%% set up folder
cd(expi.settings.savedir)
mkdir(datestr(now, 'yyyy-mm-dd'))

cd(datestr(now, 'yyyy-mm-dd'))
mkdir(expi.settings.fname)
cd(expi.settings.fname)
expi.settings.fullpath = pwd;

%% save expi do C:\, so other instance can load
save('C:\meta_expi.mat', 'expi')

%% align fly on ball, and take snapshots
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

%% initialize tcp port
% make tcp server for data surround, and write a "lights off"
% run external matlab
dos('matlab -r trench_external_tcp_timerfcn &')
app.tcpipServer = tcpip('0.0.0.0',55000,'NetworkRole','Server');
dataSize    = 3.3333*ones(1,5);
s           = whos('dataSize');
set(app.tcpipServer,'OutputBufferSize',s.bytes);
disp('waiting for cxn')
fopen(app.tcpipServer);
disp('connected')
fwrite(app.tcpipServer, [1 0 0 0 1], 'double');



%% init screen and render properties
trial_num = 1;
fix_aligned = 0;
aligned_trial = 0;

%% get ready!
disp('paused - hit space to continue')
pause


%% now run trials
redness = linspace(0,1,expi.settings.num_trials);
for aa = 1:expi.settings.num_trials
    
    
   try
        expi = rmfield(expi, 'c_trial');
    catch
    end
    expi = init_memory(expi);
    expi.c_trial.name        = [expi.settings.prefix(2).text '_' sprintf('%02d',aa) ];
    expi.c_trial.num         = aa;
    expi.c_trial.startXYT    = expi.settings.startXYT(1,:);
    expi.c_trial.dark_time   = expi.settings.dark_time;
    expi.c_trial.fix_time    = 0;
    expi.c_trial.trial_time  = expi.settings.trial_time;
    expi.c_trial.reward_time = expi.settings.reward_time;
    expi.c_trial.dark_frames = expi.c_trial.dark_time*expi.settings.hz;
    expi.c_trial.fix_frames  = expi.c_trial.fix_time*expi.settings.hz;
    expi.c_trial.reward_frames  = expi.c_trial.reward_time*expi.settings.hz;

    expi.c_trial.player.xu   = expi.c_trial.startXYT(1);
    expi.c_trial.player.yu   = expi.c_trial.startXYT(2);
    expi.c_trial.player.th   = expi.c_trial.startXYT(3);

    expi.c_trial.thermal_env = expi.settings.thermal_landscape_train(expi.settings.thermal_env_order(aa)).scape;
    disp('***************************')
    disp('hit space to run next trial ')
    disp(['will run trial ' num2str(aa)])
    pause()
    
    %% run exp trial
    expi = run_corridor_chr_trial(expi, app);
    
    plot(expi.c_trial.data.timestamp(1:expi.c_trial.data.count),...
        expi.c_trial.data.xpos(1:expi.c_trial.data.count), ...
        'Color', [redness(aa) 0 0], 'LineWidth', 2)
    
    hold on
    plot([-1000 1000], expi.settings.cool_dist(1)*ones(1,2), 'k--')
    plot([-1000 1000], expi.settings.cool_dist(2)*ones(1,2), 'k--')

    xlim([0 expi.settings.trial_time])
    ylim([96 expi.settings.max_x])
    xlabel('time(s)')
    ylabel('dist (ticks)')

end


close_tcp();
app.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])

copyfile('C:\MatlabRoot\az_pl\experiment\run_multi_distance_corridor_exp.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\az_pl\experiment\run_corridor_chr_trial.m', expi.settings.fullpath)
copyfile('C:\MatlabRoot\raycast\functional\trench_external_tcp_timerfcn.m', expi.settings.fullpath)

cd('C:\')

