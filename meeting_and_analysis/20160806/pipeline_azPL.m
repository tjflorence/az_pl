clear all

bdir = '/Volumes/sab_x/2016-08-18/20160818205601_11f03_az_PL';
idir = '/Volumes/sab_x/20160818/fly4b_11f03_CL';
syncdir = '/Volumes/sab_x/20160818/fly4b_11f03_CL';

if ispc 
    dash = '\';
else
    dash = '/';
end

ref_img = [];

process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir, 3, 65)
cd(bdir)

try
    delete([bdir dash 'stack_data.mat'])
catch
    disp('no previous stack data file')
end

cd(bdir)
load('path_list.mat')
for ii = 1:length(sum_struct.fpaths);
    
  bfile = sum_struct.fpaths(ii).bpath;
  idir = sum_struct.fpaths(ii).ipath;
  syncdir = sum_struct.fpaths(ii).spath;
    
  if ~isempty(bfile) && ~isempty(idir) && ~isempty(syncdir)
   %   try
    add_img_to_behav_laptop(bdir, bfile, idir, syncdir);
   %   catch
   %       disp('unsuccessful stitch')
   %   end
  else
      disp(['data quality criteria excluded trial ' num2str(ii)])
  end
    
end


mcorr_azPL(pwd, ref_img);
auto_process_roi_v2(pwd);
add_azPL_auto_roi_data(pwd);

plot_azPl_roi_by_trial(pwd, 2, 1);
plot_azPL_cool_align_sequence(pwd, 1);
%plot_azPL_cool_align_errortrial(pwd, 1);
adaptation_idx(pwd, 1);