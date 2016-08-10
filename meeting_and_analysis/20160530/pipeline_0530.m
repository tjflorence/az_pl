bdir = '/Volumes/Untitled/2016-05-18/20160518133849_HC-Gal4x2b_az_PL';
idir = '/Volumes/Untitled/20160518/fly02/';
syncdir = '/Volumes/Untitled/20160518/fly02/';

process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir, 1)
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