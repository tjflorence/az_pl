bdir = '/Volumes/sab_x/2016-08-06/20160806152517_11f03_OL_stim';
idir = '/Volumes/sab_x/20160806/fly1_11f03_OL';
syncdir = '/Volumes/sab_x/20160806/fly1_11f03_OL';


ref_img = [];

%process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir, 4, 130)
cd(bdir)

try
    delete([bdir '/stack_data.mat'])
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
      try
    add_img_to_behav(bdir, bfile, idir, syncdir);
      catch
          disp('unsuccessful stitch')
      end
  else
      disp(['data quality criteria excluded trial ' num2str(ii)])
  end
    
end


mcorr_azPL(pwd, ref_img);
auto_process_roi_v2(pwd);
add_azPL_auto_roi_data(pwd);

%plot_azPl_roi_by_trial(pwd, 2, 1);
%plot_azPL_cool_align_sequence(pwd, 1);
%plot_azPL_cool_align_errortrial(pwd, 1);
%adaptation_idx(pwd, 1);