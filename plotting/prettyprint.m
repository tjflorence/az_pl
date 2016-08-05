function prettyprint(fig_handle, fig_name)
%% sets up matlab figure for new pretty printing post 2015 release
% sick of copypasting these six lines

    set(fig_handle, 'Units', 'Inches');
    pos = get(fig_handle, 'position');
    set(fig_handle, 'PaperPositionMode','Auto',...
        'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

    print(fig_handle, [fig_name '.pdf'], '-dpdf', '-r0', '-opengl');
    
    set(fig_handle, 'Units', 'Normalized');

end