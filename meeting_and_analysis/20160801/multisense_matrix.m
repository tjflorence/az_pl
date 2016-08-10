stim_names = {'dark', 'light', 'env(stat)', 'env(OL)', 'env(CL)', 'noHeat', 'heat'};
isThermal = zeros(1, numel(stim_names));
isThermal(end-1:end) = 1;
isViz = ~isThermal;

legalCombos = zeros(numel(stim_names), numel(stim_names));
for yy = 1:size(legalCombos, 1)
    for xx = 1:size(legalCombos, 2)
        
        if isViz(yy) ~= isViz(xx)
           
            
            legalCombos(yy,xx) = 1 ;
            
        end
        
    end
end

stim_idx = 0;
for yy = 1:size(legalCombos, 1)
    

    for xx = 1:size(legalCombos, 2)
   
        
        if legalCombos(yy,xx)
            
            stim_idx = stim_idx+1;

            stim_struct(stim_idx).ref_name = stim_names{yy};
            stim_struct(stim_idx).test_name = stim_names{xx};
            
            stim_struct(stim_idx).ref_num = yy;
            stim_struct(stim_idx).test_num = xx;
            
            stim_struct(stim_idx).refIsVis = isViz(yy);
            stim_struct(stim_idx).refIsTherm = isThermal(yy);
            
            stim_struct(stim_idx).testIsVis = isViz(xx);
            stim_struct(stim_idx).testIsTherm = isThermal(xx);
            
            
        end
        
        
    end
end