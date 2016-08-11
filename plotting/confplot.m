function confplot(x,y,z1,z2, fillcolor)
%CONFPLOT Linear plot with continuous confidence/error boundaries.

scatcolor = fillcolor;

xfill = [x(1)-.1 x x(end)+.1];
yfill = [y(1) y y(end)];
z1_fill = [z1(1) z1 z1(end)];
z2_fill = [z2(1) z2 z2(end)];
    

hold on
fill_handle = fill([xfill fliplr(xfill)],[z1_fill+yfill fliplr(yfill-z2_fill)], fillcolor);
set(fill_handle, 'FaceAlpha', .3, 'EdgeColor', 'none')
%plot(x, z1+y, 'color', fillcolor, 'LineWidth', 2)
%plot(x, y-z2, 'color', fillcolor, 'LineWidth', 2)

plot(x,y,'color', scatcolor);
%s1 = scatter(x,y, 100, scatcolor);
%set(s1, 'MarkerFaceColor', scatcolor, 'markeredgecolor', 'none')

end
