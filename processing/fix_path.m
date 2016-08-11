function dirpath = fix_path(dirpath)
%{

    fixes filepath from windows to unix or vice versa

%}

if ispc
    target_dash = '\';
    enemy_dash = '/';
else
    target_dash = '/';
    enemy_dash = '\';
end

dirpath(strfind(dirpath, enemy_dash )) = target_dash;

end