clear all

bdir = '\\reiser_nas\tj\az_pl\behavior\2016-08-08\20160808211216_11f03_az_PL-coincidence';
idir = '\\reiser_nas\tj\az_pl\imaging\20160808\fly2_11f03_CL';
syncdir = '\\reiser_nas\tj\az_pl\imaging\20160808\fly2_11f03_CL';

local_processing_dir = 'D:\temp\';
processed_data_server = '\\reiser_nas\tj\az_pl\processed\';

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

tic
for ii = 3:length(idir_files)
    copyfile([idir '\' idir_files(ii).name], [local_processing_dir idir(last_idash_idx+1:end) '\' idir_files(ii).name])
end
delete(gcp('nocreate'))

for ii = 3:length(bdir_files)
    copyfile([ bdir '\' bdir_files(ii).name], [local_processing_dir bdir(last_bdash_idx+1:end)])
end
toc

ref_img = [];

%process_azPL_experiment(bdir)
parse_azPL_experiment(new_bdir, new_idir, 5, 65)
cd(new_bdir)

try
    delete(['stack_data.mat'])
catch
    disp('no previous stack data file')
end

cd(new_bdir)
load('path_list.mat')

for ii = 1:length(sum_struct.fpaths);
    
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


mcorr_azPL(pwd, ref_img);
auto_process_roi_v2(pwd);
add_azPL_auto_roi_data(pwd);

%plot_azPl_roi_by_trial(pwd, 2, 1);
%plot_azPL_cool_align_sequence(pwd, 1);
%plot_azPL_cool_align_errortrial(pwd, 1);
%adaptation_idx(pwd, 1);


dashes = strfind(new_bdir, '\');
last_bdash_idx = dashes(end);

copyfile([new_bdir '\' ], [processed_data_server  new_bdir(last_bdash_idx+1:end) ])

cd('C:\')
rmdir(new_bdir, 's')
rmdir(new_idir, 's');

