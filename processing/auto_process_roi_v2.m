function auto_process_roi_v2(expdir)

cd(expdir)


num_sample_frames = 100;

cMap = [255, 70, 69; ...
        186, 48, 232; ...
        65, 76, 255; ...
        48, 201, 232; ...
        24, 255, 103; ...
        232, 232, 45; ...
        232, 131, 17]./255;
    
cMap = repmat(cMap, [100, 1]);


exp_files = dir('env*');
ol_files = dir('OL_*');
test_files = dir('*test*');

all_files = [exp_files; ol_files];

df_mat = [];
raw_mat = [];

disp(['collecting ' num2str(num_sample_frames) ' frames from each of '...
            num2str(length(all_files)) ' trials...'])
        
for ii = 1:length(all_files)
   
    disp(['collecting trial ' num2str(ii) ' of '...
                num2str(length(all_files))])
    
    load(all_files(ii).name);
    
    if isfield(expr.c_trial, 'idata')
        tframes = size(expr.c_trial.idata.mcorr_MIP, 3);
        
        rand_frames = randperm(tframes);
        select_frames = rand_frames(1:num_sample_frames);
       
        df_mat = cat(3, df_mat, expr.c_trial.idata.mcorr_dF(:,:,select_frames));
        raw_mat = cat(3, raw_mat, expr.c_trial.idata.mcorr_MIP(:,:,select_frames)); 
                
    end
    
end

close all

max_mat = max(raw_mat, [], 3);
thresh_bg = prctile(max_mat(:), 75);

thresh_map = zeros(size(max_mat));
thresh_map(max_mat>thresh_bg) = 1;

%% threshold selection
for ii = 1:size(df_mat, 3)
   
    c_frame = df_mat(:,:,ii);
    c_frame(~thresh_map) = 0;
    
    df_mat(:,:,ii) = c_frame;
    
end

std_map = std(df_mat, [], 3);
dot_map = zeros(size(std_map));

disp('calculating local dot products')
for ii = 3:(size(df_mat, 1)-2);
    for jj = 3:(size(df_mat, 2)-2);
        
        if thresh_map(ii,jj) == 1
   
            
            north_vec = squeeze(df_mat(ii-1,jj, :));
            south_vec = squeeze(df_mat(ii+1, jj, :));
            east_vec = squeeze(df_mat(ii, jj+1, :));
            west_vec = squeeze(df_mat(ii, jj-1,: ));
        
            northeast_vec = squeeze(df_mat(ii+1, jj+1, :));
            northwest_vec = squeeze(df_mat(ii+1, jj-1, :));
            southeast_vec = squeeze(df_mat(ii-1, jj+1, :));
            southwest_vec = squeeze(df_mat(ii-1, jj-1, :));
        
            c_vec = squeeze(df_mat(ii,jj, :));
        
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
                    
            dot_map(ii,jj) = c_dot;
       
            
            
        end
    end
end

multi_map = dot_map.*std_map;
multi_map_thresh_val = prctile(multi_map(:), 94);


roi_thresh_map = zeros(size(multi_map));
roi_thresh_map(multi_map>multi_map_thresh_val) = 1;

present_map = max_mat;
present_map(max_mat<thresh_bg) = 0;

imagesc(present_map);

disp('finding connected components')
CC = bwconncomp(roi_thresh_map, 4);
B = bwboundaries(roi_thresh_map,4);

roi_entry = 0;
clear roi_auto_struct
for ii = 1:numel(CC.PixelIdxList)

    boundary_xy = B{ii};
    if length(boundary_xy) > 8
        roi_entry = roi_entry+1;

        roi_auto_struct(roi_entry).pixIdx = CC.PixelIdxList{ii};
        boundary_xy = B{ii};
        roi_auto_struct(roi_entry).xy = [boundary_xy(:,2), boundary_xy(:,1)];
    
        pixMask = zeros(size(multi_map));
        pixMask(roi_auto_struct(roi_entry).pixIdx) = 1;
        roi_auto_struct(roi_entry).BW = pixMask;
    
        roi_auto_struct(roi_entry).cmap = cMap(ii,:);
        roi_auto_struct(roi_entry).present_map = present_map;
        
        
    end

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

present_map = max_mat;
present_map(max_mat<thresh_bg) = 0;

imagesc(present_map);
axis equal off

min_val = min(min(present_map(4:end-3, 4:end-3)));
max_val = max(max(present_map(4:end-3, 4:end-3)));
caxis([min_val max_val]);

colormap([0,0,0; 0,0,0; gray(2^8)])
axis equal off

hold on
for jj = 1:length(roi_auto_struct)
%for jj = 1
 for kk = 1:numel(roi_auto_struct(jj).xy)
    c_xy = roi_auto_struct(jj).xy;
    
    hold on
    
    scat_h = fill(c_xy(:,1), c_xy(:,2), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_auto_struct(jj).cmap);
 
 end
 
end


set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);


print(f1, ['auto_selected_roi.pdf'], '-dpdf', '-r0', '-opengl');

cd(expdir)

end

    