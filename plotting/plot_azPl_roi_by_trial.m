function plot_azPl_roi_by_trial(expdir, expver, is_auto)


homedir = pwd;
cd(expdir)

whitebg('w')
close all

exp_files = dir('env*');

if is_auto == 0
    load('roi_data.mat');
elseif isempty(is_auto)
    is_auto = 0;
else
    load('auto_roi_data.mat');
    roi_struct = roi_auto_struct;
end


kk = 1; %roi
jj = 1; %trial


%% make sbd pattern to plot at side
bars = fliplr(repmat([zeros(32, 8) ones(32, 8)], [1 2]));
stripes = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
diag = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
for ii = 2:32

    diag(:,ii) = circshift(diag(:,ii), [ii-1 0]);
    
end
boxes = [zeros(4,4) ones(4,4);ones(4,4) zeros(4,4)];
boxes = repmat(boxes, [4 4]);

sbd = [boxes bars diag];
sbd = circshift(sbd, [0 -16]);
sbd_r = flipud(sbd');

%% make environment(s)
dilate_factor = 10;
exp_files = dir('env*');
% load first exp file for params
load(exp_files(5).name)

if isfield(expr.c_trial, 'bdata')
    expr.c_trial.data = expr.c_trial.bdata;

end

length_heat_env = round(length(expr.c_trial.data.trial_th)/expr.settings.hz*dilate_factor);
test_heat_env_map = [8*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     8*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     8*ones(96,length_heat_env) sbd_r];

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

train_map(1).map = [-2*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     -1*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     train_heat_env_map sbd_r];
                 
train_map(2).map = [-2*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     -1*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     train_heat_env_map circshift(sbd_r, [24 0])];
                 
train_map(3).map = [-2*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     -1*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     train_heat_env_map circshift(sbd_r, [48 0])];
                 
train_map(4).map = [-2*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     -1*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     train_heat_env_map circshift(sbd_r, [48 0])];

cMap = [
        [0 0 0];...
        [0 1 0];...
        [linspace(.7, 1, 6)', linspace(.7, 1, 6)', linspace(1, 1, 6)' ]];
    


dark_frames = expr.settings.dark_time*expr.settings.hz;
fix_frames = expr.settings.fix_time*expr.settings.hz;



%% create plot
for kk = 1:length(roi_struct)
    for jj = 1:length(exp_files)
        
f1 = figure('Position', [50 3 906 941], 'color', 'w', 'visible', 'off');

load(exp_files(jj).name)

if isfield(expr.c_trial, 'idata')
s3 = subplot(4,3,1:2);
imagesc(max(expr.c_trial.idata.mcorr_MIP,[], 3));
colormap(gray)
axis equal off tight
hold on


hold on

    c_xy = roi_struct(kk).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(kk).cmap);
 
 
 

s3_p = get(s3, 'Position');


if isfield(expr.c_trial, 'bdata')
    expr.c_trial.data = expr.c_trial.bdata;
end


if isempty( find(expr.c_trial.light_vec<expr.settings.light_power))
    is_mock = 1;
else
    is_mock = 0; 
end

if ~isfield(expr.c_trial, 'rand_pat')
    map_num = 1;
else
    map_num = expr.c_trial.rand_pat-1;
end

%% behavior trace
s1 = subplot(4,3,4:6);

if is_mock == 1
    
    imagesc(test_heat_env_map)
    colormap(gca, cMap)
    caxis([0 8])
    axis equal tight
    hold on
    plot([1 length(test_heat_env_map)], [36 36], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)
    plot([1 length(test_heat_env_map)], [60 60], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)


    z1 = fill([0 expr.c_trial.dark_time*dilate_factor expr.c_trial.dark_time*dilate_factor 0],...
               [1 1 96 96], [0 0 0], 'EdgeColor', 'none');
    
    alpha(z1, .5)
    
    z2 = fill([(expr.settings.dark_time*dilate_factor)+1 ...
                (expr.settings.dark_time+expr.settings.fix_time)*dilate_factor...
                (expr.settings.dark_time+expr.settings.fix_time)*dilate_factor...
                (expr.c_trial.dark_time*dilate_factor)+1 ],...
               [1 1 96 96], [.6 .6 .6], 'EdgeColor', 'none');
           
   alpha(z2, .5)
    
else
    imagesc(train_map(map_num).map)
    colormap(gca, cMap)
    caxis([0 8])
    axis equal tight
    hold on
    
        z1 = fill([0 expr.c_trial.dark_time*dilate_factor expr.c_trial.dark_time*dilate_factor 0],...
               [1 1 96 96], [0 0 0], 'EdgeColor', 'none');
    
    alpha(z1, .5)
    
    z2 = fill([(expr.settings.dark_time*dilate_factor)+1 ...
                (expr.settings.dark_time+expr.settings.fix_time)*dilate_factor...
                (expr.settings.dark_time+expr.settings.fix_time)*dilate_factor...
                (expr.c_trial.dark_time*dilate_factor)+1 ],...
               [1 1 96 96], [.6 .6 .6], 'EdgeColor', 'none');
           
   alpha(z2, .5)
end

x_vals = expr.c_trial.data.timestamp(1:expr.c_trial.data.count)*dilate_factor;
y_vals = (mod(expr.c_trial.data.th(1:expr.c_trial.data.count)+180, 360)/360)*96;
y_diff = diff(y_vals);
x_vals(y_diff>90) = nan;
x_vals(y_diff<-90) = nan;

plot(x_vals, y_vals, 'k', 'linewidth', 1.5)

box off
set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '90'},...
    'xcolor', 'w', 'FontSize', 20)

ylabel('     angular \newline position (deg)')

box off

%% roi trace
s2 = subplot(4,3,7:9);
x_vals = expr.c_trial.data.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));

if is_auto == 0
    y_vals = expr.c_trial.idata.roi_traces(kk,1:end-1);
else
    y_vals = expr.c_trial.idata.auto_roi_traces(kk,1:end-1);
end

plot(x_vals, y_vals, 'color', roi_struct(kk).cmap, 'linewidth', 2);
hold on
plot([-1000 1000], [0 0], 'k')

if expver == 1
    xlim([0 70])
    set(gca, 'XTick', [], 'Fontsize', 25)

elseif expver == 2
    xlim([0 65])
    set(gca, 'XTick', [], 'Fontsize', 25)

end

ylim([1.1*min(y_vals) 1.1*max(y_vals)])

box off


s2_p = get(s2, 'Position');
set(s2, 'Position', [s2_p(1) s2_p(2) s2_p(3)*.95 s2_p(4)])

ylabel('dF/F')


%% total ball rotation
s4 = subplot(4,3, [10 11 12]);
hold on

x_vals = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count);

vfwd_yvals = conv(expr.c_trial.bdata.vfwd(1:expr.c_trial.bdata.count), ones(25,1)/25, 'same');
om_yvals = conv(expr.c_trial.bdata.om(1:expr.c_trial.bdata.count), ones(25,1)/25, 'same');
    


plot([-100000 10000], [0 0], 'k')


plot(x_vals, vfwd_yvals, 'color', 'r', 'linewidth', 1.5);
plot(x_vals, om_yvals, 'color', 'b', 'linewidth', 1.5);


ylim([-2.5 2.5])

if expver == 1
    xlim([0 70])
    set(gca,  'XTick', [0 35 70], 'XTickLabel', {'0', '35', '70'}, ...
        'YTick', [-2.5 0 2.5],  'FontSize', 25);
    
    text(70, .8, 'vFwd', 'Color', 'r', 'Fontsize', 25)
    text(70, .5, 'Yaw', 'Color', 'b', 'Fontsize', 25)

elseif expver == 2
    xlim([0 65])
    set(gca,  'XTick', [0 30 60], 'XTickLabel', {'0', '30', '60'}, ...
        'YTick', [-2.5 0 2.5],  'FontSize', 25);    

    text(65, .8, 'vFwd', 'Color', 'r', 'Fontsize', 25)
    text(65, .5, 'Yaw', 'Color', 'b', 'Fontsize', 25)
end
xlabel('time (sec)')
ylabel('ball motion\newline     (AU)')

s4_p = get(s4, 'position');
set(s4, 'Position', [s4_p(1) s4_p(2) s4_p(3)*.95 s4_p(4)])


s1_p = get(s1, 'Position');
set(s1, 'Position', [s1_p(1) s1_p(2)-.08 s1_p(3) s1_p(4)*2])

mkdir('plots')
cd('plots')

set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);


print(f1, ['trace_by_trial_ROI_' num2str(kk, '%03d') '_trial_' num2str(expr.c_trial.rep, '%03d') '.pdf'],...
            '-dpdf', '-r0', '-opengl');
        
cd('..')
close all
end
    end
end


cd(homedir)


