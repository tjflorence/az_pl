% want stim 10, 11, 12 - ref OL test therm - none, heat ON, heat off
% stim 13 14 15 is same thing but CL
% stim 19, 24, 29
plot(summary_stim(19).rois(4).dFs(1,:), 'k')
hold on

plot(summary_stim(19).rois(4).dFs(2,:), 'k')

plot(summary_stim(24).rois(4).dFs(1,:), 'r')
hold on

plot(summary_stim(24).rois(4).dFs(2,:), 'r')

plot(summary_stim(29).rois(4).dFs(1,:), 'b')
hold on

plot(summary_stim(29).rois(4).dFs(2,:), 'b')