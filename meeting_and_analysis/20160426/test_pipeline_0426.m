bdir = '/Volumes/Untitled/sorted/2016-04-25/20160425142238_HC-Gal4x2b_az_PL';
idir = '/Volumes/Untitled/sorted/20160425/fly04';
syncdir = '/Volumes/Untitled/sorted/20160425/fly04';

process_azPL_experiment(bdir)
parse_azPL_experiment(bdir, idir)
cd(bdir)

load('path_list.mat')

try
    delete([bdir '/stack_data.mat'])
catch
    disp('no previous stack data file')
end

jj = 1;
for ii = 1:length(sum_struct(jj).fpaths);
    
  bfile = sum_struct(jj).fpaths(ii).bpath;
  idir = sum_struct(jj).fpaths(ii).ipath;
  syncdir = sum_struct(jj).fpaths(ii).spath;
    
    
  add_img_to_behav(bdir, bfile, idir, syncdir)
    
end