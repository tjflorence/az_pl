function roi_select_oct(trial)

home_dir = pwd;

exp_trials = dir('env*');
load(exp_trials(trial).name)

df_stack = std(expr.c_trial.idata.mcorr_MIP, [],  3);
%for ii = 2:45
for ii = trial
   
    load(exp_trials(ii).name)
    if isfield(expr.c_trial, 'idata')
        std_var = std(expr.c_trial.idata.mcorr_MIP,[], 3);
        df_stack = cat(3, df_stack, std_var);
    end
end

cMap = [255, 70, 69; ...
        186, 48, 232; ...
        65, 76, 255; ...
        48, 201, 232; ...
        24, 255, 103; ...
        232, 232, 45; ...
        232, 131, 17]./255;
    
cMap = repmat(cMap, [100, 1]);

neuron_fig = figure;
whitebg('black')
close all;

mdf_stack = mean(df_stack, 3);

data_to_hist = mdf_stack(4:end-3, 4:end-3);
hist(data_to_hist(:), 100);
ylim

low_val = input('select low val');
hi_val = input('select high val')

imagesc(mdf_stack);
caxis([low_val hi_val])
colormap(kjetsmooth(2^8))
axis equal off

roi_response = 1;
ii = 1;

while roi_response ~= 0
  
  mask_response = 0;
  while mask_response ~= 1
    
    disp('select next ROI');
    [BW, xi, yi] = roipoly;
  
    roi_struct(ii).xy = [xi, yi];
  
    
    temp_mask_fig = figure();
    imagesc(BW)
    colormap(gray)
    axis equal off
  
    mask_response = input('accept mask? 1 = yes, 2 = no');
    close(temp_mask_fig)
  
  end
  
  roi_struct(ii).mask = BW;
  roi_struct(ii).cmap = cMap(ii,:);
  hold on
  
  scat_h = fill(xi, yi, cMap(ii,:));
  set(scat_h, 'MarkerFaceColor', cMap(ii,:), 'MarkerEdgeColor', 'w');
  
  roi_response = input('additional ROI? 1 = yes, 0 = no (complete)');
  
  ii = ii+1;
  
    
    
end

save('roi_data.mat', 'roi_struct')

mkdir('plots')
cd('plots')
close all

neuron_fig = figure();
whitebg('black')
close all
f1 = figure;

img_F = std(expr.c_trial.idata.mcorr_dF,[], 3);
imagesc(mdf_stack);

min_val = min(min(img_F(4:end-3, 4:end-3)));
max_val = max(max(img_F(4:end-3, 4:end-3)));
caxis([min_val max_val]);

colormap([0,0,0; 0,0,0; gray(8)])
axis equal off

hold on
for jj = 1:length(roi_struct)
    
  scat_h = fill(roi_struct(jj).xy(:,1), roi_struct(jj).xy(:,2), cMap(jj,:));
  set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_struct(jj).cmap);
  
end

set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print(f1, ['selected_roi.pdf'], '-dpdf', '-r0', '-opengl');


cd(home_dir);
end

