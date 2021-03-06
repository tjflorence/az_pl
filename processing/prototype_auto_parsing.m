idir = '\\reiser_nas\tj\az_pl\imaging\20160809\fly1_11f03_CL\trial_001';
syncdir = '\\reiser_nas\tj\az_pl\imaging\20160809\fly1_11f03_CL\sync_001';
bdir = '\\reiser_nas\tj\az_pl\behavior\2016-08-09\20160809125442_11f03_az_PL-coincidence';
if ispc 
    dash = '\';
else
    dash = '.';
end
ds_factor = .33;

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
sm_pz_pos = conv(pz_pos, ones(100,1)/100, 'same');
diff_pz_pos = diff([sm_pz_pos]);

start_trash_idx = 1;
end_trash_idx   = find(diff_pz_pos>=0, 1, 'first');

start_stack_idx = end_trash_idx+1;
end_stack_idx   = find(diff_pz_pos(start_stack_idx:end)<=0, 1, 'first')+start_stack_idx;

start_flyback_idx   = end_stack_idx+1;
end_flyback_idx     = find(diff_pz_pos(start_flyback_idx:end)>=0, 1, 'first')+start_flyback_idx;

trash_frames_idx = find(frame_idx<end_trash_idx);
stack_frames_idx = find(frame_idx>start_stack_idx & frame_idx<end_stack_idx);
flyback_frames_idx = find(frame_idx>start_flyback_idx & frame_idx<end_flyback_idx);

trash_frames = numel(trash_frames_idx);
stack_frames = numel(stack_frames_idx);
flyback_frames = numel(flyback_frames_idx);
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
    
    entered_stack_data = 1;

else

    load([bdir dash 'stack_data.mat'])
    entered_stack_data = 0;

    
end






































