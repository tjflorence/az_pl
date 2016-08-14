function full_pos_vec = make_OL_map_posvec(hz)
%{
    makes NSEW "jiggle" for mapping OL responses
    jiggle is .5Hz sawtooth of 90 degree sweep
    each position is presented for 4 sec, interleaved with 2 second off
    nan values tell controller to "all off"
%}

half_sec = (hz)/2;

north_vec   = round([linspace(96, 72, half_sec), linspace(72, 96, half_sec) ...
                linspace(1, 24, half_sec) linspace(24, 1, half_sec)]);

east_vec    = round([linspace(24, 1, half_sec) linspace(1, 24, half_sec), ...
                linspace(24, 48, 1) linspace(48, 24, 1)]);
            
south_vec   = round([linspace(48, 24, half_sec) linspace(24, 48, half_sec), ...
                linspace(48, 72, half_sec) linspace(72, 48, half_sec)]);
            
west_vec    = round([linspace(72, 96, half_sec) linspace(96, 72, half_sec), ...
                linspace(72, 48, half_sec) linspace(48, 72, half_sec)]);
            
            
complete_north_vec  = [north_vec north_vec nan(1, 2*hz)];
complete_east_vec   = [east_vec east_vec nan(1, 2*hz)];
complete_south_vec  = [south_vec south_vec nan(1, 2*hz)];
complete_west_vec   = [west_vec west_vec nan(1, 2*hz)];

one_rep = [complete_north_vec complete_south_vec complete_east_vec complete_west_vec];

full_pos_vec = [nan(1, 22*hz) one_rep one_rep];

end