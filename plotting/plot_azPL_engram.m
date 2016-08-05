function plot_azPL_engram(expdir)


close all
homedir = pwd;

cd(expdir)

load('env_test_rep_001.mat')
if ~isfield(expr.c_trial, 'bdata')
    expr.c_trial.bdata = expr.c_trial.data;
end


th = expr.c_trial.bdata.th(expr.c_trial.dark_frames+expr.c_trial.fix_frames+1:end);

pi_1a = find(th>315);
pi_1b = find(th<45);
pi_1 = [pi_1a; pi_1b];

pi_2 = (find(th>135 & th < 225));

pi_1 = pi_1+expr.c_trial.dark_frames+expr.c_trial.fix_frames;
pi_2 = pi_2+expr.c_trial.dark_frames+expr.c_trial.fix_frames;

pi_1f = unique(expr.c_trial.bdata.c_iframe(pi_1));
pi_2f = unique(expr.c_trial.bdata.c_iframe(pi_2));

pre_targ_img = mean(expr.c_trial.idata.df_frames(:,:,pi_1f), 3);
pre_dist_img = mean(expr.c_trial.idata.df_frames(:,:,pi_2f), 3);


load('env_test_rep_011.mat')

if ~isfield(expr.c_trial, 'bdata')
    expr.c_trial.bdata = expr.c_trial.data;
end

th = expr.c_trial.bdata.th(expr.c_trial.dark_frames+expr.c_trial.fix_frames+1:end);

pi_1a = find(th>315);
pi_1b = find(th<45);
pi_1 = [pi_1a; pi_1b];

pi_2 = (find(th>135 & th < 225));

pi_1 = pi_1+expr.c_trial.dark_frames+expr.c_trial.fix_frames;
pi_2 = pi_2+expr.c_trial.dark_frames+expr.c_trial.fix_frames;

pi_1f = unique(expr.c_trial.bdata.c_iframe(pi_1));
pi_2f = unique(expr.c_trial.bdata.c_iframe(pi_2));

post_targ_img = mean(expr.c_trial.idata.df_frames(:,:,pi_1f), 3);
post_dist_img = mean(expr.c_trial.idata.df_frames(:,:,pi_2f), 3);

whitebg('k')
close all

f1 = figure('color', 'k', 'position', [43   249   857   705]);

s1 = subplot(3,1,1);
imagesc(max(expr.c_trial.idata.frame_MIP(2:end-1, 2:end-1, :), [], 3))
colormap(gray)
freezeColors()
axis equal off tight 
c1 = colorbar('Visible', 'off')

freezeColors()
hold on

text(0, -5, 'raw fluorescence (post)', 'fontsize', 30)

%ax = findobj(gcf,'type','axes');
%p0 = get(ax,'pos');
%delete(c1)
%set(gca, 'Position', p0)

s2 = subplot(3,1,2);
imagesc([post_targ_img(2:end-1, 2:end-1) - pre_targ_img(2:end-1, 2:end-1)]);
colormap(redblue_exp(100, 70))
axis equal off tight
caxis([-.1 .15])

hold on
text(0, -5, 'post - pre (target quadrant)', 'fontsize', 30)


c1 = colorbar( 'fontsize', 20)
ylabel(c1, 'ddF', 'rotation', 270, 'fontsize', 25)


s3 = subplot(3,1,3);
imagesc([post_dist_img(2:end-1, 2:end-1)-pre_dist_img(2:end-1, 2:end-1)])
axis equal off tight 
caxis([-.1 .15])
hold on

text(0, -5, 'post - pre  (distractor quadrant)', 'fontsize', 30)

c1 = colorbar( 'fontsize', 20)
ylabel(c1, 'ddF', 'rotation', 270, 'fontsize', 25)

mkdir('plots')
cd('plots')

set(f1, 'Units', 'Inches')
pos = get(f1, 'position');
set(f1, 'PaperPositionMode','Auto',...
    'PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print(f1, ['az_engram.pdf'], '-dpdf', '-r0', '-opengl');

cd(homedir)

