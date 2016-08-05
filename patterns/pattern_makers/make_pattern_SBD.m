clear all
homedir = pwd;

std_offset = 20;


pat_name = ['Pattern_03_SBD_shift_180'];


pattern.x_num = 96; 	% There are 96 pixel around the display (12x8) 
pattern.y_num = 1; 		% two frames of Y, at 2 different spatial frequencies
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.gs_val = 1; 	% This pattern will use 8 intensity levels
pattern.row_compression = 0;

Pats = ones(32, 96, pattern.x_num, pattern.y_num);

bars = fliplr(repmat([zeros(32, 8) ones(32, 8)], [1 2]));
stripes = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
diag = [ones(8,32); zeros([8, 32]); ones(8, 32); zeros(8, 32)];
for ii = 2:32

    diag(:,ii) = circshift(diag(:,ii), [ii-1 0]);
    
end

sbd = [stripes bars diag];
sbd = circshift(sbd, [0 -16-48]);

for k = 1:pattern.x_num

    
    for j = 1:pattern.y_num
    
        Pats(:,:,k,j) = circshift(sbd, [0 k-1+std_offset]);
    
    end

end


pattern.Pats = Pats;

pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1; 24 20 16 23 19 15 22 18 14 21 17 13; 36 32 28 35 31 27 34 30 26 33 29 25; 48 44 40 47 43 39 46 42 38 45 41 37];
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

directory_name = '/Users/florencet/Documents/matlab_root/az_pl/patterns/pattern_files';
str = [directory_name '/' pat_name];
save(str, 'pattern');

cd(homedir)
