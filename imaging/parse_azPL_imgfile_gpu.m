function [frame_4d, frame_MIP, img_frame_id, tstamp] = parse_azPL_imgfile_gpu(syncdir, idir, bdir)

ds_factor = 0.33;
if ispc 
    dash = '\';
else
    dash = '.';
end

homedir =pwd;

cd(idir);
xml_h = dir('Experiment.xml');

test_xml = [pwd dash xml_h.name];
xstruct = xml2struct(test_xml);
pixX = str2num(xstruct.ThorImageExperiment.LSM.Attributes.pixelX);
pixY = str2num(xstruct.ThorImageExperiment.LSM.Attributes.pixelY);

test_plane = ones(pixY, pixX);
test_ds_plane = imresize(test_plane, ds_factor);
ds_pixX = size(test_ds_plane, 2);
ds_pixY = size(test_ds_plane, 1);

ifile_h = dir('Image*');
test_ifile = [pwd dash ifile_h.name];

cd(syncdir)
sync_h = dir('Episode*');
test_syncfile = [pwd dash sync_h.name];

%% read out frame data
frame_out = h5read(test_syncfile, '/DI/Frame Out');
dframe_out = [0 diff(frame_out)];
frame_idx = find(dframe_out > 1.5);
frame_vec = zeros(1, length(frame_out));
frame_vec(frame_idx) = 1;

%% read out behavior sync data
clk_sig = h5read(test_syncfile, '/AI/clk');
d_clk = diff(clk_sig);
clk_idx = [1 find(abs(d_clk)>2)];
clk_vec = zeros(1,length(clk_sig));

behave_frame_id = 0;
for ii = 2:length(clk_idx)
    
    behave_frame_id = behave_frame_id+1;
    
    start_idx = clk_idx(ii-1);
    end_idx = clk_idx(ii);
    
    clk_vec(start_idx:end_idx) = behave_frame_id;
   
end

close all
plot(clk_vec)
%% read out piezo data
pz_pos = h5read(test_syncfile, '/AI/Piezo Monitor');

%% plot piezo and frame acq
if exist([bdir dash 'stack_data.mat'], 'file') == 0

    f1 = figure('Position', [ 65   541   790   414]);
    plot(pz_pos(1:10000));
    hold on
    scatter(frame_idx(frame_idx<10000),pz_pos(frame_idx(frame_idx<10000)), 'r' );

    disp('**************************************************')
    trash_frames = input('Input number of trash frames: ');
    disp('**************************************************')
    stack_frames = input('Input number of stack frames: ');
    disp('**************************************************')
    flyback_frames = input('Input number of flyback frames: ');
    disp('**************************************************')

    disp(['trash frames = ' num2str(trash_frames)]);
    disp(['stack frames = ' num2str(stack_frames)]);
    disp(['flyback frames = ' num2str(flyback_frames)]);
    save([bdir dash 'stack_data.mat'], 'trash_frames', 'stack_frames', 'flyback_frames')
    disp('continuing...')

else

    load([bdir dash 'stack_data.mat'])
    
end

%% read out frame data, collapse to MIPs
i_h = fopen(test_ifile, 'r');

for ii = 1:trash_frames

 out = fread(i_h, pixX*pixY, 'uint16');
 
end

frame_num = 0;
frame_mat = nan(ds_pixY, ds_pixX, stack_frames);

stacknum = 0;
img_frame_id = [];
c_imgframe = inf;
tstamp = [];


while (c_imgframe ~= 0) %&& (frame_num < length(frame_idx))
    
    stacknum = stacknum+1;

    for ii = 1:stack_frames
        
        frame_num = frame_num+1;
        
        sync_pos = frame_idx(frame_num);
        c_imgframe = clk_vec(sync_pos);

        istack = reshape(fread(i_h, pixX*pixY, 'uint16'), [pixX pixY]);
        istack = imresize(istack, ds_factor );
        istack = fliplr( rot90(squeeze(istack)));
      %  istack = gpuArray(istack);
       % istack = medfilt2( istack, [1,1]);
      %  istack = gather(istack);
      %  frame_mat(:,:,ii) =  imgaussfilt(istack, 1.5);
        frame_mat(:,:,ii) =  istack;

    
    end
    
    sync_pos = frame_idx(frame_num);
    tstamp = [tstamp sync_pos/10000];
    c_imgframe = clk_vec(sync_pos);
    img_frame_id = [img_frame_id, c_imgframe];
    
    if stacknum == 1
        frame_4d = frame_mat;
        
        %frame_MIP = max(frame_mat, [], 3);
        %frame_MIP = medfilt2(frame_MIP, [1,1]);
        %frame_MIP =  imgaussfilt(frame_MIP, 1.5);
        
        frame_MIP = max(frame_mat, [], 3);
        frame_4d = reshape(frame_mat, [ds_pixY ds_pixX stack_frames 1]);
    else
        
        frame_4d = cat(4, frame_4d, frame_mat);
        
       % frame_mat = max(frame_mat, [], 3);
       % frame_mat = medfilt2(frame_mat, [3,3]);
       % frame_mat =  imgaussfilt(frame_mat, 1.5);
        
        frame_MIP = cat(3, frame_MIP, max(frame_mat, [], 3));
    end
    
   for ii = 1:flyback_frames
      frame_num = frame_num+1;
      out = fread(i_h, pixX*pixY, 'uint16');
   end
   
    
end


fclose(i_h);

%% now run filtering steps
% step 1: estimate noise threshold


%try
%    frame_MIP(frame_MIP<pmt_noise_cutoff) = 0;
    
%catch
        
%    close all
%    figure;
%    hist(frame_MIP(:), 200);
%    drawnow
    
%    pmt_noise_cutoff = input('input noise cutoff: ');
    
%    save([bdir '/stack_data.mat'], 'trash_frames', 'stack_frames', ...
%        'flyback_frames', 'pmt_noise_cutoff');
    
%     frame_MIP(frame_MIP<pmt_noise_cutoff) = 0;
%end
    

% step 2: medfilt in time
parfor ii = 1:size(frame_MIP, 1);
   
    frame_MIP(ii,:,:) = medfilt2(gpuArray(squeeze(frame_MIP(ii,:,:))), [3 3]);
    
end

% step 3: medfilt in space, add gaussblur
parfor ii = 1:size(frame_MIP, 3)
    
 %   frame_MIP(:,:,ii) = imgaussfilt(medfilt2(frame_MIP(:,:,ii), [3 3]), 1);

    frame_MIP(:,:,ii) = medfilt2(gpuArray(frame_MIP(:,:,ii)), [3 3]);
end

cd(homedir)

end
