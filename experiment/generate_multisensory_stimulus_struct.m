function expi = generate_multisensory_stimulus_struct(expi) 

expi.settings.stim_names = {'dark', 'light', 'env(stat)', 'env(OL)', 'env(CL)', 'noHeat', 'heat', 'cool'};

% logicals for if a stimulus is visual or thermal
isThermal = zeros(1, numel(expi.settings.stim_names));
isThermal(end-2:end) = 1;
isViz = ~isThermal;

% generate stimuli vec
viz_ref_frame = [zeros(1, expi.settings.prestim_time*expi.settings.hz) ...
                    ones(1, expi.settings.ref_stim_time*expi.settings.hz) ...
                    zeros(1, expi.settings.prestim_time*expi.settings.hz)];

no_viz_ref_frame = zeros(1, length(viz_ref_frame));

thermal_ref_frame = [-4.99*ones(1, expi.settings.prestim_time*expi.settings.hz) ...
                        expi.settings.light_power*ones(1, expi.settings.ref_stim_time*expi.settings.hz)...
                        -4.99*ones(1, expi.settings.prestim_time*expi.settings.hz)];

cool_ref_frame = [expi.settings.light_power*ones(1, expi.settings.prestim_time*expi.settings.hz) ...
                        -4.99*ones(1, expi.settings.ref_stim_time*expi.settings.hz)...
                        expi.settings.light_power*ones(1, expi.settings.prestim_time*expi.settings.hz)];
                    

no_thermal_ref_frame = -4.99*ones(1, length(thermal_ref_frame));

viz_test_frame = [zeros(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ...
                    ones(1, expi.settings.hz*(expi.settings.test_stim_time)) ...
                    zeros(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ];

thermal_test_frame = [-4.99*ones(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ...
                    expi.settings.light_power*ones(1, expi.settings.hz*(expi.settings.test_stim_time)) ...
                    -4.99*ones(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ];

cool_test_frame = [expi.settings.light_power*ones(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ...
                    -4.99*ones(1, expi.settings.hz*(expi.settings.test_stim_time)) ...
                    expi.settings.light_power*ones(1, expi.settings.hz*(expi.settings.prestim_time+(.5*expi.settings.test_stim_time) )) ];
                
no_viz_test_frame = [zeros(1, length(viz_test_frame))];
no_thermal_test_frame = [-4.99*ones(1, length(viz_test_frame))];

viz_pos_vec = [round(linspace(48, 72, 25)) repmat([round(linspace(72, 24, 50)) round(linspace(24, 72, 50))], [1 100])];
viz_pos_vec = viz_pos_vec(1:expi.settings.trial_time*expi.settings.hz);

% generate matrix of possible legal combinations
legalCombos = zeros(numel(expi.settings.stim_names), numel(expi.settings.stim_names));
for yy = 1:size(legalCombos, 1)
    for xx = 1:size(legalCombos, 2)
        
        if isViz(yy) ~= isViz(xx)
                    
            legalCombos(yy,xx) = 1 ;
            
        end
        
    end
end

% record possible permeations into a structure
stim_idx = 0;
for yy = 1:size(legalCombos, 1)
    for xx = 1:size(legalCombos, 2)
          
        if legalCombos(yy,xx)
            
            stim_idx = stim_idx+1;

            stim_struct(stim_idx).ref_name = expi.settings.stim_names{yy};
            stim_struct(stim_idx).test_name = expi.settings.stim_names{xx};
            
            stim_struct(stim_idx).ref_num = yy;
            stim_struct(stim_idx).test_num = xx;
            
            stim_struct(stim_idx).refIsViz = isViz(yy);
            stim_struct(stim_idx).refIsTherm = isThermal(yy);
            
            stim_struct(stim_idx).testIsViz = isViz(xx);
            stim_struct(stim_idx).testIsTherm = isThermal(xx);
            
            % assign stimulus vectors for reference stimulus to stim idx
            if stim_struct(stim_idx).refIsViz
               
                if stim_struct(stim_idx).ref_num == 1
                    stim_struct(stim_idx).ref_vec = no_viz_ref_frame;
                else
                    stim_struct(stim_idx).ref_vec = viz_ref_frame;
                end
                
                stim_struct(stim_idx).viz_vec = stim_struct(stim_idx).ref_vec;
                stim_struct(stim_idx).viz_name = expi.settings.stim_names{yy};
                
            elseif stim_struct(stim_idx).refIsTherm
                
                if stim_struct(stim_idx).ref_num == 6
                   stim_struct(stim_idx).ref_vec = no_thermal_ref_frame;
                elseif stim_struct(stim_idx).ref_num == 7
                   stim_struct(stim_idx).ref_vec = thermal_ref_frame;
                else
                   stim_struct(stim_idx).ref_vec = cool_ref_frame;                    
                end
                
                stim_struct(stim_idx).therm_vec = stim_struct(stim_idx).ref_vec;
            end
            
            % assign stimulus vectors to stim idx
            if stim_struct(stim_idx).testIsViz
               
                if stim_struct(stim_idx).test_num == 1
                    stim_struct(stim_idx).test_vec = no_viz_test_frame;
                else
                    stim_struct(stim_idx).test_vec = viz_test_frame;
                end
                
                stim_struct(stim_idx).viz_vec = stim_struct(stim_idx).test_vec;
                stim_struct(stim_idx).viz_name = expi.settings.stim_names{xx};
                
            elseif stim_struct(stim_idx).testIsTherm
                
                if stim_struct(stim_idx).test_num == 6
                   stim_struct(stim_idx).test_vec = no_thermal_test_frame;
                elseif stim_struct(stim_idx).test_num == 7                 
                   stim_struct(stim_idx).test_vec = thermal_test_frame;
                else
                   stim_struct(stim_idx).test_vec = cool_test_frame; 
                end
                
                stim_struct(stim_idx).therm_vec = stim_struct(stim_idx).test_vec;
            
            end
            
            stim_struct(stim_idx).viz_pos_vec = viz_pos_vec;
        
        end
            
        
    end
end

expi.settings.stim_struct = stim_struct;

end