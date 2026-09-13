clear

profiles = {
    'Tichum'
    'Blue_Ridge'
    'Pioneer'
    'Amy_1'
    'Cragmill'
    'Middleton'
    'Hillhouse'
    'Dummy_1'
    'Dummy_2'
    'Oregon'
    'Renforth'
    'Mike'
    'Energy_Farm_1'
    'Energy_Farm_2'
    'Cepuritis_1-25'
    'Cepuritis_20_60'
    'Nunes_1'
    'Nunes_2'
    'Nunes_3'
    'Nunes_4'
    'test'
    'Amy_2'
    };
basalts = {
    'Pioneer'
    'Blue_Ridge'
    'Tichum'
    'Blue_Ridge_2'
    'Blue_Ridge_2_short'
    'Pioneer'
    'Labradorite'
    'Labradorite2'
    'Virginia_3'
    'Oregon_1'
    'North_Carolina_1'
    'New_Jersey_1'
    'Massachusetts_1'
    'Pennsylvania_1'
    'Washington_1'
    'Washington_2'
    'Connecticut_1'
    'Connecticut_2'
    'Cragmill'
    'Middleton'
    'Hillhouse'
    'Dummy_1'
    'Dummy_2'
    'Oregon'
    'Alkali'
    'Tholeiite'
    'Lyla'
    'CRB_1'
    'CRB_2'
    'Ilmenite'
    'Tholeiite2'
    'Kfeldspar'
     };
eq_phases = {
    ''
    'Kaolinite'
    'Montmorillonite-Ca'
    };

warning('on','MATLAB:nearlySingularMatrix');

iprofile  = 1;
ibasalt   = 1;
ieq_phase = 1;

profile  = profiles{iprofile};
basalt   = basalts{ibasalt};
eq_phase = eq_phases{ieq_phase};

%clear basalt;
%basalt.name = {'Blue_Ridge_2_short','Pioneer'};
%basalt.name = {'Blue_Ridge_2','Pioneer'};
%basalt.name = {'Pioneer'};
%basalt.name = {'Tichum'};
%basalt.name = {'Connecticut_1'};
%basalt.year = [1,4];

% alpha is for advection beta is for Diffusion
% 0 is fully forward, 1 is fully backward, 1/2 is Crank-Nicholson
% min is kg/m^3, Ca is mol/litre
fd_params=struct( ...
'Delz',     0.005, ...     
'min_tol',  0.03,       'Ca_tol',   0.005,    'H_tol', 0.001, ...
'min_alpha',0.50,       'min_beta', 0.50,     'min_Diff',1e-4, ...
'Ca_alpha', 0.50,       'Ca_beta',  0.50,     'Ca_Diff', 2e-3, ...
'H_alpha',  0.50,       'H_beta',   0.50,     'H_Diff',  1e-4, ...
'BC_iter',  1, ...
'SA_VOL_bins',200,      'profile_bins', 200,  'test', 'no', ...
'spinup_length',14/365, 'spinup_steps',50,    'spinup_power', 1.2, ...
'min_Delt', 1/4/365,    'max_Delt', 1/12);

run_params=struct( ...
'cells',15,            'total_cells',15,    'basalt_cells',15, ...
'affinity', 'yes',     'exchanger',         'yes', ...
'acidifier','yes',     'buffer',            'yes', ...
'N_alk',    'yes',     'apatite_inhibiter', 'yes', ...
'tf',1,                'woody',0,           'nppnormscale', 1000, ...
'tmp',20,              'flowrate',1,        'CO2', 410, ...
'pH0',6.0,             'pH_rain',6.0,       'spinup', 4, ...
'b_mass',50e-1,      ...
'depth',0.15,          'basalt_depth',0.15, 'rooting_depth',.9, ...
'p80',0,               'fd',0.0,            'lambda', 300, ...
'yield',600,           'npp',1000,          'soy', 0, ...
'wfp',.25,             'wfp_min',.1, ...
'ocean_salinity',35,   'ocean_tmp',17, ...      
'bucket_dampner', 0.5, 'Ceq_dampner', 0.0, ...
'add_npp',0,           'add_flowrate',0, ...
'add_tmp',0,           'add_pH',0, ...
'average_drv','no',    'data_dir','../particle_weathering_data', ...
'reps', 1,            'transport',         'no',  ...
'model_P_or_C', 'C',   'minerals_filename', 'mineral_parameters_Pioneer');
%'model_P_or_C', 'C',   'minerals_filename', 'mineral_parameters_Blue_Ridge_2');
%'model_P_or_C', 'C', 'minerals_filename', 'mineral_parameters4_USA');
%'model_P_or_C', 'C',   'minerals_filename', 'mineral_parameters_Tichum');

fidani = 79;
if strcmp(run_params.model_P_or_C,'C')
  fidani = fidani + 100;
end

if strcmp(run_params.transport,'no')
  reps = 1;
end

%figure(fidani+100); clf;

% Driving data: montly values ie m/mnth/m^2 or gC/mnth/m^2
% N (gN/s/M^3)
% tmp (c)
% flowrate (m/yr)
% npp, yield, soilresp (gC/yr)

%[data_Flux,data_tmp,data_year0,data_yearf,data_lat,data_lon] = Nitrogen_readData(run_params,fd_params,0);
%save('Nitrogen.mat','data_Flux','data_tmp','data_year0','data_yearf','data_lat','data_lon')
%load('Nitrogen.mat');
%disp('read data');

% A uniform N source of 3e-5 gN/s/M^3 should give rise to 
% an alkalinity of 0.0095 mol/l given q = 1 m/year phi =0.25.
%xlat = 53.25;
%xlon = -1;
%[ilat,ilon]  = get_ilatlon(xlat,xlon,data_lat,data_lon);
%data.N.year0 = data_year0;
%data.N.yearf = data_yearf;
%data.N.Flux  = data_Flux(:,:,ilat,ilon);

%data.tmp      = data_tmp(:,ilat,ilon)*0 + 15;
%data.flowrate = data.tmp*0 + run_params.flowrate/12;
%data.npp      = data.tmp*0 + run_params.npp/12;
%data.yield    = data.tmp*0 + run_params.npp/12;
%data.soilresp = data.npp*1.5;
%data.CO2      = data.npp*0 + run_params.CO2;

t0 = 1;

% site nos [low 88: med 69: high 53]
load('../particle_weathering_data/driving_data_structure/dat_3_SSP2');
iSiteCats = [88,69,53];
iSite = iSiteCats(2);
markz = dat_f3;

data.N.Flux   = squeeze(markz.alk(iSite,(t0-1)*12+1:end,:));
data.tmp      = markz.st(iSite,(t0-1)*12+1:end)' - 273.15;
data.flowrate = double(markz.wat(iSite,(t0-1)*12+1:end)'/1000);
data.npp      = markz.npp(iSite,(t0-1)*12+1:end)';
data.yield    = data.npp;
data.soilresp = markz.sr(iSite,(t0-1)*12+1:end)';
data.CO2      = markz.co2(iSite,(t0-1)*12+1:end)';
run_params.pH0 = markz.pH(iSite);
run_params.wfp = markz.fc(iSite);

temp1 = data.tmp;
fr1 = data.flowrate;


load('../particle_weathering_data/driving_data_structure/run_strc_3');
iSite = 1;
markz = mylist{iSite};

data.N.Flux = markz.N';
data.tmp = markz.st' - 273.15;
data.flowrate = double(markz.infil'/1000);
data.npp = double(markz.npp');
data.yield = data.npp;
data.soilresp = double(markz.sr');
data.CO2 = markz.co2';

run_params.pH0 = markz.pH;
run_params.wfp = markz.fc;

if 1
load('../particle_weathering_data/driving_data_structure/run_strc_6');
CLM_depths = [0, 5, 15, 30, 60, 100, 200]/100;
iSite = 238; % Illinoise
%iSite = 1;
markz = mylist{iSite};
data.N.Flux = markz.N';
data.tmp = markz.st' - 273.15;
data.flowrate = double(markz.infil'/1000);
data.npp = double(markz.npp');
data.yield = data.npp;
data.soilresp = double(markz.sr');
data.CO2 = markz.co2';

end
run_params.pH0 = markz.pH*0+6.0;
%run_params.pH0 = markz.pH;
run_params.wfp = markz.fc;

if strcmp(basalt,'Tichum')

  load('../particle_weathering_data/Energy_Farm/Tichum_Drivers/data_Tichum.mat')

  data.tmp(1:96,:) = Tichum_tmp;
  data.yield(1:96,:) = Tichum_yield*2;
  data.npp(1:96,:) = Tichum_yield*2;
  data.soilresp(1:96,:) = Tichum_soilresp*2;
  data.flowrate(1:96) = Tichum_flowrate;
  run_params.wfp = .2;

end

if 0
load('../particle_weathering_data/driving_data_structure/marks_1');
CLM_depths = [0, 5, 15, 30, 60, 100, 200]/100;
markz = tesf
data.N.Flux = markz.N';
data.tmp = markz.st' - 273.15;
data.flowrate = double(markz.infil'/1000);
data.npp = double(markz.npp');
data.yield = data.npp;
data.soilresp = double(markz.sr');
data.CO2 = markz.co2';

run_params.pH0 = markz.pH*0+6.3;
run_params.wfp = markz.fc;
end

Delz = fd_params.Delz;
p = round(run_params.depth/Delz+1);
z = (0:Delz:(p-1)*Delz)';
stmp = [];
for i=1:size(data.tmp,1)
  stmp(i,:) = interp1(CLM_depths,data.tmp(i,:),z);
end
data.tmp = stmp;

run_params.pH0 = interp1(CLM_depths,run_params.pH0,z);
%run_params.pH0 = run_params.pH0(1);
%return

data.N.Flux(612,p) = 0;
for i=32:p
  data.N.Flux(:,i) = data.N.Flux(:,31);
end

if 0
  load('data/fert/fert_test/res')
  % res(depths,months,lat,lon,fert scenario)
  ilat = 20; ilon = 33;

  alk_0 = squeeze(res(:,:,ilat,ilon,4));
  alk_1 = alk_0';

  size(alk_1);
  size(data.N.Flux);

  if 0
    yl = [-1 1]*1e-5;
    figure(1)
    subplot(2,1,1)
    plot(data.N.Flux(1:60,:)); ylim(yl);
    subplot(2,1,2)
    plot(alk_1(1:60,:)); ylim(yl);
  end
  data.N.Flux(1:60,:) = alk_1;
end

run_params.tmp      = sum(data.tmp(1:run_params.spinup*12))/run_params.spinup/12;
run_params.flowrate = sum(data.flowrate(1:run_params.spinup*12))/run_params.spinup;
run_params.npp      = sum(data.npp(1:run_params.spinup*12))/run_params.spinup;
run_params.yield    = sum(data.yield(1:run_params.spinup*12))/run_params.spinup;
run_params.soilresp = sum(data.soilresp(1:run_params.spinup*12))/run_params.spinup;
run_params.CO2      = sum(data.CO2(1:run_params.spinup*12))/run_params.spinup/12;

% Average drivers
if strcmp(run_params.average_drv,'yes')
  data.tmp = data.tmp*0 + run_params.tmp;
  data.flowrate = data.flowrate*0 + run_params.flowrate/12;
  data.npp = data.npp*0 + run_params.npp/12;
  data.yield = data.yield*0 + run_params.yield/12;
  data.soilresp = data.soilresp*0 + run_params.soilresp/12;
%  data.N.Flux = data.N.Flux*0 + sum(sum(data.N.Flux(1:run_params.spinup*12,:)))/run_params.spinup/12/p;
end

% run epk style

inps.iprof = iprofile;
inps.ibas = ibasalt;
inps.lamb = run_params.fd;
inps.p80 = run_params.p80;
inps.pH = run_params.pH0;
inps.fc = run_params.wfp;
inps.yy = run_params.tf;

inps.st = data.tmp;
inps.wat = data.flowrate;
inps.npp = data.npp;
inps.sr = data.soilresp;
inps.co2 = data.CO2;
inps.alk = data.N.Flux;

mod1_epk(inps);

%%


%
Delz = fd_params.Delz;
p = round(run_params.depth/Delz+1);
z = (0:Delz:(p-1)*Delz)';
NFlux = [];
for i=1:size(data.N.Flux,1)
  NFlux(i,:) = interp1(0:.005:run_params.depth,data.N.Flux(i,:),z);
end
data.N.Flux = NFlux;

if strcmp(fd_params.test,'yes')
  fd_params.BC_iter = 1;
  fd_params.min_Diff = 0;
  fd_params.SA_VOL_bins  = 100;
  fd_params.profile_bins = 100;
  tf = 1;
end

% set theoretical pH2alk & alk2pH functions
global pH2Alk_theoretical alk2pH_theoretical
pH2Alk_theoretical = @ph2alk_no_buffer;
load('alk2pH_function.mat');
alk2pH_theoretical = alk2pH;

% set model pH2alk & alk2pH functions
if strcmp(run_params.buffer,'yes')
  alk2pH = @alk2pH_buffer;
  pH2Alk = @pH2Alk_buffer;
  load('CaSatBuffered_function.mat') % sets @Csat
else
  load('alk2pH_function.mat'); % sets @alk2pH;
  pH2Alk = @pH2Alk_no_buffer;
  load('CaSatNotBuffered_function.mat') % sets @Csat
end

% Soil CO2 profile
soil_CO2 = co2_profile(run_params.depth,fd_params.Delz, ...
 run_params.rooting_depth,run_params.CO2, ...
 run_params.soilresp,0)*1e6;

Delz = fd_params.Delz;
p = round(run_params.depth/Delz+1);
z = (0:Delz:(p-1)*Delz)';

nppavg = run_params.npp;
enhancement = comp_npp_enhancement( ...
 npp2nppnorm(nppavg,run_params.nppnormscale),run_params.woody);

params = set_basalt(basalt,run_params);
%params.mf = [.3 .7];
%params.rho = [2000 4000];
%params.mf = [.2 .8];
%params.rho = [2000 2000];

[rad0,mfd0] = set_profile(profile,run_params,fd_params.profile_bins,0);

if run_params.p80>0
  pval = p_x(mfd0,rad0,80);
  rad0 = rad0/pval*run_params.p80;
  mfd0 = mfd0/trapz(rad0,mfd0);
  fprintf('p_80 = %.3f',pval)
end
rad0 = rad0'; mfd0 = mfd0';
w = m2k(comp_k(run_params.pH0(1),run_params.tmp,params),params.mol_mass);
%[rad0,mfd0] = make_profile(p80/2,[.05],[1],fd_params.profile_bins);
%[rad0,mfd0] = make_profile(10,[.05],[1],fd_params.profile_bins);


% Override some variable for a test
if strcmp(fd_params.test,'yes')
% sets basalt weathering rate to 50 microns per year
  [rad0,mfd0] = make_profile([100 150 200],[1 1 1]*.5,[5 3 2],fd_params.profile_bins);
%  [rad0,mfd0] = make_profile([50],[1]*.5,[2],fd_params.profile_bins);
%  figure(2);
%  stem(rad0,mfd0);
% mass loss percentage for 1 year = 76.42361% = 1 - .5*(1/8) - .3*(8/27) - .2*(27/64)
  w = 50e-6*params.rho;
  enhancement = 1;
  affinity = 'no';
  run_params.affinity = 'no';
  run_params.fd = 0;
  params.mf = params.mf/sum(params.mf(1:length(params.names)));
end

w = w*enhancement; % enhanced weathering
SA_phc = enhancement*3/(params.vf0*params.rho')*trapz(rad0,mfd0.*(10^10*rad0).^run_params.fd./rad0)/1000;
GSA = 3/(params.vf0*params.rho')*trapz(rad0,mfd0./rad0)/1000;
SA_phc/enhancement;

%
[parms,mol_lpw_min,sa_prop,lpw_m2] = calc_phc_params(params,SA_phc,run_params.b_mass,run_params.depth,run_params.wfp);
[SA_org, vol_org] = SA_vs_Vol_9(rad0,mfd0,run_params.fd,0);

clear w

run_params.pH0 = run_params.pH0 + run_params.add_pH;
% Calculate baseline alkaninity to give rise to constant pH profile
alk0 = calc_alk0(data,run_params,fd_params,soil_CO2,pH2Alk,alk2pH);


% Adjust drivers
data.npp = data.npp/sum(data.npp)*(run_params.npp + run_params.add_npp)*size(data.npp,1)/12;
data.tmp = data.tmp + run_params.add_tmp;
data.flowrate = data.flowrate + run_params.add_flowrate/12;

% Run simple model
tic
[PB,alk_sim,H_sim,C_sim,B_sim,pH_sim,Ca_sol_sim,Ca_precip_sim, ...
 Ca_sat_sim,Cf_sim,R_sim,outflow_sim,outflowCa_sim,outflowH_sim, ...
 swvf_sim,z_sim,t_sim,Delz_sim,Delt_sim,profiles,tolerences] = ...
fd15(data,run_params,fd_params,params,basalt,eq_phase,rad0,mfd0, ...
 enhancement,SA_org,vol_org,soil_CO2,alk2pH,pH2Alk,CaSat,alk0,[],100,1);
toc 

pH_avg_sim = sum(pH_sim,1)/size(pH_sim,1);
[totals,CaCO3_sim,RCO2_sim,K_mass,P_mass,Ca_mass_precip_t, ...
    c2b_ratio,CO2_mass,CO2_mass_precip,CO2_mass_outflow, ...
    Application_Basalt_mass,outElements] = mass_balance(41,params,fd_params, ...
 run_params,data,t_sim,B_sim,C_sim,outflow_sim,run_params.depth, ...
 Ca_sol_sim,Ca_precip_sim,outflowCa_sim,run_params.wfp, ...
 run_params.b_mass,H_sim,outflowH_sim,swvf_sim,0);

disp(['c2b ratio = ',num2str(RCO2_sim(end)*100,'%0.6f%%')]);
disp(['K = ',num2str(K_mass(end)*1000,'%0.2f'),'g/m^2']);
disp(['P = ',num2str(P_mass(end)*1000,'%0.2f'),'g/m^2']);

%CO2_mass_20 = CO2_mass;
%CO2_mass_30 = CO2_mass;
%totals.Outflow.P

draw_results( ...
    fidani+100,params,run_params,data,fd_params.Delz,soil_CO2,RCO2_sim, ...
    totals,alk_sim,B_sim,C_sim,H_sim,outflow_sim,R_sim,Cf_sim, ...
    run_params.b_mass,z_sim,t_sim,Ca_sol_sim,Ca_precip_sim,run_params.wfp, ...
    pH_sim,run_params.depth,outflowCa_sim,outflowH_sim,swvf_sim,Ca_sat_sim,alk2pH);

%%

rco1tmp1 = RCO2_sim;
global GM

B_mass_t = [];
for i=1:length(params.names);
  for j=1:size(B_sim,3)
    B_mass_t(i,j) = trapz(z,squeeze(B_sim(i,:,j)));
  end
end

(B_mass_t(1) - B_mass_t(end))/B_mass_t(1)*100


M1 = GM

%save('movies/Cragmill_0p02_0p04','M1','M2')


%%


figure(51)
subplot(4,2,1)
plot(t_sim,pH_avg_sim,'linewidth',2); ylim([0 max(pH_avg_sim)*1.1]); ylabel('pH')
subplot(4,2,3)
plot(t_sim,alk_sim,'linewidth',2); ylabel('Alkalinity (mols)');
subplot(4,2,5)
plot(t_sim,CaCO3_sim,'linewidth',2); ylabel('CaCO3 (mols)');
subplot(4,2,7)
plot(t_sim,RCO2_sim,'linewidth',2); ylabel('RCO2');

%%

C_t = squeeze(C_sim(:,:,end));
Ca_sol = squeeze(Ca_sol_sim(:,end));

C_t_molperl = C_t./params.mol_mass';

%Ca = C_t_molperl.*params.elements.Ca'; Ca = squeeze(sum(Ca,1))';
Mg = C_t_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1))';
K  = C_t_molperl.*params.elements.K';  K  = squeeze(sum(K ,1))';
Na = C_t_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1))';

alk = 2*Ca_sol + 2*Mg + K + Na;

[alk, H_sim(:,end)]


%%

figure(73)
plot(t_sim,squeeze(sum(B_sim,2)),'linewidth',2)
ylim([0 inf])
legend(params.names)

figure(74)
plot(t_sim,squeeze(sum(B_sim(end,:,:),2)),'linewidth',2)
ylim([0 inf])
legend(params.names{end})

figure(76)
plot(t_sim,squeeze(sum(H_sim(:,:),1)),'linewidth',2)
ylim([0 inf])
title('H+');

%%

figure(78)
plot(squeeze(H_sim(:,end)),z,'linewidth',2)
set(gca,'Ydir','reverse')
ylim([0 inf])
title('H+');

%%


%%
% Run phreeqC
run_params.exchanger = 'no';

depth = .15

SA = SA_phc
%SA = 42.7;

fid = 38;

dataDir = 'phc_profile';
st1 = 'site';
phc_dir = [dataDir,'\',st1];
phc_model = 'test';
newInputFile = [phc_dir,'\input\' ,phc_model,'.pqi'];
outputFile   = [phc_dir,'\output\',phc_model,'.tsv'];

phi = wfp; % porosity
time_step = depth/total_cells/flow_rate*phi*3600*24*365;
shifts = round(365*24*3600/time_step*tf);
Delz = depth/total_cells;

z_phc = depth/total_cells:depth/total_cells:depth; z_phc=z_phc';
soil_CO2_phc = interp1(z,soil_CO2,z_phc-Delz/2);

[parms,mol_lpw_min,sa_prop,lpw_m2] = calc_phc_params(params,SA,b_mass,depth*basalt_cells/total_cells,wfp);

make_transport_file_profile(dataDir,total_cells,time_step,shifts,depth);
make_kinetic_reactants_file(dataDir,params,basalt_cells);
make_selected_output_file(dataDir,params);
make_exchange_file(dataDir,run_params.total_cells,run_params.exchanger);
make_solution1_file(dataDir,total_cells);
make_equilibrium_phases_file(dataDir,total_cells,soil_CO2_phc,eq_phase);

phc = make_input_file_profile(dataDir,st1,newInputFile,'affin',run_params,affinity,'file',outputFile, ...
    'm',mol_lpw_min,'m0',mol_lpw_min,'parms',parms,'temp',[1 1]*tmp);
phc.exchanger = run_params.exchanger;

disp('Running phc ...');
tic
cmdout = run_phreeqc(newInputFile);
toc
disp('Finished phc run.');

%%
fid = 57;

figure(fid); clf;
outputs  = params.names;
outputsk = {}; outputsdk = {};
outputsCa = {}; outputsCalcite = {}; outputsNa = {};
for i=1:length(outputs)
  outputsk = [outputsk,['k_',outputs{i}]];
  outputsdk = [outputsdk,['dk_',outputs{i}]];
end
[outputdk] = readOutputFile_profile(outputFile,outputsdk,phc,1,1);
[outputk, d]  = readOutputFile_profile(outputFile,outputsk,phc,1,1);
[outputpH] = squeeze(readOutputFile_profile(outputFile,{'pH'},phc,1,1));
[outputCa] = squeeze(readOutputFile_profile(outputFile,{'Ca'},phc,1,1));
[outputNa] = squeeze(readOutputFile_profile(outputFile,{'Na'},phc,1,1));
[outputCalcite] = squeeze(readOutputFile_profile(outputFile,{'Calcite'},phc,1,1));

% add initial mass to phreeqc output
outputk(:,2:size(outputk,2)+1,:)   = outputk;
outputdk(:,2:size(outputdk,2)+1,:) = outputdk;
for i=1:size(outputk,1)
  for j=1:size(outputk,3)
    outputk(i,1,j) = mol_lpw_min(i);
    outputdk(i,1,j) = 0;
  end
end

outputCa(2:size(outputCa,1)+1,:) = outputCa;
outputNa(2:size(outputNa,1)+1,:) = outputNa;
outputCalcite(2:size(outputCalcite,1)+1,:) = outputCalcite;

%convert from moles per litre of pore water to kg per litre of soil
for i=1:size(outputk,1)
  for j=1:size(outputk,2)
    for k=1:size(outputk,3)
      outputk(i,j,k)  = phi*params.mol_mass(i)*outputk(i,j,k);
      outputdk(i,j,k) = phi*params.mol_mass(i)*outputdk(i,j,k);
    end
  end
end

% Draw profiles for one of the minerals
imin = 2;

outdk = squeeze(outputdk(imin,:,:));
outk  = squeeze(outputk(imin,:,:));

C = -outdk(imin,:)'; csum = 0;
C = C*0;
Cf = max(max(max(outk)));
L = 0.15;
B_init = max(max(max(outk)));

pH0 = 4; pHf = 10;
B_total = max(max(max(outk)));

figure(66);

make_text_boxes_profile;
sol_mass = 1;
B_mass = 1;

B_total = sum(outk(1,:)')*Delz

CV = []; BV = []; outflow = 0; B = [];

% plot totals for all minerals
lw = 2;
axis(h3);
%figure(34);
t_rtm = [0:shifts]*time_step/3600/24/365;
B_tots_rtm = squeeze(sum(outputk,3)/size(outputk,3))*depth;
lines = {};
lc = [0 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0 0];
plot(t_rtm,B_tots_rtm,'linewidth',lw);
%legend(params.names,'location','northeastoutside');
ylim([0 max(max(B_tots_rtm))]);
xlim([0 t_rtm(end)]);
ylabel('Areal Density (kg/m^2)');
%ylim([0 .4])
grid

delm_rtm = (B_tots_rtm(:,1) - B_tots_rtm(:,end));
c2b_ratio_rtm = sum(delm_rtm.*params.co2_ratio')/b_mass;
disp(['c2b ratio ',num2str(c2b_ratio_rtm*100),'%'])

%(B_tots_rtm(3,2) - B_tots_rtm(3,end))/B_tots_rtm(3,end)*100

ppH = squeeze(readOutputFile_profile(outputFile,{'pH'},phc,1,1));
pCa = squeeze(readOutputFile_profile(outputFile,{'Ca'},phc,1,1));
pMg = squeeze(readOutputFile_profile(outputFile,{'Mg'},phc,1,1));
pNa = squeeze(readOutputFile_profile(outputFile,{'Na'},phc,1,1));
pK = squeeze(readOutputFile_profile(outputFile,{'K'},phc,1,1));
pSi = squeeze(readOutputFile_profile(outputFile,{'Si'},phc,1,1));
pAl = squeeze(readOutputFile_profile(outputFile,{'Al'},phc,1,1));
pCalcite = squeeze(readOutputFile_profile(outputFile,{'Calcite'},phc,1,1));

ii = zeros(1,size(pCa,2));
pCalcite = [ii; pCalcite];
pCa = [ii; pCa];
pMg = [ii; pMg];
pNa = [ii; pNa];
pK = [ii; pK];

Ca_O = pCa(:,15)*1000*flow_rate;
Mg_O = pMg(:,15)*1000*flow_rate;
Na_O = pNa(:,15)*1000*flow_rate;
K_O  = pK(:,15)*1000*flow_rate;
Si_O = pSi(:,15)*1000*flow_rate;
Al_O = pAl(:,15)*1000*flow_rate;

Ca_O_sum = tril(ones(size(Ca_O,1)))*Ca_O/size(Ca_O,1);
Na_O_sum = tril(ones(size(Ca_O,1)))*Na_O/size(Ca_O,1);
Mg_O_sum = tril(ones(size(Ca_O,1)))*Mg_O/size(Ca_O,1);
K_O_sum  = tril(ones(size(Ca_O,1)))*K_O/size(Ca_O,1);

%CDR2 = .861*(Na_O + K_O + 2*(Mg_O + Ca_mass_sol_t*phi*1000 + outflowCa_t*phi)) + Ca_mass_precip_t*phi*1000;
CDR2 = .861*(Na_O_sum + K_O_sum + 2*(Mg_O_sum + Ca_O_sum)) + sum(pCalcite,2)/15;
c2b_ratio = CDR2(end)*44/(b_mass*1000*floor(tf));
disp(['c2b ratio x ',num2str(c2b_ratio*100),'%'])

%
%ppH(:,1) = [];
%pCa(:,1) = [];
%pMg(:,1) = [];
%pNa(:,1) = [];
%pK(:,1) = [];
%pSi(:,1) = [];
%pAl(:,1) = [];
%pCalcite(:,1) = [];
%z_phc(1) = [];

ksp = 3.3e-9;
Kw = 14.16; Kw = 10^-Kw;
Kh = 1.41;  Kh = 10^-Kh;
K1 = 6.38;  K1 = 10^-K1;
K2 = 10.38; K2 = 10^-K2;
rho = 10^-6;

a0  = @(H) 1./(1 + K1./H + K1*K2./H.^2);
a1  = @(H) 1./(1 + H/K1 + K2./H);
a2  = @(H) 1./(1 + H/K2 + H.^2/K1/K2);
Alk = @(H) Kh*rho*CO2*(a1(H) + 2*a2(H))./a0(H) + Kw./H - H;

alk0 = pH2Alk(7,1000)*0;

H = 10.^-ppH;
%A1 = Alk(H);
A2 = alk0 + 2*pCa + 2*pMg + pK + pNa;

pH2 = alk2pH(ones(size(A2,1),1)*soil_CO2_phc',A2);

%for t=2:2
for t=2:10:size(outdk,1)
  outflow = outflow + C(end)*Delz*phi;
  C = [0;C(1:end-1)] + (outk(t-1,:)' - outk(t,:)')/phi;
  B = outk(t,:)';
  Ca = outputCa(t,:)';
  Na = outputNa(t,:)';
  Calcite = outputCalcite(t,:)';

  sol_mass = sum(C)*Delz;
  B_mass = sum(B)*Delz;
  
  zz = [0;0;reshape([z_phc,z_phc]',2*length(z_phc),1)];
  
  CC = [0;reshape([C,C]',2*length(C),1);0];
  BB = [0;reshape([B,B]',2*length(B),1);0];
  
  CaCa = [0;reshape([Ca,Ca]',2*length(Ca),1);0];
  NaNa = [0;reshape([Na,Na]',2*length(Na),1);0];
  CalCal = [0;reshape([Calcite,Calcite]',2*length(Calcite),1);0];
  
%  p1.Vertices = [[0; C; 0],[0; z_phc; L]];
%  p2.Vertices = [[0; B; 0],[0; z_phc; L]];
  p1.Vertices = [CC,zz];
  p2.Vertices = [BB,zz];
  p3.Vertices = [CaCa,zz];
  p4.Vertices = [CalCal,zz];
  p5.Vertices = [NaNa,zz];

  textp11.String = {'Total Solution Mass',sprintf('%0.3f kg',sol_mass)};
  textp12.String = {'Total Outflow Mass',sprintf('%0.3f kg',outflow)};
  textp22.String = {'Total Basalt Mass',sprintf('%0.3f kg',B_mass)};
  textp23.String = {'System Mass Error',sprintf('%0.1f %s',((sol_mass*phi+outflow+B_mass)/B_total-1)*100,'%')};
  textp21.String = {'Time',sprintf('%0.2f yrs',(t-1)*time_step/3600/24/365)};
  
  lpH.XData = (outputpH(t-1,:) - pH0)/(pHf - pH0)*B_init(1);
  lpH2.XData = (pH2(t-1,:) - pH0)/(pHf - pH0)*B_init(1);

  drawnow; pause(.05);
  CV = [CV,C];
  BV = [BV,B];
end

figure(88)

its = [8 2];
newUnits = 'normal';
fsl = 6;

B_rtm = permute(outputk,[1,3,2]);
C_rtm = [];
for imin=1:size(outputk,1)
  outk  = squeeze(outputk(imin,:,:));
  C = -outdk(imin,:)';
  C = C*0;
  for t=2:size(outdk,1)
    C = [0;C(1:end-1)] + (outk(t-1,:)' - outk(t,:)')/phi;
    C_rtm(imin,:,t) = C;
  end
end

%B_sim(1,:,1)
%B_rtm(1,:,1)
%C_rtm(2,:,end)'
%C_sim(2,:,end)'

%Ca_sol_rtm = permute(outputCa,[2,1]);
%Ca_sol_sim(:,end)
%Ca_sol_rtm(:,end)

figure(fid); clf
subplot(3,2,4);
plot(t_rtm',Ca_O_sum,t_rtm',Mg_O_sum,t_rtm,K_O_sum,t_rtm,Na_O_sum,'linewidth',2)
hL = legend({'Ca','Mg','K','Na'});
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
title('outflow mols')
grid;

B_mass_t = []; C_mass_t = []; Ca_mass_t = []; Ca_mass_sol_t = []; Ca_mass_precip_t = [];
nmins = length(params.names);
for i=1:nmins
  for j=1:size(B_rtm,3)
    B_mass_t(i,j) = sum(B_rtm(i,:,j)/15)*.15;
    C_mass_t(i,j) = sum(C_rtm(i,:,j)/15)*.15;
  end
end

for j=1:length(t)
% times by a thousand as we are integrating mols per litre over meters
% and mols per litre are effectively mols per millimeter per meter squared.
%  Ca_mass_sol(j) = trapz(z,squeeze(Ca_sol_rtm(:,j)))*1000*phi;
%  Ca_mass_precip(j) = trapz(z,squeeze(Ca_precip_rtm(:,j)))*1000*phi;
end

C_molperl = 1000*B_mass_t./params.mol_mass'; % mols per m^2
Ca_B = C_molperl.*params.elements.Ca'; Ca_B = squeeze(sum(Ca_B,1));
Mg_B = C_molperl.*params.elements.Mg'; Mg_B = squeeze(sum(Mg_B,1));
K_B  = C_molperl.*params.elements.K';  K_B  = squeeze(sum(K_B ,1));
Na_B = C_molperl.*params.elements.Na'; Na_B = squeeze(sum(Na_B,1));

C_molperl = 1000*C_mass_t./params.mol_mass'; % mols per m^2
Ca_C = C_molperl.*params.elements.Ca'; Ca_C = squeeze(sum(Ca_C,1));
Mg_C = C_molperl.*params.elements.Mg'; Mg_C = squeeze(sum(Mg_C,1));
K_C  = C_molperl.*params.elements.K';  K_C  = squeeze(sum(K_C ,1));
Na_C = C_molperl.*params.elements.Na'; Na_C = squeeze(sum(Na_C,1));

Ca_O = pCa(:,15)*1000*flow_rate;
Mg_O = pMg(:,15)*1000*flow_rate;
Na_O = pNa(:,15)*1000*flow_rate;
K_O  = pK(:,15)*1000*flow_rate;
Si_O = pSi(:,15)*1000*flow_rate;
Al_O = pAl(:,15)*1000*flow_rate;

Ca_O = tril(ones(size(Ca_O,1)))*Ca_O/size(Ca_O,1); Ca_O = Ca_O';
Na_O = tril(ones(size(Na_O,1)))*Na_O/size(Na_O,1); Na_O = Na_O';
Mg_O = tril(ones(size(Mg_O,1)))*Mg_O/size(Mg_O,1); Mg_O = Mg_O';
K_O = tril(ones(size(K_O,1)))*K_O/size(K_O,1); K_O = K_O';

totCa = Ca_B + Ca_O + Ca_C*phi;
totMg = Mg_B + Mg_O + Mg_C*phi;
totK  =  K_B +  K_O +  K_C*phi;
totNa = Na_B + Na_O + Na_C*phi;

subplot(3,2,2)
plot(t_rtm,totCa,t_rtm,totMg,t_rtm,totK,t_rtm,totNa,'linewidth',2)
ylim([0 inf]);
title('min total mols');
hL = legend('Ca','Mg','K','Na');
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t_rtm(end)]); grid;

subplot(3,2,6)
plot(t_rtm,B_mass_t,'linewidth',2)
title('Basalt (kg)')
hL = legend(params.names);
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t_rtm(end)]); grid;

Ca_sol = 1000*(sum(pCa,2)/15)*depth*phi;
Ca_precip = 1000*(sum(pCalcite,2)/15)*depth*phi;

CDR2 = .861*(Na_O_sum + K_O_sum + 2*(Mg_O_sum + Ca_O_sum)) + Ca_precip;
CDR2_rtm = CDR2*44/(b_mass*1000);


disp(['Na    = ',num2str(Na_O_sum(end))]);
disp(['K     = ',num2str(K_O_sum(end))]);
disp(['Mg    = ',num2str(Mg_O_sum(end))]);
disp(['Ca    = ',num2str(Ca_O_sum(end))]);
disp(['CO3Ca = ',num2str(Ca_precip(end))]);


subplot(3,2,5)
plot(t_rtm,CDR2_rtm,'linewidth',2)
%plot(t,CDR2,t,CDR1,'linewidth',2)
title('CDR');
%hL = legend({'New','Old'});
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t_rtm(end)]); grid;


totCa2 = Ca_B+Ca_O_sum'+Ca_precip'+Ca_sol';
subplot(3,2,3)
plot(t_rtm',totCa2,t_rtm',Ca_B,t_rtm',Ca_O_sum',t_rtm',Ca_precip',t_rtm',Ca_sol,'linewidth',2)
ylim([0 inf])
title('mols Ca')
hL = legend({'total','Basalt','outflow','CaCO_3','solution'});
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t_rtm(end)]); grid;

disp(['c2b ratio ',num2str(CDR2_rtm(end)*100),'%'])




%%
ksp = 3.3e-9;
Kw = 14.16; Kw = 10^-Kw;
Kh = 1.41;  Kh = 10^-Kh;
K1 = 6.38;  K1 = 10^-K1;
K2 = 10.38; K2 = 10^-K2;
rho = 10^-6;
CO2 =1000;

a0  = @(H) 1./(1 + K1./H + K1*K2./H.^2);
a1  = @(H) 1./(1 + H/K1 + K2./H);
a2  = @(H) 1./(1 + H/K2 + H.^2/K1/K2);
Alk = @(H) Kh*rho*CO2*(a1(H) + 2*a2(H))./a0(H) + Kw./H - H;

C   = @(H) Kh*rho*CO2./a0(H);
CO3 = @(H) C(H).*a2(H);
Ca  = @(H) ksp./CO3(H);

alk0 = pH2Alk(7,1000)*0;


%%

[a, b] = size(A1);
figure(31); clf; i=a/2;
subplot(2,1,1)
plot(A1(i,:),z_phc,A2(i,:),z_phc,'linewidth',2); set(gca,'YDir','reverse');
subplot(2,1,2)
plot(reshape(A1,a*b,1),reshape(A2,a*b,1),'.'); axis([0 1 0 1]*4e-3);

i = 480;
Ca_sat = ksp./CO3(H);
subplot(3,1,1)
plot(Ca_sat(i,:),z_phc,pCa(i,:),z_phc,'linewidth',2); set(gca,'YDir','reverse');
subplot(3,1,2)
plot(pNa(i,:),z_phc,pCa(i,:),z_phc,'linewidth',2); set(gca,'YDir','reverse');
legend({'Na','Ca'})
subplot(3,1,3)
plot(ppH(i,:),z_phc,'linewidth',2); set(gca,'YDir','reverse');
legend({'pH'})

%%

alk0 = pH2Alk(ones(size(CO2))*pH0,CO2)
alk = alk0 + 2*pCa + 2*pMg + pK + pNa

alk2pH(alk*0+1000,alk)





%%
imin = 1;
Delt = time_step/3600/24/365;

% Calculation R for phreaqC
METHOD = 'spline';

SAvsVol_SA  = SA_org/params.rho(imin);
SAvsVol_vol = vol_org;

B_total = mass*params.mf(imin);
B_depth = depth;
SAvsVol_con = SAvsVol_vol/B_depth*B_total;
SAvsVol_SA  = SAvsVol_SA/B_depth*B_total;

w = m2k(comp_k(pH,tmp,params),params.mol_mass);

RV = []; w = [];
for i=1:size(CV,2)
  B = BV(:,i);
  SA = interp1(SAvsVol_con,SAvsVol_SA,B,METHOD,'extrap');
  for j=1:15
    pH = outputpH(i,j);
    w(j,:) = m2k(comp_k(pH,tmp,params),params.mol_mass);
  end

%  RR = w(imin)*SA;
  RR = w(:,imin).*SA;
  RV = [RV,RR];
end

%%
figure(61)
for i=1:length(params.names)
  subplot(3,2,i)
  plot(t_simple,B_tots_simple(i,:),'-k',t_rtm,B_tots_rtm(i,:),'-r','linewidth',2)
  ylim([0 2]); title(params.names(i)); grid;
end


%%

figure('position',[0 0 600 1000]); clf;
axis([0 15 0 depth]); set(gca,'YDir','reverse','fontsize',12,'box','on');
bcol = [.40 .25 .15];
scol = [.1 .1 .8];
ocol = [.4 .4 .4];

CV(:,1) = CV(:,1)*0;
count = 0;
%for i=1:17:52
for i=1:80:321
  zz = [0;0;reshape([z,z]',2*length(z),1)];
  CC = [0;reshape([CV(:,i),CV(:,i)]',2*length(CV(:,i)),1);0];
  BB = [0;reshape([BV(:,i),BV(:,i)]',2*length(BV(:,i)),1);0];

  count = count + 1;
  subplot(5,2,2*count-1)
  axis([0 5 0 depth*100]); set(gca,'YDir','reverse','fontsize',12,'box','on');
  p1 = patch(CC,zz*100,scol);
  if (count == 1); title('Solution'); end
  if (count == 5); xlabel('Con. (kg/m^3)'); end
  ylabel('Depth (cm)');
  subplot(5,2,2*count)
  axis([0 15 0 depth*100]); set(gca,'YDir','reverse','fontsize',12,'box','on','Yticklabel',{});
  p1 = patch(BB,zz*100,bcol);
  if (count == 1); title('Soil'); end
  if (count == 5); xlabel('Con. (kg/m^3)'); end
end

