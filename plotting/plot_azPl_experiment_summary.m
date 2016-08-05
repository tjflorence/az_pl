function plot_azPl_experiment_summary(expdir)

homedir = pwd;

cd(expdir)

whitebg('w')
close all

f1 = figure('Position', [50 3 906 941], 'color', 'w', 'visible', 'off');

%% make sbd pattern to plot at side
bars = fliplr(repmat([zeros(32, 8) ones(32, 8)], [1 2]));
stripes = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
diag = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
for ii = 2:32

    diag(:,ii) = circshift(diag(:,ii), [ii-1 0]);
    
end

sbd = [stripes bars diag];
sbd = circshift(sbd, [0 -16]);
sbd_r = flipud(sbd');

dilate_factor = 10;
exp_files = dir('env*');
% load first exp file for params
load(exp_files(1).name)

if isfield(expr.c_trial, 'bdata')
    expr.c_trial.data = expr.c_trial.bdata;
end

length_heat_env = length(expr.c_trial.data.trial_th)/expr.settings.hz*dilate_factor;
test_heat_env_map = [8*ones(96,length_heat_env) sbd_r];

c_power = expr.settings.light_power;
power_vec = c_power*ones(1,96);
power_vec(38:58) = -4.99;
gaussFilter = gausswin(10);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
power_vec = conv(power_vec, gaussFilter, 'same');
power_vec(1:15) = c_power;
power_vec(80:96) = c_power;
power_vec = power_vec+7;

train_heat_env_map = [];
for ii = 1:length_heat_env
   
    train_heat_env_map = [train_heat_env_map power_vec'];
    
end
train_heat_env_map = [train_heat_env_map sbd_r];

cMap = [[0 0 0];...
        [0 1 0];...
        [linspace(.7, 1, 6)', linspace(.7, 1, 6)', linspace(1, 1, 6)' ]];
    
colormap(cMap)

dark_frames = expr.settings.dark_time*expr.settings.hz;
fix_frames = expr.settings.fix_time*expr.settings.hz;

test_files = dir('*test*');
train_files = dir('*train*');

%% pretest
s1 = subplot(5,1,1);
load(test_files(1).name)

if isfield(expr.c_trial, 'bdata')
    expr.c_trial.data = expr.c_trial.bdata;
end

imagesc(test_heat_env_map)
axis equal tight
hold on

x_vals = (-expr.c_trial.data.timestamp(dark_frames+fix_frames)+expr.c_trial.data.timestamp((dark_frames+fix_frames+1):(expr.c_trial.data.count)))*dilate_factor;
y_vals = (mod(expr.c_trial.data.trial_th+180, 360)/360)*96;
y_diff = diff(y_vals);
x_vals(y_diff>90) = nan;
x_vals(y_diff<-90) = nan;


plot([1 length_heat_env], [36 36], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)
plot([1 length_heat_env], [60 60], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)

plot(x_vals, y_vals, 'k', 'linewidth', 1.5)

box off
set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '90'},...
    'xcolor', 'w', 'FontSize', 20)

text(0, -10, 'pre-test', 'fontsize', 25)

%% trials 1-3
plot_colors = [0 0 0; .5 0 0; 1 0 0];

s2 = subplot(5,1,2);
    imagesc(train_heat_env_map)
    axis equal tight
    hold on

for ii = 1:3
    
    load(train_files(ii).name)
    
    if isfield(expr.c_trial, 'bdata')
        expr.c_trial.data = expr.c_trial.bdata;
    end

    x_vals = (-expr.c_trial.data.timestamp(dark_frames+fix_frames)+expr.c_trial.data.timestamp((dark_frames+fix_frames+1):(expr.c_trial.data.count)))*dilate_factor;
    y_vals = (mod(expr.c_trial.data.trial_th+180, 360)/360)*96;
    y_diff = [0 ;diff(y_vals)];
    x_vals(y_diff>90) = nan;
    x_vals(y_diff<-90) = nan;
    

    plot(x_vals, y_vals, 'color', plot_colors(ii,:), 'linewidth', 1.5)
end

box off
set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '+90'},...
    'xcolor', 'w', 'FontSize', 20)

text(0, -10, 'trials 1-3', 'fontsize', 25)

    if isfield(expr.settings, 'is_control')
        if expr.settings.is_control == 1
 
           z1 = fill([601 632 632 601], [0 0 96 96], [.5 .5 .5]);
           alpha(z1, .8)
           text(607, 48, '?', 'color', 'w', 'fontsize', 40)
 
        end
        
    end
    
    
%% trials 4-6
s3 = subplot(5,1,3);
    imagesc(train_heat_env_map)
    axis equal tight
    hold on

for ii = 4:6
    
    load(train_files(ii).name)
    if isfield(expr.c_trial, 'bdata')
        expr.c_trial.data = expr.c_trial.bdata;
    end


    x_vals = (-expr.c_trial.data.timestamp(dark_frames+fix_frames)+expr.c_trial.data.timestamp((dark_frames+fix_frames+1):(expr.c_trial.data.count)))*dilate_factor;
    y_vals = (mod(expr.c_trial.data.trial_th+180, 360)/360)*96;
    y_diff = [0 ;diff(y_vals)];
    x_vals(y_diff>90) = nan;
    x_vals(y_diff<-90) = nan;



    plot(x_vals, y_vals, 'color', plot_colors(ii-3,:), 'linewidth', 1.5)
end

box off
set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '+90'},...
    'xcolor', 'w', 'FontSize', 20)

text(0, -10, 'trials 4-6', 'fontsize', 25)
ylabel('orientation \newline (degrees)')

    if isfield(expr.settings, 'is_control')
        if expr.settings.is_control == 1
 
           z1 = fill([601 632 632 601], [0 0 96 96], [.5 .5 .5]);
           alpha(z1, .8)
           text(607, 48, '?', 'color', 'w', 'fontsize', 40)
 
        end
        
    end
    

%% trials 7-9
s4 = subplot(5,1,4);
    imagesc(train_heat_env_map)
    axis equal tight
    hold on

for ii = 7:9
    
    load(train_files(ii).name)
    
    if isfield(expr.c_trial, 'bdata')
        expr.c_trial.data = expr.c_trial.bdata;
    end

    x_vals = (-expr.c_trial.data.timestamp(dark_frames+fix_frames)+expr.c_trial.data.timestamp((dark_frames+fix_frames+1):(expr.c_trial.data.count)))*dilate_factor;
    y_vals = (mod(expr.c_trial.data.trial_th+180, 360)/360)*96;
    y_diff = [0 ;diff(y_vals)];
x_vals(y_diff>90) = nan;
x_vals(y_diff<-90) = nan;


    plot(x_vals, y_vals, 'color', plot_colors(ii-6,:), 'linewidth', 1.5)
end

box off
set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '+90'},...
    'xcolor', 'w', 'FontSize', 20)

text(0, -10, 'trials 7-9', 'fontsize', 25)

    if isfield(expr.settings, 'is_control')
        if expr.settings.is_control == 1
 
           z1 = fill([601 632 632 601], [0 0 96 96], [.5 .5 .5]);
           alpha(z1, .8)
           text(607, 48, '?', 'color', 'w', 'fontsize', 40)
 
        end
        
    end
    

s5 = subplot(5,1,5);

load(test_files(2).name)
if isfield(expr.c_trial, 'bdata')
    expr.c_trial.data = expr.c_trial.bdata;
end

imagesc(test_heat_env_map)
axis equal tight
hold on

x_vals = (-expr.c_trial.data.timestamp(dark_frames+fix_frames)+expr.c_trial.data.timestamp((dark_frames+fix_frames+1):(expr.c_trial.data.count)))*dilate_factor;
y_vals = (mod(expr.c_trial.data.trial_th+180, 360)/360)*96;
y_diff = diff(y_vals);
x_vals(y_diff>90) = nan;
x_vals(y_diff<-90) = nan;


plot([1 length_heat_env], [36 36], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)
plot([1 length_heat_env], [60 60], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)

plot(x_vals, y_vals, 'k', 'linewidth', 1.5)
text(0, -10, 'post-test', 'fontsize', 25)

box off
set(gca,  'XTick', [0 150 300 450 ], 'XTickLabel', {'0', '15', '30', '45'}, ...
    'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '+90'},...
   'FontSize', 20)
xlabel('time (sec)')

mkdir('plots')
cd('plots')

set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print(f1, ['az_experiment_summary.pdf'], '-dpdf', '-r0', '-opengl');

cd(homedir)

