cd('/Volumes/sab_x/2016-07-29/20160729134155_11f03-uniblocks_OL_stim')


clear all
close all

expdir = pwd;

num_sample_frames = 200;

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
f1 = figure();
s1 = subplot(2,1,1)
imagesc(max_mat)
axis equal tight

s2 = subplot(2,1,2)

%accept = 0;
%while accept ~= 1
    
%    thresh_bg = input('input bg thresh: ');

%    thresh_img = zeros(size(max_mat));
%    thresh_img(max_mat>thresh_bg) = 1;
    
%    s2 = subplot(2,1,1)
%    imagesc(thresh_img)
%    colormap(gray)
%    axis equal tight
    
%    accept = input('is acceptable? 1=yes: ');
    
%    close all

%end

thresh_bg = prctile(max_mat(:), 75);

thresh_map = zeros(size(max_mat));
thresh_map(max_mat>thresh_bg) = 1;

imagesc(thresh_map)
axis equal

for ii = 1:size(df_mat, 3)
   
    c_frame = df_mat(:,:,ii);
    c_frame(~thresh_map) = 0;
    
    df_mat(:,:,ii) = c_frame;
    
end

%% reshape image into pixel x time matrix
df_size = size(df_mat);
pix_by_time = [];
pix_lookup = nan(df_size(1:2));
pix_idx = 0;
for yy = 1:df_size(1)
   for xx = 1:df_size(2)
        
       
        if thresh_map(yy,xx)
         
            pix_idx = pix_idx+1;
            pix_by_time = [pix_by_time reshape(df_mat(yy,xx,:), [df_size(3) 1])   ]; 
            pix_lookup(yy,xx) = pix_idx;

        end
        
        
    end
    
end


%% make matrix of pixel pairwise distance comparisons
pairwise_dist_mat = nan(pix_idx, pix_idx);
for ii = 1:pix_idx

    c_pix_idx = find(pix_lookup==ii);
    [cI, cJ] = ind2sub(size(pix_lookup), c_pix_idx);
    
    dist_vec = [];
    
    for yy = 1:df_size(1)
        for xx = 1:df_size(2)
       
            if thresh_map(yy,xx)
            
                
                pix_dist = sqrt( ((cI-yy)^2) + ((cJ-xx)^2));
                dist_vec = [dist_vec; pix_dist];
                
            end
            
            
        end
    end
    

    pairwise_dist_mat(:,ii) = dist_vec;


end


covMat = cov(pix_by_time);
% Set parameters
no_dims = 3;
initial_dims = 100;
perplexity = 30;
% Run t?SNE
mappedX = tsne([covMat;pairwise_dist_mat ]', [], no_dims, initial_dims, perplexity);
% Pl

dist_vec = [];
for ii = 1:10
    
    [idx, C, sum_d] = kmeans(mappedX, ii,...
            'distance', 'sqeuclidean', 'MaxIter', 1000);
    dist_vec = [dist_vec mean(sum_d)];
    
end

dist_vec = dist_vec/max(dist_vec);

proper_k = find(dist_vec<.1, 1, 'first');
proper_k = proper_k+1;
[idx, C, sum_d] = kmeans(mappedX, proper_k,...
                'distance', 'sqeuclidean', 'MaxIter', 1000);


roi_map = zeros(size(pix_lookup));
for ii = 1:length(idx)
    
    roi_map(pix_lookup==ii) = idx(ii);
    
end

roi_idx = 0;
for ii = 1:max(max(roi_map))
%for ii = 4
    
    bin_mask = zeros(size(roi_map));
    bin_mask(roi_map==ii) = 1;
    
    CC = bwconncomp(bin_mask);
    xy_boundaries = bwboundaries(bin_mask);
    
    
    for jj = 1:numel(CC.PixelIdxList)
        
        roi_idx = roi_idx+1;
        
        roi_auto_struct(roi_idx).pixIdx = CC.PixelIdxList{jj};
    
        roi_auto_struct(roi_idx).xy = xy_boundaries{jj};

        roi_auto_struct(roi_idx).cmap = cMap(roi_idx,:);
        
        
        pixMask = zeros(size(roi_map));
        pixMask(roi_auto_struct(roi_idx).pixIdx) = 1;
        roi_auto_struct(roi_idx).BW = pixMask;
    

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
    
    scat_h = fill(c_xy(:,2), c_xy(:,1), 'r');
    set(scat_h, 'LineWidth', 4, 'FaceColor', 'none', 'EdgeColor', roi_auto_struct(jj).cmap);
 
 end
 
end


set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);


print(f1, ['auto_selected_roi.pdf'], '-dpdf', '-r0', '-opengl');

cd(expdir)

%close all

    