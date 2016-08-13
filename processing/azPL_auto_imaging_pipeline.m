function azPL_auto_imaging_pipeline(bdir, idir, ... 
                                        parse_ver, test_length)

%{
  fully automatic processing pipelien for imaging experiments
  can run while I sleep!
  
  2016-08-13 TJF
%}
syncdir = idir;
ref_img = [];

%% set up locations to place and copy data
local_processing_dir = 'D:\temp\';
processed_data_server = '\\reiser_nas\tj\az_pl\processed\';

%% create name for new data folders
dashes = strfind(bdir, '\');
last_bdash_idx = dashes(end);

dashes = strfind(idir, '\');
last_idash_idx = dashes(end);

new_bdir = [local_processing_dir bdir(last_bdash_idx+1:end)];
new_idir = [local_processing_dir idir(last_idash_idx+1:end)];

bdir_files = dir([bdir '\*']);
idir_files = dir([idir '\*']);

try
    rmdir(local_processing_dir, 's')
catch
    disp('could not remove old temp dir')
end

mkdir(local_processing_dir)
mkdir(new_bdir)
mkdir(new_idir)

%% copy imaging files locally
for ii = 3:length(idir_files)
    copyfile([idir '\' idir_files(ii).name], [local_processing_dir idir(last_idash_idx+1:end) '\' idir_files(ii).name])
end
delete(gcp('nocreate'))

for ii = 3:length(bdir_files)
    copyfile([ bdir '\' bdir_files(ii).name], [local_processing_dir bdir(last_bdash_idx+1:end)])
end
toc


%% apply processing to data folders 
if parse_ver == 3
    process_azPL_experiment(bdir)
end
parse_azPL_experiment(new_bdir, new_idir, parse_ver, test_length)
cd(new_bdir)

load('path_list.mat')

parfor ii = 1:length(sum_struct.fpaths);
    
  bfile = sum_struct.fpaths(ii).bpath;
  idir = sum_struct.fpaths(ii).ipath;
  syncdir = sum_struct.fpaths(ii).spath;
    
  if ~isempty(bfile) && ~isempty(idir) && ~isempty(syncdir)
    add_img_to_behav(new_bdir, bfile, idir, syncdir);

  else
      disp(['data quality criteria excluded trial ' num2str(ii)])
  end
    
end
delete(gcp('nocreate'))

%% motion correction and ROI extraction
mcorr_azPL(pwd, ref_img);
auto_process_roi_v2(pwd);
add_azPL_auto_roi_data(pwd);


dashes = strfind(new_bdir, '\');
last_bdash_idx = dashes(end);

%% copy everything back to data server, deleting local files
copyfile([new_bdir '\' ], [processed_data_server  new_bdir(last_bdash_idx+1:end) ])

cd('C:\')
rmdir(new_bdir, 's')
rmdir(new_idir, 's');

end
