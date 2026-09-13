X1 = 2016 + 150/365;
X2 = 2020 + 150/365;

x1 = 66;
x2 = 355;

Y1 = 5.7;
Y2 = 7.2;

y1_0_10 = 185;
y2_0_10 = 28;

y1_10_30 = 433;
y2_10_30 = 250;

xp = [
102
114
138
150
173
184
214
224
245
273
292
316
350];

yp_10_30 = [
421 372
395 370
395 374
399 367
392 363
396 346
394 357
377 350
362 334
397 352
375 344
400 337
383 333];


yp_0_10 = [
146 132
133 93
111 101
173 143
143 98
141 85
155 139
145 87
110 112
151 95
149 79
152 66
138 51];

xx = (xp - x1)/(x2 - x1)*(X2 - X1) + X1;
yy_0_10 = (yp_0_10 - y1_0_10)/(y2_0_10 - y1_0_10)*(Y2 - Y1) + Y1;
yy_10_30 = (yp_10_30 - y1_10_30)/(y2_10_30 - y1_10_30)*(Y2 - Y1) + Y1;

figure(1)
subplot(2,1,1)
h = plot(xx,yy_0_10,'-o','linewidth',2)
for i=1:length(h); h(i).MarkerFaceColor = h(i).Color; end
title('Maize 0-10 cm');
set(gca,'fontsize',12,'fontweight','bold')
ytickformat('%.1f'); ylabel('pH'); xlabel('year');
ylim([5.3 7.3]); xlim([2016.8 2020.5]); grid;
legend({'Control','Basalt'},'location','northwest')

subplot(2,1,2)
h = plot(xx,yy_10_30,'-o','linewidth',2)
for i=1:length(h); h(i).MarkerFaceColor = h(i).Color; end
title('Maize 10-30 cm');
set(gca,'fontsize',12,'fontweight','bold')
ytickformat('%.1f'); ylabel('pH'); xlabel('year')
ylim([5.3 7.3]); xlim([2016.8 2020.5]); grid;
legend({'Control','Basalt'},'location','northwest')

disp([xx,yy_0_10,yy_10_30])

fprintf('%.3f %.3f %.3f %.3f %.3f\n',[xx,yy_0_10,yy_10_30]')

%%

print(gcf,'-dpng','-r0','energy_farm_pH')


