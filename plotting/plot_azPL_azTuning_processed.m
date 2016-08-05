function plot_azPL_azTuning_processed(expdir, is_auto)

homedir = pwd;
cd(expdir)

whitebg('white')
close all

ola_files = dir('OL_A*');
olb_files = dir('OL_B*');

if isempty(is_auto)
    is_auto = 0;
end

if is_auto == 0
    load('roi_data.mat')
else
    load('auto_roi_data.mat');
    roi_struct = roi_auto_struct;
end
    
for aa = 1:length(roi_struct)


f1 = figure('color', 'w', 'Position', [68   402   662   540], 'visible', 'off');

s1 = subplot(3,1,1);

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

   % sbd = [stripes bars diag];
    sbd = circshift(sbd, [0 -16]);
    sbd_r = flipud(fliplr(sbd));

    
    gcMap = [[0 0 0];...
            [0 1 0]];
            
    imagesc(sbd_r);
    axis equal off tight
    box off
    
    colormap(gcMap);
    freezeColors();
    
 s2 = subplot(3,1,2);
   
    
    grand_cvec = [];
    for bb = 1:length(ola_files)
                load(ola_files(bb).name)

       if isfield(expr.c_trial, 'idata')


        if is_auto == 0
            c_trace = expr.c_trial.idata.roi_traces(aa,:);
        else
             c_trace = expr.c_trial.idata.auto_roi_traces(aa,:);
        end
        
        c_pos = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
        c_vec = [];
        x_vec = [];
    
        for ii = 3:3:96
    
            c_vec = [mean(c_trace(find(c_pos==ii))) c_vec ];
            x_vec = [ii x_vec];
    
        end
        
        grand_cvec = [grand_cvec; c_vec];
        end
    
    end
    grand_cvec = circshift(grand_cvec, [0 48]);
    
    for bb = 1:size(grand_cvec, 1);
        plot(x_vec, grand_cvec(bb,:), 'r', 'linewidth', 1)
        hold on
    
    end
    plot(x_vec, mean(grand_cvec), 'k', 'linewidth', 2)

    xlim([1 96])
    ylim([1.1*min(min(grand_cvec)) 1.1*max(max(grand_cvec))])
    box off
    
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    s2_pos = get(s2, 'position');
    set(s2, 'position', [s2_pos(1)+.145 s2_pos(2) s2_pos(3)*.66 s2_pos(4)])
    
    set(gca, 'XColor', 'w', 'Fontsize', 25)
    ylabel('dF/F\newline(pre)')

    
s3 = subplot(3,1,3);

    grand_cvec = [];
    for bb = 1:length(olb_files)
                load(olb_files(bb).name)

        if isfield(expr.c_trial, 'idata')


        if is_auto == 0
            c_trace = expr.c_trial.idata.roi_traces(aa,:);
        else
             c_trace = expr.c_trial.idata.auto_roi_traces(aa,:);
        end
        
        c_pos = expr.c_trial.bdata.xpos(expr.c_trial.idata.img_frame_id(1:end-1));
        c_vec = [];
        x_vec = [];
    
        for ii = 3:3:96
    
            c_vec = [mean(c_trace(find(c_pos==ii))) c_vec ];
            x_vec = [ii x_vec];
    
        end
        
        grand_cvec = [grand_cvec; c_vec];
        end
        
    end
    grand_cvec = circshift(grand_cvec, [0 48]);
    
    for bb = 1:size(grand_cvec, 1);
        plot(x_vec, grand_cvec(bb,:), 'r', 'linewidth', 1)
        hold on
    
    end
    plot(x_vec, mean(grand_cvec), 'k', 'linewidth', 2)
    hold on
    
    plot([-1000 1000], [0 0], 'k')
    
        xlim([1 96])
  %  ylim([.9*min(min(grand_cvec)) 1.1*max(max(grand_cvec))])
    
    s3_pos = get(s3, 'position');
    set(s3, 'position', [s3_pos(1)+.145 s3_pos(2) s3_pos(3)*.66 s3_pos(4)])
    
    set(gca, 'XColor', 'w', 'Fontsize', 25)
    
    ylabel('dF/F\newline (post)')

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

