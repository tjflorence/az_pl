function plot_azPL_circVec(expdir)

close all
cd(expdir)

try
    rmdir('plots', 's')
catch
end

exp_files = dir('env*');

for ii = 1:length(exp_files)
    close all
    
    load(exp_files(ii).name)

    if ~isfield(expr.c_trial, 'bdata')
        expr.c_trial.bdata = expr.c_trial.data;
    end

    cutoff = expr.c_trial.bdata.circCutoff;

    gcolor = [.7 .7 .7];
    [x,y] = pol2cart(expr.c_trial.bdata.circMean, expr.c_trial.bdata.circRad);

    f1 = figure('color', 'w', 'visible', 'off');
    hold on

    tArc = plot_arc(-pi/4, pi/4, 0, 0, 1.04);
    set(tArc, 'FaceColor', [146 159 204]/255, 'EdgeColor', 'none');
    alpha(tArc, .5)

    oArc = plot_arc(3*pi/4, 5*pi/4, 0, 0, 1.04);
    set(oArc, 'FaceColor', [255 141 154]/255, 'EdgeColor', 'none');
    alpha(oArc, .5)

    iCirc_h = circles(0,0,cutoff+.01, 'points', 1000, 'facecolor', 'w', 'edgecolor', 'none');

    [xc1, yc1] = circle([0,0], [cutoff], 1000);
    [xc2, yc2] = circle([0,0], [1.05], 1000);

    plot(xc1, yc1, 'color', gcolor, 'linewidth', 2)
    plot(xc2, yc2, 'color', gcolor, 'linewidth', 2)

    %% plot target quad
    [xt11, yt11] = pol2cart(-45/360*2*pi, cutoff);
    [xt21, yt21] = pol2cart(-45/360*2*pi, 1.05);

    [xt12, yt12] = pol2cart(45/360*2*pi, cutoff);
    [xt22, yt22] = pol2cart(45/360*2*pi, 1.05);

    plot([xt11 xt21], [yt11 yt21], 'color', gcolor, 'linewidth', 2)
    plot([xt12 xt21], [yt12 yt22], 'color', gcolor, 'linewidth', 2)

    %% plot distractor quad
    [xt11, yt11] = pol2cart(225/360*2*pi, cutoff);
    [xt21, yt21] = pol2cart(225/360*2*pi, 1.05);

    [xt12, yt12] = pol2cart(135/360*2*pi, cutoff);
    [xt22, yt22] = pol2cart(135/360*2*pi, 1.05);

    plot([xt11 xt21], [yt11 yt21], 'color', gcolor, 'linewidth', 2)
    plot([xt12 xt21], [yt12 yt22], 'color', gcolor, 'linewidth', 2)

    %% plot fly vec
    plot(x, y, 'k', 'linewidth', 1.5)
    xlim([-1.1 1.1])
    ylim([-1.1 1.1])

    c1 = scatter(x(1), y(1), 'k');
    c2 = scatter(x(end), y(end), 'k');
    set(c2, 'MarkerFaceColor', 'k')

    axis equal off

    text(1.07, 0, 'target\newlinequadrant', 'fontsize', 20);
    text(-1.07, 0, 'opposite\newlinequadrant', 'fontsize', 20,...
        'HorizontalAlignment', 'Right')
    
    mkdir('plots')
    cd('plots')
    
    prettyprint(f1, ['circVec_' num2str(expr.c_trial.rep_num, '%03d')])
    
    cd('..')
    
end

close all;