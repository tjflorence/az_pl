homedir = pwd;
cd('..')
fcn_dir = pwd;

bdir = [fcn_dir 'test_data/20160724215547_11f03_az_PL'];
idir = [fcn_dir 'test_data/fly1_11f03_CL'];
syncdir = [fcn_dir '/test_data/fly1_11f03_CL'];

ref_img = [];

process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir, 3, 65)
cd(bdir)

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
adaptation_idx(pwd, 1)

plot_azPl_roi_by_trial(pwd, 2, 1);
plot_azPL_cool_align_sequence(pwd, 1);

cd(homedir)