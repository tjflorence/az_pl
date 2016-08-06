function parse_azPL_experiment(bdir, idir, expver, test_length)
%{
    parse experiment imaging and behavior data
    bdir = behavior directory
    idir = imaging directory
    expver = experiment version
        1: original - no open-loop
        2: with open loop
        3: mid-test A
        4: mid-test B

%}

sample_rate = 10000;
%test_length = 65;
sync_sample_num = round(.9*sample_rate*test_length);
acceptable_framedrop_time = 10;

cd(bdir);


%% switch analysis for experiment version
if expver == 1

    ol_a_files = dir('OL_A*');
    ol_b_files = dir('OL_B*');
    
    bfiles = dir('env*');
    bsort(1).name = bfiles(1).name;
    for ii = 2:10
        bsort(ii).name = bfiles(ii+1).name;
    end
    
    bsort(11).name = bfiles(2).name;
    
elseif expver == 2

    ol_a_files = dir('OL_A*');
    ol_b_files = dir('OL_B*');
    bfiles = dir('env*');

    bfiles = dir('env*');
    bsort(1).name = bfiles(1).name;
    for ii = 2:6
        bsort(ii).name = bfiles(ii+4).name;
    end
    
    bsort(7).name = bfiles(2).name;
    
    for ii = 8:12
        bsort(ii).name = bfiles(ii+3).name;
    end
    
    bsort(13).name = bfiles(3).name;
    bsort(14).name = bfiles(4).name;
    bsort(15).name = bfiles(5).name;
    
elseif expver == 3
    
    %% used for CL learning experiment
    
    ol_a_files = dir('OL_A*');
    ol_b_files = dir('OL_B*');
    bfiles = dir('env*');

    for ii = 1:length(bfiles)
       
        for jj = 1:length(bfiles)
            
            split_name = strsplit(bfiles(jj).name, '.mat');
            split_part = split_name{1};
            split_num = str2num(split_part(end-2:end));
            
            if split_num == ii
                
                bsort(ii).name = bfiles(jj).name;
                
            end
            
        end
        
    end
    
elseif expver == 4
    
    %% use for OL stim experiment
    ol_a_files = dir('OL_A*');
    ol_b_files = dir('OL_B*');
    bfiles = dir('env*');
    bsort = bfiles;
    
end
        
cd(idir);
sync_files = dir('sync*');
i_files = dir('trial*');

b_num = 0;
for ii = 1:length(ol_a_files)
   
    b_num = b_num + 1;
    
       %% checks for valid sync files
   sync_exist = ~isempty(dir([idir '/sync_' num2str(b_num, '%03d')]));
   if sync_exist
       try
        cd([idir '/sync_' num2str(b_num, '%03d')])
        pz_pos = h5read('Episode001.h5', '/AI/Piezo Monitor');
        out = pz_pos(sync_sample_num);
        sync_exist = 1;
       catch
           disp('sync file exists, but too short')
            sync_exist = 0;
       end
   end
   cd(idir)   
   i_exist = ~isempty(dir(['trial_' num2str(b_num, '%03d')]));
   
   
   %% checks for behavior files -- sometime read errors from ball
   % throw off sync
   load([bdir '/' ol_a_files(ii).name])
   
   if ~isfield(expr.c_trial, 'bdata')
        expr.c_trial.bdata = expr.c_trial.data;
        expr.c_trial = rmfield(expr.c_trial, 'data');
   end
    
   if expr.c_trial.bdata.count == 3500 || expr.c_trial.bdata.count == 3499 ...
           || expr.c_trial.bdata.count == 3501
       no_berror = 1;
   else
       no_berror = 0;
   end
   
   if sync_exist == 1 && i_exist == 1 && no_berror == 1
       
           sum_struct.fpaths(b_num).bpath = [bdir '/' ol_a_files(ii).name];
           sum_struct.fpaths(b_num).ipath = [idir '/trial_' num2str(b_num, '%03d')];
           sum_struct.fpaths(b_num).spath = [idir '/sync_' num2str(b_num, '%03d')];
       
   end
    
    
    
end

for ii = 1:length(bsort)
    
   
    b_num = b_num + 1;
    
       %% checks for valid sync files
   sync_exist = ~isempty(dir([idir '/sync_' num2str(b_num, '%03d')]));
   if sync_exist
       try
        cd([idir '/sync_' num2str(b_num, '%03d')])
        pz_pos = h5read('Episode001.h5', '/AI/Piezo Monitor');
        out = pz_pos(68000);
        sync_exist = 1;
       catch
           disp('sync file exists, but too short')
            sync_exist = 0;
       end
   end
   cd(idir)   
   i_exist = ~isempty(dir(['trial_' num2str(b_num, '%03d')]));
   
   
   %% checks for behavior files -- sometime read errors from ball
   % throw off sync
   load([bdir '/' bsort(ii).name])
   
   if ~isfield(expr.c_trial, 'bdata')
    expr.c_trial.bdata = expr.c_trial.data;
    expr.c_trial = rmfield(expr.c_trial, 'data');
   end
    
   if expr.c_trial.bdata.count >= ( ((expr.settings.dark_time+expr.settings.fix_time+...
           expr.settings.trial_time)*expr.settings.hz)-(acceptable_framedrop_time*expr.settings.hz));
       no_berror = 1;
   else
       disp('behavior frame drop error')
       no_berror = 0;
   end
   
   if sync_exist == 1 && i_exist == 1 && no_berror == 1
       
           sum_struct.fpaths(b_num).bpath = [bdir '/' bsort(ii).name];
           sum_struct.fpaths(b_num).ipath = [idir '/trial_' num2str(b_num, '%03d')];
           sum_struct.fpaths(b_num).spath = [idir '/sync_' num2str(b_num, '%03d')];
       
   end
    
end

for ii = 1:length(ol_b_files)
   
    b_num = b_num + 1;
    
       %% checks for valid sync files
   sync_exist = ~isempty(dir([idir '/sync_' num2str(b_num, '%03d')]));
   if sync_exist
       try
        cd([idir '/sync_' num2str(b_num, '%03d')])
        pz_pos = h5read('Episode001.h5', '/AI/Piezo Monitor');
        out = pz_pos(69000);
        sync_exist = 1;
       catch
           disp('sync file exists, but too short')
            sync_exist = 0;
       end
   end
   cd(idir)   
   i_exist = ~isempty(dir(['trial_' num2str(b_num, '%03d')]));
   
   
   %% checks for behavior files -- sometime read errors from ball
   % throw off sync
   load([bdir '/' ol_b_files(ii).name])
   
   if ~isfield(expr.c_trial, 'bdata')
    expr.c_trial.bdata = expr.c_trial.data;
    expr.c_trial = rmfield(expr.c_trial, 'data');
   end
    
   if expr.c_trial.bdata.count == 3500 || expr.c_trial.bdata.count == 3499 ...
           || expr.c_trial.bdata.count == 3501
       no_berror = 1;
   else
       no_berror = 0;
   end
   
   if sync_exist == 1 && i_exist == 1 && no_berror == 1
       
           sum_struct.fpaths(b_num).bpath = [bdir '/' ol_b_files(ii).name];
           sum_struct.fpaths(b_num).ipath = [idir '/trial_' num2str(b_num, '%03d')];
           sum_struct.fpaths(b_num).spath = [idir '/sync_' num2str(b_num, '%03d')];
       
   end
    
    
    
end

cd(bdir);
save('path_list.mat', 'sum_struct')

end
