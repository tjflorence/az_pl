anoche(1).bdir = '\\reiser_nas\tj\az_pl\behavior\2016-08-14\20160814202003_11f03_az_PL';
anoche(1).idir = '\\reiser_nas\tj\az_pl\imaging\20160814\fly2_11f03_CL';
anoche(1).parse_ver = 3;
anoche(1).test_len = 70;

anoche(2).bdir = '\\reiser_nas\tj\az_pl\behavior\2016-08-14\20160814204908_11f03_OL_stim'
anoche(2).idir = '\\reiser_nas\tj\az_pl\imaging\20160814\fly2_11f03_OL'
anoche(2).parse_ver = 5;
anoche(2).test_len = 130;

for ii = 1%:length(anoche)
   
    bdir = anoche(ii).bdir
    idir = anoche(ii).idir
    parse_ver = anoche(ii).parse_ver
    test_len = anoche(ii).test_len
    
    azPL_auto_imaging_pipeline(bdir, idir, ... 
                                        parse_ver, test_len)
end