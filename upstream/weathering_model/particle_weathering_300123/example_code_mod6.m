
iSiteCats = [88,69,53];
iSiteCats = [88,53];

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

inps.add_npp = 100;


Delz = 0.005;
p = .15/Delz+1;
z = (0:Delz:(p-1)*Delz)';
NFlux = [];
for i=1:size(inps.alk,1)
  NFlux(i,:) = interp1(0:.005:.15,inps.alk(i,:),z);
end
inps.alk = NFlux;

inps.iprof = 1;
inps.ibas  = 1;
inps.p80   = 100;
inps.tf    = 1;

%


mod1_epk(inps)


%%

%inps.tf    = 1;
%[c2b_ratio_20,run_params,CO2_mass_20,~,pH,K,P,~,CO_mass_outflow,CO_mass_precip] = mod6(inps);
%disp(['c2b ratio = ',num2str(c2b_ratio_20(end)*100,'%0.6f%%')]);
%disp(['K = ',num2str(K(end)*1000,'%0.2f'),'g/m^2']);
%disp(['P = ',num2str(P(end)*1000,'%0.2f'),'g/m^2']);

% MRL gets
% c2b ratio = 15.233036%
% K = 48.61g/m^2
% P = 23.45g/m^2

%

sens.npp_del_range = linspace(-500,500,11);
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

if iSite == 88
  sensLow = sens;
elseif iSite == 53
  sensHigh = sens    
else
  error('Wrong Site') 
end

end

%%

save('mat/sens/npp','sensLow','sensHigh')

%%

figure('position',[0 0 600 600])

plot(sensLow.npp,sensLow.c2b_npp*40,'-b','linewidth',2);
hold on
  plot(sensHigh.npp,sensHigh.c2b_npp*40,'-r','linewidth',2);
  i = (length(sens.npp_del_range)+1)/2;
  plot(sensLow.npp(i),sensLow.c2b_npp(i)*40,'bo','linewidth',2,'markerFaceColor','blue');
  plot(sensHigh.npp(i),sensHigh.c2b_npp(i)*40,'ro','linewidth',2,'markerFaceColor','red');
hold off
ylim([0 inf])
xlabel('gC/y')
ylabel('CO2 t/ha/y')
leg = legend({'low','high'});
leg.ItemTokenSize = [8 2];
set(gca,'fontsize',12,'fontweight','bold');
title('NPP Sensitivity')
xlim([min([sensLow.npp,sensHigh.npp]),max([sensLow.npp,sensHigh.npp])]);

print(gcf,'-dpng','-r0','pics/sens_npp_high_low_1')

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

