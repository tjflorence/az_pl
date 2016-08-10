c_gmr(1).path = '/Volumes/tj/az_pl/processed/20160627205056_11F03_az_PL';
c_gmr(1).cool_roi = [];

c_gmr(2).path = '/Volumes/tj/az_pl/processed/20160627164538_11F03_az_PL';
c_gmr(2).cool_roi = [];

c_gmr(3).path = '/Volumes/tj/az_pl/processed/20160624172843_11F03_az_PL';
c_gmr(3).notes = ['some adjustment to trial numbering on 6/24  messed up '...
                  'the imaging and behavior numbering, unfortunately doesnt '...
                  'seem recoverable'];

c_gmr(4).path = '/Volumes/tj/az_pl/processed/20160624142329_11F03_az_PL';
c_gmr(4).notes = ['some adjustment to trial numbering on 6/24  messed up '...
                  'the imaging and behavior numbering, unfortunately doesnt '...
                  'seem recoverable'];
              
c_gmr(5).path = '/Volumes/tj/az_pl/processed/20160620180741_11F03_az_PL';

c_gmr(6).path = '/Volumes/tj/az_pl/processed/20160620112609_11F03_az_PL';
c_gmr(6).cool_roi = [];

c_gmr(7).path = '/Volumes/tj/az_pl/processed/20160618120700_11F03_az_PL';
c_gmr(7).cool_roi = [];

c_gmr(8).path = '/Volumes/tj/az_pl/processed/20160724215547_11f03_az_PL';
c_gmr(8).cool_roi = [ 4];

uc_gmr(1).path = '/Volumes/tj/az_pl/processed/20160725_combo_fly_1/20160725170013_11f03_az_PL';
uc_gmr(1).cool_roi = [3 4];

uc_gmr(2).path = '/Volumes/tj/az_pl/processed/20160723235715_11f03_az_PL';
uc_gmr(2).cool_roi = [1 3];

uc_gmr(3).path = '/Volumes/tj/az_pl/processed/20160723230416_11f03_az_PL';
uc_gmr(3).cool_roi = [1 2];

uc_gmr(4).path = '/Volumes/tj/az_pl/processed/20160723190053_11f03_az_PL';
uc_gmr(4).cool_roi = 4;

uni_gmr(1).path = '/Volumes/tj/az_pl/processed/20160729_combo_fly_1/20160729130335_11f03_az_PL-uniblocks';
uni_gmr(1).cool_roi = [2 4];

uni_gmr(2).path = '/Volumes/tj/az_pl/processed/20160729_combo_fly_2/20160729164642_11f03_az_PL-uniblocks';
uni_gmr(2).cool_roi = [1];

uni_gmr(3).path = '/Volumes/tj/az_pl/processed/20160729_combo_fly_3/20160729200649_11f03_az_PL-uniblocks';
uni_gmr(3).cool_roi = [1];

uni_gmr(4).path = '/Volumes/tj/az_pl/processed/20160728_combo_fly_2/20160728173913_11f03_az_PL-uniblocks';
uni_gmr(4).cool_roi = [1 3 4];


coupled_adapt = [];
uncoupled_adapt = [];
uniform_adapt = [];

for ii = 1:length(c_gmr)
   
    cd(c_gmr(ii).path)
    if isfield(c_gmr(ii), 'cool_roi')
       
        if ~isempty(c_gmr(ii).cool_roi)
           
          %  cool_file = dir('cool_adapation*');
          %  if isempty(cool_file)
               
          %      adaptation_idx(pwd, 1)
                
          %  end
            
            load(cool_file.name)
            for jj = 1:length(c_gmr(ii).cool_roi)
               
               coupled_adapt =  [coupled_adapt cool_adapt(jj).adapt_idx];
                
            end
                 
        end
        
    end
    
end


for ii = 1:length(uc_gmr)
   
    cd(uc_gmr(ii).path)
    if isfield(uc_gmr(ii), 'cool_roi')
       
        if ~isempty(uc_gmr(ii).cool_roi)
           
        %    cool_file = dir('cool_adapation*');
        %    if isempty(cool_file)
               
         %       adaptation_idx(pwd , 1)
                
        %    end
            
            load(cool_file.name)
            for jj = 1:length(uc_gmr(ii).cool_roi)
               
               uncoupled_adapt =  [uncoupled_adapt cool_adapt(jj).adapt_idx];
                
            end
                 
        end
        
    end
    
end

for ii = 1:length(uni_gmr)
   
    cd(uni_gmr(ii).path)
    if isfield(uni_gmr(ii), 'cool_roi')
       
        if ~isempty(uni_gmr(ii).cool_roi)
           
      %      cool_file = dir('cool_adapation*');
      %      if isempty(cool_file)
               
      %          adaptation_idx(pwd , 1)
                
      %      end
            
            load(cool_file.name)
            for jj = 1:length(uni_gmr(ii).cool_roi)
               
               uniform_adapt =  [uniform_adapt cool_adapt(jj).adapt_idx];
                
            end
                 
        end
        
    end
    
end


h1 = scatter(ones(1,length(coupled_adapt)), coupled_adapt);
set(h1, 'markeredgecolor', 'r', 'markerFaceColor', 'none');
hold on

h2 = scatter(2*ones(1,length(uncoupled_adapt)), uncoupled_adapt);
set(h2, 'markeredgecolor', 'b', 'markerFaceColor', 'none');

h3 = scatter(3*ones(1,length(uniform_adapt)), uniform_adapt);
set(h3, 'markeredgecolor', 'k', 'markerFaceColor', 'none');
