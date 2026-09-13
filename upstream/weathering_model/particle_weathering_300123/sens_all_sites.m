inps.iprof = 1; inps.ibas = 1;
load('data/driving_data_structure/dat_3_SSP2');
t0 = 1;

nsites = size(dat_f3.pH,1);
c2bAll = zeros(nsites,1);

%nsites = 1;

for isite=1:nsites
iSite = isite;

inps.alk      = squeeze(dat_f3.alk(iSite,(t0-1)*12+1:end,:));
inps.st       = dat_f3.st(iSite,(t0-1)*12+1:end)' - 273.15;
inps.wat      = dat_f3.wat(iSite,(t0-1)*12+1:end)'/1000;
inps.npp      = dat_f3.npp(iSite,(t0-1)*12+1:end)';
inps.yield    = inps.npp;
inps.sr       = dat_f3.sr(iSite,(t0-1)*12+1:end)';
inps.co2      = dat_f3.co2(iSite,(t0-1)*12+1:end)';
inps.fc       = dat_f3.fc(iSite);
inps.pH0      = dat_f3.pH(iSite);
inps.p80 = 100;
inps.tf = 1;

Delz = 0.005;
p = .15/Delz+1;
z = (0:Delz:(p-1)*Delz)';
NFlux = [];
for i=1:size(inps.alk,1)
  NFlux(i,:) = interp1(0:.005:.15,inps.alk(i,:),z);
end
inps.alk = NFlux;

[c2b,~,~,pH, K, P] = mod3(inps);

c2bAll(isite) = c2b(end)

end

save('sens_all_sites');
