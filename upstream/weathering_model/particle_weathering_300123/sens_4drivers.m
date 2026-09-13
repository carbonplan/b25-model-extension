
%iSiteCats = [88,69,53];
iSiteCats = [88,53];

nn = 11;

for ii=1:2
iSite = iSiteCats(ii);
load('data/driving_data_structure/dat_3_SSP2');

% Site parameters

t0 = 1;

inps.alk      = squeeze(dat_f3.alk(iSite,(t0-1)*12+1:end,:));
inps.st       = dat_f3.st(iSite,(t0-1)*12+1:end)' - 273.15;
inps.wat      = dat_f3.wat(iSite,(t0-1)*12+1:end)'/1000;
inps.npp      = dat_f3.npp(iSite,(t0-1)*12+1:end)';
inps.yield    = inps.npp;
inps.sr       = dat_f3.sr(iSite,(t0-1)*12+1:end)';
inps.co2      = dat_f3.co2(iSite,(t0-1)*12+1:end)';
inps.fc       = dat_f3.fc(iSite);
inps.pH0      = dat_f3.pH(iSite);
%

Delz = 0.005;
p = .15/Delz+1;
z = (0:Delz:(p-1)*Delz)';
NFlux = [];
for i=1:size(inps.alk,1)
  NFlux(i,:) = interp1(0:.005:.15,inps.alk(i,:),z);
end
inps.alk = NFlux;

% 1 Cragmill
% 2 Middleton
% 3 Hillhouse

inps.iprof = 1;
inps.ibas  = 1;
inps.p80   = 100;
inps.tf    = 1;

inps.add_npp = 0;
inps.add_tmp = 0;
inps.add_pH = 0;
inps.add_flowrate = 0;

inps.tf    = 10;
%[c2b_ratio_20,run_params,CO2_mass_20,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
%disp(['c2b ratio = ',num2str(c2b_ratio_20(end)*100,'%0.6f%%')]);
%disp(['K = ',num2str(K(end)*1000,'%0.2f'),'g/m^2']);
%disp(['P = ',num2str(P(end)*1000,'%0.2f'),'g/m^2']);

% MRL gets
% c2b ratio = 15.233036%
% K = 48.61g/m^2
% P = 23.45g/m^2

%

% NPP Sensitivity
if 1
sens.npp_del_range = linspace(-500,500,nn);
sens.c2b_npp = zeros(size(sens.npp_del_range));
sens.npp = zeros(size(sens.npp_del_range));

for i=1:length(sens.npp_del_range)
  inps.add_npp = sens.npp_del_range(i);
  [c2b_ratio,run_params,CO2_mass,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
  disp(['c2b ratio = ',num2str(c2b_ratio(end)*100,'%0.6f%%')]);

  sens.npp0 = run_params.npp;
  sens.npp(i) = run_params.npp + inps.add_npp;
  sens.c2b_npp(i) = c2b_ratio(end);
end
inps.add_npp = 0;

if iSite == 88
  sensLow.npp_del_range = sens.npp_del_range;
  sensLow.npp0     = sens.npp0;
  sensLow.npp      = sens.npp;
  sensLow.c2b_npp  = sens.c2b_npp;
elseif iSite == 53
  sensHigh.npp_del_range = sens.npp_del_range;
  sensHigh.npp0    = sens.npp0;
  sensHigh.npp     = sens.npp;
  sensHigh.c2b_npp = sens.c2b_npp;
else
  error('Wrong Site') 
end
end

% Temperature Sensitivity
if 1
sens.tmp_del_range = linspace(-6,6,nn);
sens.c2b_tmp = zeros(size(sens.tmp_del_range));
sens.tmp = zeros(size(sens.tmp_del_range));

for i=1:length(sens.npp_del_range)
  inps.add_tmp = sens.tmp_del_range(i);
  [c2b_ratio,run_params,CO2_mass,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
  disp(['c2b ratio = ',num2str(c2b_ratio(end)*100,'%0.6f%%')]);

  sens.tmp0 = run_params.tmp;
  sens.tmp(i) = run_params.tmp + inps.add_tmp;
  sens.c2b_tmp(i) = c2b_ratio(end);
end
inps.add_tmp = 0;

if iSite == 88
  sensLow.tmp_del_range = sens.tmp_del_range;
  sensLow.tmp0     = sens.tmp0;
  sensLow.tmp      = sens.tmp;
  sensLow.c2b_tmp  = sens.c2b_tmp;
elseif iSite == 53
  sensHigh.tmp_del_range = sens.tmp_del_range;
  sensHigh.tmp0    = sens.tmp0;
  sensHigh.tmp     = sens.tmp;
  sensHigh.c2b_tmp = sens.c2b_tmp;
else
  error('Wrong Site') 
end
end

% pH Sensitivity
if 1
sens.pH_del_range = linspace(-4,4,nn);
sens.c2b_pH = zeros(size(sens.pH_del_range));
sens.pH = zeros(size(sens.pH_del_range));

for i=1:length(sens.pH_del_range)
%for i=length(sens.pH_del_range):length(sens.pH_del_range)
  inps.add_pH = sens.pH_del_range(i);

  [c2b_ratio,run_params,CO2_mass,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
  disp(['c2b ratio = ',num2str(c2b_ratio(end)*100,'%0.6f%%')]);

  sens.pH0 = run_params.pH0;
  sens.pH(i) = run_params.pH0 + inps.add_pH;
  sens.c2b_pH(i) = c2b_ratio(end);
end
inps.add_pH = 0;

if iSite == 88
  sensLow.pH_del_range = sens.pH_del_range;
  sensLow.pH0     = sens.pH0;
  sensLow.pH      = sens.pH;
  sensLow.c2b_pH  = sens.c2b_pH;
elseif iSite == 53
  sensHigh.pH_del_range = sens.pH_del_range;
  sensHigh.pH0    = sens.pH0;
  sensHigh.pH     = sens.pH;
  sensHigh.c2b_pH = sens.c2b_pH;
else
  error('Wrong Site') 
end
end

% flowrate Sensitivity
if 1
sens.flowrate_del_range = linspace(-.4,.4,nn);
sens.c2b_flowrate = zeros(size(sens.flowrate_del_range));
sens.flowrate = zeros(size(sens.flowrate_del_range));

for i=1:length(sens.flowrate_del_range)
  inps.add_flowrate = sens.flowrate_del_range(i);
  [c2b_ratio,run_params,CO2_mass,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
  disp(['c2b ratio = ',num2str(c2b_ratio(end)*100,'%0.6f%%')]);

  sens.flowrate0 = run_params.flowrate;
  sens.flowrate(i) = run_params.flowrate + inps.add_flowrate;
  sens.c2b_flowrate(i) = c2b_ratio(end);
end
inps.add_flowrate = 0;

if iSite == 88
  sensLow.flowrate_del_range = sens.flowrate_del_range;
  sensLow.flowrate0     = sens.flowrate0;
  sensLow.flowrate      = sens.flowrate;
  sensLow.c2b_flowrate  = sens.c2b_flowrate;
elseif iSite == 53
  sensHigh.flowrate_del_range = sens.flowrate_del_range;
  sensHigh.flowrate0    = sens.flowrate0;
  sensHigh.flowrate     = sens.flowrate;
  sensHigh.c2b_flowrate = sens.c2b_flowrate;
else
  error('Wrong Site') 
end
end


end

save('mat/sens/sens2_Cragmill_1year','sensLow','sensHigh')


%%
save('mat/sens/sens1_Labradorite','sensLow','sensHigh')
%%
save('mat/sens/sens2_Cragmill','sensLow','sensHigh')
%%
save('mat/sens/sens1_Middleton','sensLow','sensHigh')
%%
save('mat/sens/sens1_Hillhouse','sensLow','sensHigh')

%%

load('mat/sens/sens1_Cragmill')
load('mat/sens/sens1_Middleton')
load('mat/sens/sens1_Hillhouse')


%%

figure('position',[0 0 600 600])

plot(sensLow.npp,sensLow.c2b_npp*40,'-b','linewidth',2);
hold on
  plot(sensHigh.npp,sensHigh.c2b_npp*40,'-r','linewidth',2);
  i = (length(sens.npp_del_range)+1)/2;
  plot(sensLow.npp(i),sensLow.c2b_npp(i)*40,'bo','linewidth',2,'markerFaceColor','blue');
  plot(sensHigh.npp(i),sensHigh.c2b_npp(i)*40,'ro','linewidth',2,'markerFaceColor','red');
hold off
xlabel('gC/y')
ylabel('CO2 t/ha/y')
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
set(gca,'fontsize',12,'fontweight','bold');
title('NPP Sensitivity')
xlim([min([sensLow.npp,sensHigh.npp]),max([sensLow.npp,sensHigh.npp])]);
ylim([0 max([sensLow.c2b_npp,sensHigh.c2b_npp]*40)])

print(gcf,'-dpng','-r0','pics/sens_npp_high_low_1')

%%

figure('position',[0 0 600 600])

plot(sensLow.tmp,sensLow.c2b_tmp*40,'-b','linewidth',2);
hold on
  plot(sensHigh.tmp,sensHigh.c2b_tmp*40,'-r','linewidth',2);
  i = (length(sens.tmp_del_range)+1)/2;
  plot(sensLow.tmp(i),sensLow.c2b_tmp(i)*40,'bo','linewidth',2,'markerFaceColor','blue');
  plot(sensHigh.tmp(i),sensHigh.c2b_tmp(i)*40,'ro','linewidth',2,'markerFaceColor','red');
hold off
xlabel('t (^o)')
ylabel('CO2 t/ha/y')
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
set(gca,'fontsize',12,'fontweight','bold');
title('Temperature Sensitivity')
xlim([min([sensLow.tmp,sensHigh.tmp]),max([sensLow.tmp,sensHigh.tmp])]);
ylim([0 max([sensLow.c2b_tmp,sensHigh.c2b_tmp]*40)])

print(gcf,'-dpng','-r0','pics/sens_tmp_high_low_1')

%%

figure('position',[0 0 600 600])

plot(sensLow.pH,sensLow.c2b_pH*40,'-b','linewidth',2);
hold on
  plot(sensHigh.pH,sensHigh.c2b_pH*40,'-r','linewidth',2);
  i = (length(sens.pH_del_range)+1)/2;
  plot(sensLow.pH(i),sensLow.c2b_pH(i)*40,'bo','linewidth',2,'markerFaceColor','blue');
  plot(sensHigh.pH(i),sensHigh.c2b_pH(i)*40,'ro','linewidth',2,'markerFaceColor','red');
hold off
xlabel('pH')
ylabel('CO2 t/ha/y')
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
set(gca,'fontsize',12,'fontweight','bold');
title('pH Sensitivity')
xlim([min([sensLow.pH,sensHigh.pH]),max([sensLow.pH,sensHigh.pH])]);
ylim([0 max([sensLow.c2b_pH,sensHigh.c2b_pH]*40)])

print(gcf,'-dpng','-r0','pics/sens_pH_high_low_1')

%%

figure('position',[0 0 600 600])

plot(sensLow.flowrate*1000,sensLow.c2b_flowrate*40,'-b','linewidth',2);
hold on
  plot(sensHigh.flowrate*1000,sensHigh.c2b_flowrate*40,'-r','linewidth',2);
  i = (length(sens.flowrate_del_range)+1)/2;
  plot(sensLow.flowrate(i)*1000,sensLow.c2b_flowrate(i)*40,'bo','linewidth',2,'markerFaceColor','blue');
  plot(sensHigh.flowrate(i)*1000,sensHigh.c2b_flowrate(i)*40,'ro','linewidth',2,'markerFaceColor','red');
hold off
xlabel('flowrate (mm/y)')
ylabel('CO2 t/ha/y')
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
set(gca,'fontsize',12,'fontweight','bold');
title('Flowrate Sensitivity')
xlim(1000*[min([sensLow.flowrate,sensHigh.flowrate]),max([sensLow.flowrate,sensHigh.flowrate])]);
ylim([0 max([sensLow.c2b_flowrate,sensHigh.c2b_flowrate]*40)])

print(gcf,'-dpng','-r0','pics/sens_flowrate_high_low_1')

%%























figure('position',[0 0 600 600])

plot(sens1.npp - sens1.npp0,sens1.c2b_npp*40,'-b','linewidth',2);
hold on
  plot(sens2.npp - sens2.npp0,sens2.c2b_npp*40,'-r','linewidth',2);
  i = (length(sens.npp_del_range)+0)/2;
  plot(sens1.npp(i) - sens1.npp0,sens1.c2b_npp(i)*40,'bo','linewidth',2);
  plot(sens2.npp(i) - sens2.npp0,sens2.c2b_npp(i)*40,'ro','linewidth',2);
hold off
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
ylim([0 inf])
xlabel('\Delta gC/y')
ylabel('CO2 t/ha/y')
set(gca,'fontsize',12,'fontweight','bold');
title('NPP Sensitivity')

print(gcf,'-dpng','-r0','pics/sens_npp_high_low_2')


%%
inps.tf    = 51;
inps.p80   = 20;
[c2b_ratio_20,CO2_mass_20,~,pH] = mod6(inps);
disp(['c2b ratio = ',num2str(c2b_ratio_20(end)*100,'%0.6f%%')]);

inps.p80   = 30;
[c2b_ratio_30,CO2_mass_30,~,pH] = mod6(inps);
disp(['c2b ratio = ',num2str(c2b_ratio_30(end)*100,'%0.6f%%')]);

%%
figure(1)
subplot(2,1,1)
plot(.5:length(CO2_mass_20)-.5,CO2_mass_20, ...
 .5:length(CO2_mass_20)-.5,CO2_mass_30,'.')
subplot(2,1,2)
figure(2)
plot(CO2_mass_20 - CO2_mass_30,'-','linewidth',2)
set(gca,'fontsize',12)
title('gridcell = 144, p80=20 - p80=30')
xlim([0 600]);
print(gcf,'-dpng','-r0','pics/site144_p20mp30')

