bdir = '/Volumes/sab_x/2016-08-09/20160809181551_11f03_OL_stim';
idir = '/Volumes/sab_x/20160809/fly3_11f03_OL';
syncdir = '/Volumes/sab_x/20160809/fly3_11f03_OL';


ref_img = [];

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

cd(bdir)

mcorr_azPL(pwd, ref_img);
auto_process_roi_v2(pwd);
add_azPL_auto_roi_data(pwd);
process_azPL_multisense_exp(pwd);