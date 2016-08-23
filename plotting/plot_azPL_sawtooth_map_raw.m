expdir = '/Volumes/sab_x/2016-08-18/20160818205601_11f03_az_PL';

cd(expdir);

ol_a = dir('OL_A*');
ol_b = dir('OL_B*');

c_roi = 4;

load(ol_a.name)

whitebg('w'); close all;

f1 = figure('units', 'normalized', 'position', [0.0292 0.0629 0.4744 0.8305], ...
                'color', 'w');
            
load(ol_a.name)

bcount = expr.c_trial.bdata.count;
s1 = subplot(3,1,1);

c_xpos = mod(expr.c_trial.bdata.xpos(1:bcount)+49, 96);
c_xpos(c_xpos==0) = nan;

plot(expr.c_trial.bdata.timestamp(1:bcount), c_xpos);
xlim([0 70])


s2 = subplot(3,1,2);
itstamps = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
c_dF = expr.c_trial.idata.auto_roi_traces(c_roi, 1:end-1);
plot(itstamps, c_dF)
xlim([0 70])

s3 = subplot(3,1,3);
load(ol_b.name)

itstamps = expr.c_trial.bdata.timestamp(expr.c_trial.idata.img_frame_id(1:end-1));
c_dF = expr.c_trial.idata.auto_roi_traces(c_roi, 1:end-1);
plot(itstamps, c_dF)
xlim([0 70])

n_idx = [22 26; 46 50];
s_idx = [28 32; 52 56];
e_idx = [34 38; 58 62];
w_idx = [40 44; 64 68];


