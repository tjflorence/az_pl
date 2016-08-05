%load('env_rep_004_type_005_stim_15_sec_pulse_vizOFF.mat')

df_mat = expr.c_trial.idata.mcorr_dF;
raw_mat = expr.c_trial.idata.frame_MIP;

max_mat = max(raw_mat, [], 3);
thresh_val = 140;

thresh_map = zeros(size(max_mat));
thresh_map(max_mat>thresh_val) = 1;

for ii = 1:size(df_mat, 3)
   
    c_frame = df_mat(:,:,ii);
    
    c_frame(~thresh_map) = 0;
    
    df_mat(:,:,ii) = c_frame;
    
end

df_size = size(df_mat);
pix_by_time = [];
pix_lookup = nan(df_size(1:2));
pix_idx = 0;
for yy = 1:df_size(1)
   for xx = 1:df_size(2)
        
       
        if sum(df_mat(yy,xx,:)) > 0 
            pix_idx = pix_idx+1
            pix_by_time = [pix_by_time reshape(df_mat(yy,xx,:), [df_size(3) 1])   ]; 
            pix_lookup(yy,xx) = pix_idx;

        end
        
        
    end
    
end

[wcoeff,score,latent,tsquared,explained] = pca(pix_by_time);

% Set parameters
no_dims = 2;
initial_dims = 100;
perplexity = 10;
% Run t?SNE
mappedX = tsne(pix_by_time', [], no_dims, initial_dims, perplexity);
% Pl

idx = kmeans(mappedX,3);

cMap = 'rgbk';

close all
for ii = 1:size(mappedX, 1)
    
    hold on
    r1 = scatter(mappedX(ii,1), mappedX(ii,2));
    set(r1, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', k);
    
end
drawnow


min_x = min(mappedX(:,1));
max_x = max(mappedX(:,1));

min_y = min(mappedX(:,2));
max_y = max(mappedX(:,2));

img_X = [mappedX(:,1)-min_x, mappedX(:,2)-min_y];
img_X = round(img_X)+1;

img_x_dim = max(img_X(:,1));
img_y_dim = max(img_X(:,2));
img_space = zeros(img_y_dim, img_x_dim);


for ii = 1:size(img_X, 1)
    
    img_space(img_X(ii,2), img_X(ii,1)) = 1;
    
end

img_space = imgaussfilt(img_space, 20);
img_space(img_space<.05) = 0;
img_space_norm = img_space./max(max(img_space));

D = -img_space;
D(img_space==0) = -Inf;

L = watershed(D);
bin_watershed = zeros(size(L));
bin_watershed(L>1) = 1;

CC = bwconncomp(bin_watershed);
B = bwboundaries(bin_watershed,8);


rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure
imshow(rgb,'InitialMagnification','fit')


