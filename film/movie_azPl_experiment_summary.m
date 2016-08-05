function movie_azPl_experiment_summary(expdir, expver)


homedir = pwd;
cd(expdir)


whitebg('w')
close all

exp_files = dir('env*');

for c_trial = 1:length(exp_files);

%% sort trial names to put them in rep order
bfiles = dir('env*');
    for ii = 1:length(bfiles)
       
        for jj = 1:length(bfiles)
            
            split_name = strsplit(bfiles(jj).name, '.mat');
            split_part = split_name{1};
            split_num = str2num(split_part(end-2:end));
            
            if split_num == ii
                
                bsort(ii).name = bfiles(jj).name;
                
            end
            
        end
        
    end
    
c_file = bsort(c_trial);

if  ~isempty(strfind(c_file.name, 'test'))
    
    
    is_test_trial = 1;
    
else
    
    is_test_trial = 0;
    
end
   
%% load current trial
load(c_file.name);
 

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

%% make environment(s)
dilate_factor = 10;
% load first exp file for params

length_heat_env = round(length(expr.c_trial.bdata.trial_th)/expr.settings.hz*dilate_factor);
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

train_heat_env_map = [8*ones(96, expr.c_trial.dark_time*dilate_factor) ...
                     8*ones(96, expr.c_trial.fix_time*dilate_factor) ...
                     train_heat_env_map sbd_r];

cMap = [ [0 0 0];...
        [0 0 0];...
        [0 1 0];...
        [linspace(.7, 1, 6)', linspace(.7, 1, 6)', linspace(1, 1, 6)' ]];
    


dark_frames = expr.settings.dark_time*expr.settings.hz;
fix_frames = expr.settings.fix_time*expr.settings.hz;
    

if is_test_trial == 1
    c_heat_env = test_heat_env_map;
else
    c_heat_env = train_heat_env_map;
end

dark_frames = expr.settings.dark_time*expr.settings.hz;
fix_frames = expr.settings.fix_time*expr.settings.hz;

fnum = 0;

mkdir('movie_frames')
cd('movie_frames')

%% loop controls printing frames
%for ii = 2000
for ii = 1:4:expr.c_trial.bdata.count;

    close all
    
    fnum = fnum+1;
    f1 = figure('Position', [50 62 1457 882], 'color', 'w', 'visible', 'off');
    
    %% current imaging frame
    s1 = subplot(4,4, [1 2 5 6]);
    set(s1, 'Tag', 'ca_img');

    c_imgframe_idx = expr.c_trial.bdata.c_iframe(ii);
    c_imgframe = expr.c_trial.idata.df_frames(:,:,c_imgframe_idx);
    img_h = imagesc(c_imgframe(5:end-4, 5:end-4));
    caxis([.2 1])
    colormap(gca, kjetsmooth)
    axis equal off
    
    cmap = colormap(gca);
    cbar1 = colorbar(s1);

    set(cbar1, 'YTick', [.2 .5 1 1.5],...
        'YTickLabel', {'<0.2     ', '0.5     ', '1.0     ', '1.5     '  }, 'Fontsize', 25);
    ylabel(cbar1, 'dF/F', 'Rotation', -90, 'fontsize', 30)
    
    %% fly view frame
  %  s2 = subplot(4,4, [3 4 7 8]);
    
    
    %% trajectory in 1D space
    s3 = subplot(4,4, [9 10 11 12]);
    imagesc(c_heat_env)

    colormap(s3, cMap)
    caxis([-2 8])
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
   

    x_vals = expr.c_trial.bdata.timestamp(1:expr.c_trial.bdata.count)*dilate_factor;
    y_vals = (mod(expr.c_trial.bdata.th+180, 360)/360)*96;
    y_diff = diff(y_vals);
    x_vals(y_diff>90) = nan;
    x_vals(y_diff<-90) = nan;

    if is_test_trial == 1

        plot([1 length_heat_env]+(expr.settings.dark_time+expr.settings.fix_time)*dilate_factor, [36 36], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)
        plot([1 length_heat_env]+(expr.settings.dark_time+expr.settings.fix_time)*dilate_factor, [60 60], 'linestyle', '--', 'color', [.7 .7 .7], 'linewidth', 1.5)

    end
    
    c_xvals = x_vals(1:ii);
    c_yvals = y_vals(1:ii);
    
    plot(c_xvals, c_yvals, 'k', 'linewidth', 1.5)
    c1 = scatter(c_xvals(end), c_yvals(end), 100);
    set(c1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.6 .6 .6]);

    box off
    set(gca, 'XTick', [], 'YTick', [24 48 72], 'YTickLabel', {'-90', '0', '90'},...
        'xcolor', 'w', 'FontSize', 20)

    ylabel('fly heading \newline(degrees)')
    
    %% total ball rotation
    s4 = subplot(4,4, [13 14 15 16]);
    hold on
    
    sm_vfwd = conv(expr.c_trial.bdata.vfwd, ones(25,1)/25, 'same');
    sm_om = conv(expr.c_trial.bdata.om, ones(25,1)/25, 'same');
    
    vfwd_yvals = sm_vfwd(1:ii);
    om_yvals = sm_om(1:ii);
    
    plot([-100000 10000], [0 0], 'k')
    plot(c_xvals, vfwd_yvals, 'color', 'r', 'linewidth', 1.5);
    c1 = scatter(c_xvals(end), vfwd_yvals(end), 100);
    set(c1, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    
    plot(c_xvals, om_yvals, 'color', 'b', 'linewidth', 1.5);
    c1 = scatter(c_xvals(end), om_yvals(end), 100);
    set(c1, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    
    if expver == 1
        xlim([0 700])
    elseif expver == 2
        xlim([0 650])
    end
    
    ylim([-2.5 2.5])
    
    set(gca,  'XTick', [0 150 300 450 600], 'XTickLabel', {'0', '15', '30', '45', '60'}, ...
        'YTick', [-2.5 0 2.5],  'FontSize', 20);
    
    xlabel('time (sec)')
    ylabel('ball motion\newline     (AU)')
    
    if expver == 1
        text(750, 2.5, 'Fwd', 'Color', 'r', 'Fontsize', 20)
        text(750, 1.5, 'Yaw', 'Color', 'b', 'Fontsize', 20)
    elseif expver ==2
        text(700, 2.5, 'Fwd', 'Color', 'r', 'Fontsize', 20)
        text(700, 1.5, 'Yaw', 'Color', 'b', 'Fontsize', 20)
    end

    %% adjust position
    s3_p = get(s3, 'Position');
    set(s3, 'Position', [s3_p(1)-.021 s3_p(2:4)])
    
    if expver == 1
        s4_p = get(s4, 'Position');
        set(s4, 'Position', [s4_p(1:2) s4_p(3)-.08 s4_p(4)])
    elseif expver == 2
        s4_p = get(s4, 'Position');
        set(s4, 'Position', [s4_p(1)+.025 s4_p(2) s4_p(3)-.125 s4_p(4)])
    end
    
    s1_p = get(s1, 'Position');
    set(s1, 'Position', [s1_p(1)-.065 s1_p(2:4)])

   % cbar_p = get(cbar1, 'Position');
   % set(cbar1, 'Position', [cbar_p(1)-.05 cbar_p(2:4)])

    
    set(f1, 'Units', 'Inches')
    pos = get(f1, 'position');
    set(f1, 'PaperPositionMode','Auto',...
        'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

    print(f1, ['frame_'  num2str(fnum, '%05d') '.bmp'], '-dbmp', '-r50', '-opengl');

end

trial_num = num2str(c_trial, '%02d');

success = system(['ffmpeg -framerate 25 -i frame_%05d.bmp -c:v libx264 -r 30 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" ../movie_trial_' trial_num '.mp4']);
if success ~=0 
    path1 = getenv('PATH');
    path1 = [path1 ':/usr/local/bin'];
    setenv('PATH', path1);
    success = system(['ffmpeg -framerate 25 -i frame_%05d.bmp -c:v libx264 -r 30 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" ../movie_trial_' trial_num '.mp4']);
end


cd('..')
rmdir('movie_frames','s')

end
cd(homedir)

end
