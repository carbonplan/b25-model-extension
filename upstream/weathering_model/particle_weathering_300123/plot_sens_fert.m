global GpH_t Galk_t

%pH1 = GpH_t;
%alk1 = Galk_t;


%%

rco22_no_affin = RCO2_sim;

%%

save('plot_sens_fert_2','pH1','alk1','rco21','pH2','alk2','rco22','t_sim')

%%

load('plot_sens_fert_1')

%%

fs = 12;
fsl = 10;
fw = 'bold';
lw = 2;
its = [10, 1];
fp = [0 0 800 400];
lloc = 'southwest';
stleg = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
depth = 0:.5:15;

istleg1 = [4:8]; istleg2 = round(istleg1*101/12-101/24);

%figure('position',fp)
figure(1); clf;

subplot(2,3,1)
plot(pH1(:,istleg2),depth,'linewidth',lw); 
xlim([4 10]);
ylabel('depth (cm)'); xlabel('');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc);
grid; title('Fert x 0 pH');
set(leg,'ItemTokenSize',its,'fontsize',fsl);


subplot(2,3,2);
plot(squeeze(alk1(1,:,istleg2)),depth,'linewidth',lw); 
xlim([-1 1]*.05);
ylabel('depth (cm)'); xlabel('+ mol/l');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc); 
grid; title('Alkalinity');
set(leg,'ItemTokenSize',its,'fontsize',fsl);

subplot(2,3,3);
plot(squeeze(alk1(4,:,istleg2)),depth,'linewidth',lw); 
xlim([-1 1]*.05);
ylabel('depth (cm)'); xlabel('+ mol/l');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc); 
grid; title('Charge (via N Flux)');
set(leg,'ItemTokenSize',its,'fontsize',fsl);


subplot(2,3,4)
plot(pH2(:,istleg2),depth,'linewidth',lw); 
xlim([4 10]);
ylabel('depth (cm)'); xlabel('');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc);
grid; title('Fert x 2 pH');
set(leg,'ItemTokenSize',its,'fontsize',fsl);


subplot(2,3,5);
plot(squeeze(alk2(1,:,istleg2)),depth,'linewidth',lw); 
xlim([-1 1]*.05);
ylabel('depth (cm)'); xlabel('+ mol/l');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc); 
grid; title('Alkalinity');
set(leg,'ItemTokenSize',its,'fontsize',fsl);

subplot(2,3,6);
plot(squeeze(alk2(4,:,istleg2)),depth,'linewidth',lw); 
xlim([-1 1]*.05);
ylabel('depth (cm)'); xlabel('+ mol/l');
set(gca,'YDir','reverse','fontsize',fs,'fontweight',fw);
leg = legend(stleg(istleg1),'location',lloc); 
grid; title('Charge (via N Flux)');
set(leg,'ItemTokenSize',its,'fontsize',fsl);


%%


figure(3)
subplot(2,2,1)
plot(t_sim,rco21*100,t_sim,rco22*100,'linewidth',2)
title('Cumulative')
leg = legend({'Fert x 0','Fert x 2'});
set(leg,'ItemTokenSize',its,'fontsize',fsl,'location','northwest');

ylabel('RCO2 %')
subplot(2,2,2)
plot(t_sim,(rco22 - rco21)*100,'linewidth',2)
title('Difference')
subplot(2,2,3)
plot(t_sim(2:end),(diff(rco22) - diff(rco21))*100,'linewidth',2)
title('Cumulative Difference')

subplot(2,2,4)
plot(t_sim,rock.*rco22*100 - rock.*rco21*100,'linewidth',2)
title('Cumulative')
set(leg,'ItemTokenSize',its,'fontsize',fsl,'location','northwest');
xlabel('tonnes per h')




%%


load('plot_rco2_1')



rock = [ones(1,100),ones(1,100)*2,ones(1,101)*3]*40/100;

figure(3)
subplot(2,2,1)
plot(t_sim,rco21*100,t_sim,rco22*100,'linewidth',2)
title('Cumulative')
leg = legend({'Fert x 0','Fert x 2'});
set(leg,'ItemTokenSize',its,'fontsize',fsl,'location','northwest');

ylabel('RCO2 %')
subplot(2,2,2)
plot(t_sim,(rco22 - rco21)*100,'linewidth',2)
title('Difference')
subplot(2,2,3)
plot(t_sim(2:end),(diff(rco22) - diff(rco21))*100,'linewidth',2)
title('Cumulative Difference')

subplot(2,2,4)
plot(t_sim,rock.*rco22*100 - rock.*rco21*100,'linewidth',2)
title('Cumulative')
set(leg,'ItemTokenSize',its,'fontsize',fsl,'location','northwest');
xlabel('tonnes per h')

%%


















%%

%save('plot_rco2_1','t_sim','rco22','rco21')
load('plot_rco2_1','t_sim','rco22','rco21')

figure(3)
subplot(2,2,1)
plot(t_sim,rco21*100,t_sim,rco22*100,'linewidth',2)
title('Cumulative')
leg = legend({'Fert x 0','Fert x 2'});
set(leg,'ItemTokenSize',its,'fontsize',fsl,'location','northwest');

ylabel('RCO2 %')
subplot(2,2,2)
plot(t_sim,(rco22 - rco21)*100,'linewidth',2)
title('Difference')
subplot(2,2,[3 4])
plot(t_sim(2:end),(diff(rco22) - diff(rco21))*100,'linewidth',2)
title('Cumulative Difference')





