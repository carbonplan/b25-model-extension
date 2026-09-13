clear
basalts = {
    'Cragmill_Ceq'
    'Middleton_Ceq'
    'Hillhouse_Ceq'
    'Alkali'
    'Tholeiite'
    'Lyla'
    'CRB_1'
    'CRB_2'
    'Labradorite'
    'Labradorite2'
    'Ilmenite'
     };
 eq_phases = {
    ''
    'Kaolinite'
    'Montmorillonite-Ca'
    };
ibasalt =  1;
ieq_phase = 1;

basalt   = basalts{ibasalt};

% alpha is for advection beta is for Diffusion
% 0 is fully forward, 1 is fully backward, 1/2 is Crank-Nicholson
% min is kg/m^3, Ca is mol/litre
fd_params=struct( ...
'Delz',     0.005, ...     
'min_tol',  0.1,        'Ca_tol',  0.01,      'H_tol', 0.001, ...
'min_alpha',0.50,       'min_beta', 0.50,     'min_Diff',1e-4, ...
'Ca_alpha', 0.50,       'Ca_beta',  0.50,     'Ca_Diff', 1e-3, ...
'H_alpha',  0.50,       'H_beta',   0.50,     'H_Diff',  1e-4, ...
'smoother', 'no',       'BC_iter',  1, ...
'SA_VOL_bins',200,      'profile_bins', 200,  'test', 'no', ...
'spinup_length',14/365, 'spinup_steps',50, 'spinup_power', 1.2, ...
'min_Delt', .0005, 'max_Delt', .01);

run_params=struct( ...
'cells',15,          'total_cells',15,    'basalt_cells',15, ...
'affinity', 'yes',   'exchanger',         'yes', ...
'acidifier','yes',   'buffer',            'yes', ...
'N_alk',    'yes',   'apatite_inhibiter', 'yes', ...
'tf',1,              'woody',1,           'nppnormscale', 1000, ...
'tmp',20,            'flowrate',1,        'CO2', 410, ...
'pH0',7.0,           'pH_rain',4.8, ...
'b_mass',40e-1,      'depth',0.15, ...
'p80',50,            'fd',0.33, ...
'yield',600,         'npp',1000, ...
'wfp',.25,           'wfp_min',.1,        'rooting_depth',.6, ...
'ocean_salinity',35, 'ocean_tmp',17);

run_params.soilresp = 1.5*run_params.npp;
run_params.CO2 = 600;

data.N.Flux = zeros*ones(31,120);

%for ibasalt=1:1

eq_phase = eq_phases{ieq_phase};

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

enhancement = comp_npp_enhancement( ...
 npp2nppnorm(run_params.npp,run_params.nppnormscale),run_params.woody);

basalt_str = char(basalts(ibasalt));
params = set_basalt(basalt_str);

b_mass = run_params.b_mass;
depth = run_params.depth;
wfp = run_params.wfp;
fd = run_params.fd;

[rad0,mfd0] = make_profile([10],[.05],[1],fd_params.profile_bins);
%rad0=rad0'; mfd0=mfd0';
SA_phc = enhancement*3/(params.vf0*params.rho')*trapz(rad0,mfd0.*(10^10*rad0).^run_params.fd./rad0)/1000;
[SA_org, vol_org] = SA_vs_Vol_9(rad0,mfd0,run_params.fd,0);

Ceq_tmp_range      = [ 10,  15,  20,  25,  30];
Ceq_flowrate_range = [.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0];

options = optimoptions('fmincon', ...
  'OptimalityTolerance',1e-5, ...
  'UseParallel',1, ...
  'Display','iter' ...
);

Ceq_table.values   = 1e10*ones(length(Ceq_tmp_range),length(Ceq_flowrate_range),length(params.names));
Ceq_table.tmp      = Ceq_tmp_range;
Ceq_table.flowrate = Ceq_flowrate_range;
Ceq_table.info     = 'values(tmp,flowrate,mineral)';


%for itmp=1:length(Ceq_tmp_range)
%  for iflowrate=1:length(Ceq_flowrate_range)
    itmp = 3; iflowrate = 3;
    disp([itmp,iflowrate]);
    tmp = Ceq_tmp_range(itmp); flowrate = Ceq_flowrate_range(iflowrate);

    run_params.tmp = tmp;       run_params.flow_rate = flowrate;
    data.tmp = tmp*ones(120,1); data.flow_rate = flowrate*ones(120,1);
  
    [~,~,~,~,B_rtm,t_rtm,z_rtm] = run_rtm2(run_params,eq_phase, ...
      z,soil_CO2,SA_phc,params,ibasalt,0);
    disp('PhreaqC has completed.');
%%
    B_sim = ...
    run_simple3([],[],data,run_params,fd_params,params, ...
     t_rtm,SA_org,vol_org,rad0,mfd0,soil_CO2,alk2pH, ...
     pH2Alk,CaSat,0);
%% 
    iCeq = find(sum(B_rtm - B_sim,2)/size(B_rtm,2) > 0.01);

    FUN = @(Ceq) sum(sum(abs(run_simple3(iCeq,Ceq,data,run_params,fd_params,params, ...
     t_rtm,SA_org,vol_org,rad0,mfd0,soil_CO2, ...
     basalt_str,alk2pH,pH2Alk,CaSat,0) - B_rtm).^2));
    Ceq0 = ones(1,length(iCeq))*10;
    lb = Ceq0*0; ub = lb + 100;
    [Ceq_X,fval,exitflag] = fmincon(FUN,Ceq0,[],[],[],[],lb,ub,[],options);
    Ceq_table.values(itmp,iflowrate,iCeq) = Ceq_X;
    disp(['Exit flag ',num2str(exitflag)]);
    disp(['Ceq ',num2str(Ceq_X)]);
%  end
%end
if length(eq_phase) == 0;
%  save(['../particle_weathering/Ceqs/Ceq_table_',basalts{ibasalt}],'Ceq_table');
else
%  save(['../particle_weathering/Ceqs/Ceq_table_',basalts{ibasalt},'_',eq_phase],'Ceq_table');
end
%end

%%

B_sim2 = ...
run_simple3(iCeq,Ceq_X,data,run_params,fd_params,params, ...
 t_rtm,SA_org,vol_org,rad0,mfd0,soil_CO2,basalt_str,alk2pH,pH2Alk,CaSat,0);

figure(1)
subplot(2,2,1)
plot(t_rtm,B_rtm,'linewidth',2); title('RTM');
subplot(2,2,2)
plot(t_rtm,B_sim2,'linewidth',2); title('SIM (+Ceq)');
subplot(2,2,3)
plot(t_rtm,B_sim,'linewidth',2); title('SIM (-Ceq)');




%%


iCeq = [1 3];
Ceq = Ceq_X;
    B_sim2 = ...
    run_simple3(iCeq,Ceq,t_rtm,ibasalt,yield,nppnorm,woody,affinity,SA_org,vol_org,tmp,pH0,...
    flowrate,b_mass,tf,fd,rad0,mfd0,params,basalt_str,0);



%%

B_sim1 = ...
    run_simple3([],[],t_rtm,ibasalt,yield,nppnorm,woody,affinity,SA_org,vol_org,tmp,pH,...
    flowrate,b_mass,tf,fd,rad0,mfd0,params,basalt_str,0);

%%
Ceq = Ceq_table.values(4,3,:)

Ceq = Ceq_comp(tmp,flowrate,basalts{ibasalt},affinity);
Ceq(1)


%%
    B_sim3 = ...
    run_simple3([1:length(Ceq)],Ceq,t_rtm,ibasalt,nppnorm,woody,affinity,SA_org,vol_org,tmp,pH,...
    flowrate,b_mass,tf,fd,rad0,mfd0,params,basalt_str,0);


%%
figure(5)
subplot(3,1,1)
plot(t_rtm,B_sim1,'-','linewidth',2); title('Simple');
subplot(3,1,2)
plot(t_rtm,B_sim2,'-','linewidth',2); title('Simple');
subplot(3,1,3)
plot(t_rtm,B_rtm,'-','linewidth',2); title('RTM');
legend(params.names)

%%
plot(t_rtm,B_rtm(3,:),'b-',t_rtm,B_sim1(3,:),'r-',t_rtm,B_sim2(3,:),'g-','linewidth',2); title('RTM');


