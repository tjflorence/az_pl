bdir = '/Volumes/Untitled/2016-05-02/20160502155938_HC-Gal4x2b_az_PL';
idir = '/Volumes/Untitled/20160502/fly04e';
syncdir = '/Volumes/Untitled/20160502/fly04e';

process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir)
cd(bdir)

load('path_list.mat')

try
    delete([bdir '/stack_data.mat'])
catch
    disp('no previous stack data file')
end

for ii = 1:length(sum_struct.fpaths);
    
  bfile = sum_struct.fpaths(ii).bpath;
  idir = sum_struct.fpaths(ii).ipath;
  syncdir = sum_struct.fpaths(ii).spath;
    
    
  add_img_to_behav(bdir, bfile, idir, syncdir)
    
end