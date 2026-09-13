clear
load('run1')

figure(1); clf;
x = linspace(2016,2021,61);
xx = linspace(2016,2021,501);
plot(x,P_mass*1000,x,K_mass*1000,xx,totals.Outflow.Si*molMass2('Si')/1000,'linewidth',2); grid;
l = legend({'P','K','Si'},'location','northwest')
l.ItemTokenSize = [10 5];
ylabel('g/m^2')

%%
figure(2); clf;
x = linspace(2016,2021,501);
pH_0_10 = sum(pH_sim(1:21,:),1)/21;
pH_10_15 = sum(pH_sim(21:31,:),1)/11;
subplot(2,1,1)
plot(x,pH_0_10,'linewidth',2); grid;
ylim([5.5,8.5])
subplot(2,1,2)
plot(x,pH_10_15,'linewidth',2); grid;
ylim([5.5,8.5])

%%
figure(3); clf;
x = linspace(2016,2021,501);
plot(x,RCO2_sim*100,'linewidth',2); grid;
ylabel('RCO2 (%)');



%%

figure(4); clf;
load('run1')
pH_sim1 = pH_sim;
load('run2')
pH_sim2 = pH_sim;

x = linspace(2016,2021,501);
pH1_0_10 = sum(pH_sim1(1:21,:),1)/21;
pH1_10_15 = sum(pH_sim1(21:31,:),1)/11;
pH2_0_10 = sum(pH_sim2(1:21,:),1)/21;
pH2_10_15 = sum(pH_sim2(21:31,:),1)/11;

subplot(2,1,1)
plot(x,pH1_0_10,x,pH2_0_10,'linewidth',2); grid;
ylim([4.0,8.5])
subplot(2,1,2)
plot(x,pH1_10_15,'linewidth',2); grid;
ylim([5.5,8.5])










