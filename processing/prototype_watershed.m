exp_files = dir('env*');
ol_files = dir('OL_*');
test_files = dir('*test*');

all_files = [exp_files; ol_files];

c_load = 1;
correct_load = 0;

while correct_load == 0
    load(exp_files(c_load).name)
    
    if isfield(expr.c_trial, 'idata')
        correct_load = 1;
    else
        c_load = c_load+1;
        
    end

end

frame_y = size(expr.c_trial.idata.df_frames,1);
frame_x = size(expr.c_trial.idata.df_frames, 2);
df_frames = expr.c_trial.idata.df_frames;

dot_map = zeros(frame_y, frame_x, length(exp_files));
var_map = zeros(frame_y, frame_x, length(exp_files));
rawF_map = zeros(frame_y, frame_x, length(exp_files));

%% find ROI for all trials
disp('******************************')
disp('calculating ROI for all trials')
disp('******************************')

for c_trial =1:2 :length(all_files)

    disp(['loading trial: ' num2str(c_trial) ' of ' num2str(length(all_files))])
    load(all_files(c_trial).name)

    
if isfield(expr.c_trial, 'idata')
    for ii = 4:(frame_y-3)
        for jj = 4:(frame_x-3);
   
            df_frames = expr.c_trial.idata.mcorr_dF;
            
            north_vec = squeeze(df_frames(ii-1,jj, :));
            south_vec = squeeze(df_frames(ii+1, jj, :));
            east_vec = squeeze(df_frames(ii, jj+1, :));
            west_vec = squeeze(df_frames(ii, jj-1,: ));
        
            northeast_vec = squeeze(df_frames(ii+1, jj+1, :));
            northwest_vec = squeeze(df_frames(ii+1, jj-1, :));
            southeast_vec = squeeze(df_frames(ii-1, jj+1, :));
            southwest_vec = squeeze(df_frames(ii-1, jj-1, :));
        
            c_vec = squeeze(df_frames(ii,jj, :));
        
            north_dot = dot(north_vec, c_vec);
            south_dot = dot(south_vec, c_vec);
            east_dot = dot(east_vec, c_vec);
            west_dot = dot(west_vec, c_vec);
            
        
        northeast_dot = dot(northeast_vec, c_vec);
        northwest_dot = dot(northwest_vec, c_vec);
        southeast_dot = dot(southeast_vec, c_vec);
        southwest_dot = dot(southwest_vec, c_vec);
        
            c_dot = mean([north_dot south_dot east_dot west_dot...; 
                        northeast_dot northwest_dot southeast_dot southwest_dot]);
                    
            dot_map(ii,jj, c_trial) = c_dot;
        
        %    var_map(:,:,c_trial) = iqr(df_frames, 3);
            rawF_map(:,:,c_trial) = mean(expr.c_trial.idata.mcorr_dF, 3);
        end
    end
end

end

f1 = figure;
mean_dot_map = mean(dot_map, 3);
%mean_var_map = mean(var_map, 3);
mean_rawF = mean(rawF_map, 3);

multi_map = mean_dot_map;%.*mean_var_map;

s1 = subplot(2,1,1);
imagesc(multi_map);
axis equal tight

s2 = subplot(2,1,2);
hist(multi_map(:), 100);

f2 = figure();
accept = 0;
while accept ~= 1
    
    thresh = input('input img thresh: ');

    thresh_img = zeros(size(multi_map));
    

    thresh_img((multi_map>thresh)) = 1;
    
    imagesc(thresh_img)
    colormap(gray)
    axis equal tight
    
    accept = input('is acceptable? 1=yes: ');

end

cMap = [255, 70, 69; ...
        186, 48, 232; ...
        65, 76, 255; ...
        48, 201, 232; ...
        24, 255, 103; ...
        232, 232, 45; ...
        232, 131, 17]./255;
    
cMap = repmat(cMap, [100, 1]);

D = bwdist(~thresh_img);
D = -D;
D(~thresh_img) = -Inf;

L = watershed(D);
bin_watershed = zeros(size(L));
bin_watershed(L>1) = 1;

    CC = bwconncomp(bin_watershed);
    B = bwboundaries(bin_watershed,8);

for ii = 1:numel(CC.PixelIdxList)

    roi_auto_struct(ii).pixIdx = CC.PixelIdxList{ii};
    boundary_xy = B{ii};
    roi_auto_struct(ii).xy = [boundary_xy(:,2), boundary_xy(:,1)];
    
    pixMask = zeros(size(multi_map));
    pixMask(roi_auto_struct(ii).pixIdx) = 1;
    roi_auto_struct(ii).BW = pixMask;
    
    roi_auto_struct(ii).cmap = cMap(ii,:);


end
    

%% now save
save('auto_roi_data.mat', 'roi_auto_struct')

mkdir('plots')
cd('plots')
close all

neuron_fig = figure();
whitebg('black')
close all
f1 = figure;


imagesc(mean_rawF);

min_val = min(min(mean_rawF(4:end-3, 4:end-3)));
max_val = max(max(mean_rawF(4:end-3, 4:end-3)));
caxis([min_val max_val]);

colormap([0,0,0; 0,0,0; gray(2^8)])
axis equal off

hold on
for jj = 1:length(roi_auto_struct)
    
  scat_h = fill(roi_auto_struct(jj).xy(:,1), roi_auto_struct(jj).xy(:,2), 'r');
  set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_auto_struct(jj).cmap);
  
end

set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);


print(f1, ['auto_selected_roi.pdf'], '-dpdf', '-r0', '-opengl');

cd(expdir)
