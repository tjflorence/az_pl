function plot_azPL_azTuning_raw(expdir)

homedir = pwd;
cd(expdir)

close all

ol_files = dir('OL*');
load('roi_data.mat')

for aa = 1:length(roi_struct)
load(ol_files(1).name)

c_trace = expr.c_trial.idata.auto_roi_traces(aa,:);
c_pos = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
c_vec = [];

for ii = 1:96
    
    c_vec = [mean(c_trace(find(c_pos==ii))) c_vec ];
    
end

whitebg('w')
close all
f1 = figure('color', 'w', 'Position', [68   402   662   540], 'visible', 'off');

s1 = subplot(3,1,1);
load(ol_files(1).name)

    pos_vec = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1))/96*360;
   % pos_vec = mod((pos_vec+180), 360);
    tstamp_vec = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
    
    z1 = fill([0 expr.c_trial.dark_time expr.c_trial.dark_time 0], [0 0 400 400],...
        [.5 .5 .5], 'EdgeColor', 'none');
    alpha(z1, .5)
    
    hold on
    
    plot(tstamp_vec, pos_vec, 'r', 'linewidth', 2)
    
    ylim([0 360])
    xlim([0 70])
    
    set(gca, 'YTick', [0 180 360], 'XTick', [], 'Fontsize', 25)
    ylabel(' pattern \newlineposition')
    
    box off

s2 = subplot(3,1,2);

    dF_vec = expr.c_trial.idata.auto_roi_traces(aa,1:end-1);
    tstamp_vec = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
    
    z1 = fill([0 expr.c_trial.dark_time expr.c_trial.dark_time 0], [-400 -400 400 400],...
        [.5 .5 .5], 'EdgeColor', 'none');
    alpha(z1, .5)
    
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    plot(tstamp_vec, dF_vec, 'k', 'linewidth', 2)
    
    ylim([1.1*min(dF_vec) 1.1*max(dF_vec)])
    xlim([0 70])

    set(gca, 'XTick', [], 'Fontsize', 25)
    ylabel('dF/F \newline(pre)')
    
    box off
    
s3 = subplot(3,1,3);

load(ol_files(2).name)

    dF_vec = expr.c_trial.idata.auto_roi_traces(aa,1:end-1);
    tstamp_vec = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
    
    z1 = fill([0 expr.c_trial.dark_time expr.c_trial.dark_time 0], [-400 -400 400 400],...
        [.5 .5 .5], 'EdgeColor', 'none');
    alpha(z1, .5)
    
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    plot(tstamp_vec, dF_vec, 'k', 'linewidth', 2)
    
    ylim([1.1*min(dF_vec) 1.1*max(dF_vec)])
    xlim([0 70])
    
    set(gca, 'XTick', [0 35 70], 'Fontsize', 25)
    ylabel('dF/F \newline(post)')
    xlabel('time (sec)')
    
    box off
    
  mkdir('plots')
  cd('plots')
  
  
  set(f1, 'Units', 'Inches')
  pos = get(f1, 'position');
  set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print(f1, ['direction_tuning_raw_ROI_' num2str(aa, '%03d') '.pdf'], '-dpdf', '-r0', '-opengl');

close all
cd('..')

end

cd(homedir)
end


