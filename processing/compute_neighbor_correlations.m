clear all
close all

expdir = '/Volumes/Untitled/2016-06-21/20160621151111_41b12_az_PL';

cd(expdir)

exp_files = dir('env*');

load(exp_files(1).name)


frame_y = size(expr.c_trial.idata.df_frames,1);
frame_x = size(expr.c_trial.idata.df_frames, 2);
df_frames = expr.c_trial.idata.df_frames;

dot_map = zeros(frame_y, frame_x, length(exp_files));
var_map = zeros(frame_y, frame_x, length(exp_files));
rawF_map = zeros(frame_y, frame_x, length(exp_files));

for c_trial =25 :length(exp_files)
%c_trial = 3;
load(exp_files(c_trial).name)

if isfield(expr.c_trial, 'idata')
for ii = 2:(frame_y-1)
    for jj = 4:(frame_x-3);
   
        north_vec = df_frames(ii-1,jj);
        south_vec = df_frames(ii+1, jj);
        east_vec = df_frames(ii, jj+1);
        west_vec = df_frames(ii, jj-1);
        
        northeast_vec = df_frames(ii+1, jj+1);
        northwest_vec = df_frames(ii+1, jj-1);
        southeast_vec = df_frames(ii-1, jj+1);
        southwest_vec = df_frames(ii-1, jj-1);
        
        c_vec = df_frames(ii,jj);
        
        north_dot = dot(north_vec, c_vec);
        south_dot = dot(south_vec, c_vec);
        east_dot = dot(east_vec, c_vec);
        west_dot = dot(west_vec, c_vec);
        
     %   northeast_dot = dot(northeast_vec, c_vec);
     %   northwest_dot = dot(northwest_vec, c_vec);
     %   southeast_dot = dot(southeast_vec, c_vec);
     %   southwest_dot = dot(southwest_vec, c_vec);
        
        c_dot = mean([north_dot south_dot east_dot west_dot]); 
                     %   northeast_dot northwest_dot southeast_dot southwest_dot]);
                    
        dot_map(ii,jj, c_trial) = c_dot;
        
        var_map(:,:,c_trial) = iqr(df_frames, 3);
        rawF_map(:,:,c_trial) = mean(expr.c_trial.idata.frame_MIP, 3);
    end
    end
end

end

f1 = figure;
mean_dot_map = mean(dot_map, 3);
mean_var_map = mean(var_map, 3);
mean_rawF = mean(rawF_map, 3);

multi_map = mean_dot_map.*mean_var_map;

s1 = subplot(2,1,1);
imagesc(multi_map);
axis equal tight

s2 = subplot(2,1,2);
hist(multi_map(:), 100);

f2 = figure();
accept = 0;
while accept == 0
    
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

CC = bwconncomp(thresh_img);
B = bwboundaries(thresh_img,8);

for ii = 1:numel(CC.PixelIdxList)

    roi_auto_struct(ii).pixIdx = CC.PixelIdxList{ii};
    boundary_xy = B{ii};
    roi_auto_struct(ii).xy = [boundary_xy(:,2), boundary_xy(:,1)];
    
    pixMask = zeros(size(multi_map));
    pixMask(roi_auto_struct(ii).pixIdx) = 1;
    roi_auto_struct(ii).BW = pixMask;
    
    roi_auto_struct(ii).cmap = cMap(ii,:);


end

save('auto_roi_data.mat', 'roi_auto_struct')

mkdir('plots')
cd('plots')
close all

neuron_fig = figure();
whitebg('black')
close all
f1 = figure;


imagesc(mean_rawF);
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
