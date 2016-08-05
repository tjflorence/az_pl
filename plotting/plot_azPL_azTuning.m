function plot_azPL_azTuning_processed(expdir)

homedir = pwd;
cd(expdir)

close all

ol_files = dir('OL*');
load('roi_data.mat')

for aa = 1:length(roi_struct)

load(ol_files(1).name)

f1 = figure('color', 'w', 'Position', [68   402   662   540], 'visible', 'off');

s1 = subplot(3,1,1);
load(ol_files(1).name)

    %% make sbd pattern to plot at side
    bars = fliplr(repmat([zeros(32, 8) ones(32, 8)], [1 2]));
    stripes = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
    diag = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
    for ii = 2:32

        diag(:,ii) = circshift(diag(:,ii), [ii-1 0]);
    
    end

    sbd = [stripes bars diag];
    sbd = circshift(sbd, [0 -16]);
    sbd_r = flipud(sbd);

    
    gcMap = [[0 0 0];...
            [0 1 0]]...
            
    imagesc(sbd_r);
    axis equal off tight
    box off
    
    colormap(gcMap);
    freezeColors();
    
 s2 = subplot(3,1,2);
   

    c_trace = expr.c_trial.idata.roi_traces(aa,:);
    c_pos = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
    c_vec = [];

    for ii = 1:96
    
        c_vec = [mean(c_trace(find(c_pos==ii))) c_vec ];
    
    end
    
    c_vec = circshift(c_vec, [0 48])
    
    plot(c_vec)
    xlim([1 96])
    ylim([1.1*min(c_vec) 1.1*max(c_vec)])
    box off
    
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    s2_pos = get(s2, 'position');
    set(s2, 'position', [s2_pos(1)+.145 s2_pos(2) s2_pos(3)*.66 s2_pos(4)])
    
    set(gca, 'XColor', 'w')

    
s3 = subplot(3,1,3);

load(ol_files(2).name)

    c_trace = expr.c_trial.idata.roi_traces(aa,:);
    c_pos = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
    c_vec = [];

    for ii = 1:96
    
        c_vec = [mean(c_trace(find(c_pos==ii))) c_vec ];
    
    end
    
    c_vec = circshift(c_vec, [0 48])
    
    plot(c_vec)
    xlim([1 96])
    ylim([1.1*min(c_vec) 1.1*max(c_vec)])
    box off
    
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    s3_pos = get(s3, 'position');
    set(s3, 'position', [s3_pos(1)+.145 s3_pos(2) s3_pos(3)*.66 s3_pos(4)])
    
    set(gca, 'XColor', 'w')
  mkdir('plots')
  cd('plots')
  
  
  set(f1, 'Units', 'Inches')
  pos = get(f1, 'position');
  set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print(f1, ['direction_tuning_processed_ROI_' num2str(aa, '%03d') '.pdf'], '-dpdf', '-r0', '-opengl');

%close all
cd('..')

end

cd(homedir)
end

