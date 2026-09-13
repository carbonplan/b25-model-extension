function [PB,alk_new,H_sol_new,C_new,B_new,pH_new,Ca_sol_new,Ca_precip_new,Ca_sat_new,Cf_new,RR_new, ...
 outflow_new,outflowCa_new,outflowH_new,swvf_new,z,t,Delz,Delt,profiles,tolerences, ...
 q_eff_new] = ...
fd15(data,run_params,fd_params,params,basalt,eq_phase,rad0,mfd0, ...
 enhancement,SAvsVol_SA_org,SAvsVol_vol_org,soil_CO2_org, ...
 alk2pH,pH2Alk,CaSat,alk0,Ceq_override,regularGrid,verbose)

t = 0;

%% Set up particles

path('./PSD',path);
path('./PSD/PSD_data',path);

global PSD_data
PSD_get('Cragmill');

reps = run_params.reps;
depth_range = [0, run_params.basalt_depth]; delZ = fd_params.Delz;
z = linspace(depth_range(1),depth_range(2),depth_range(2)/delZ+1)';

if strcmp(fd_params.test,'no')
  P = PSD_data.P_opt;
else
  P = make_particles([100 150 200]*1e-6,[5 3 2]);
end

vf = params.mf./params.rho; vf = vf/sum(vf);
rho = params.rho;
minerals = params.names;

PB = PSD_make_basalt(run_params.b_mass,P,reps,z,vf,rho,minerals);
PB_add = PB;

PB.lambda.fd = .33;
PB.lambda.alpha = 1e-10;
PB.lambda.beta = 1;
PB.lambda.constant = 1;
PB.lambda.method = 'const';

%%

if strcmp(run_params.acidifier,'yes')
  if run_params.woody==1  
    yieldV = data.npp;
  else
    yieldV = data.yield;
  end
else
  yieldV = data.yield*0;
end

apatite_inhibiter = run_params.apatite_inhibiter;
fd      = run_params.fd;
B_depth = run_params.depth;
mass    = run_params.b_mass;
phi     = run_params.wfp;
q       = run_params.flowrate;
tf      = run_params.tf;
Delz    = fd_params.Delz;
pH_base = run_params.pH0;

spinup_length = fd_params.spinup_length;
spinup_steps = fd_params.spinup_steps;
spinup_power = fd_params.spinup_power;
%del_min_ts = spinup_length/spinup_power^spinup_steps;
del_min_ts = 1/365/24/3600;

nmins = length(params.names);

METHOD = 'linear';

Delt = del_min_ts;

p = round(B_depth/Delz+1);
z = [0:Delz:(p-1)*Delz]';

C_t = []; B_t = []; Cf_t = []; R_t = []; 
outflow_t = []; swvf_t = [];

Ca_precip = zeros(length(z),1);
[Ca_sat,pH,Ca_precip,Ca_sol] = solution2pH(zeros(nmins,length(z)),Ca_precip,params,phi,pH_base,soil_CO2_org,alk2pH,CaSat);

[tmp,q,npp,acidifier_source] = calc_drivers(data,t,yieldV);

basalt_name = basalt;

if isempty(Ceq_override)
  Ceq = Ceq_comp(params,tmp,q,basalt_name,run_params.affinity,eq_phase);
else
  Ceq = Ceq_override;
end

w = [];
if strcmp(fd_params.test,'yes')
  for i=1:length(pH)
    w(:,i) = 50e-6*params.rho;
  end 
else
  for i=1:length(pH)
    w(:,i) = m2k(comp_k(pH(i),tmp(i),params),params.mol_mass)';
  end
  w = w*enhancement;
end

B_total = mass*params.mf;
for imin=1:length(params.names)
%  if ~strcmp(params.names{imin},'Apatite')
    B_init = ones(p,1);
    ii = find(z>B_depth); B_init(ii) = 0;
    B_init = B_init/trapz(z,B_init)*B_total(imin);
    B(imin,:) = B_init;
    C(imin,:) = zeros(p,1);
    SA = interp1(SAvsVol_vol_org/B_depth*B_total(imin),SAvsVol_SA_org/params.rho(imin)/B_depth*B_total(imin),B(imin,:),METHOD,'extrap');
  
    RR(imin,:) = SA.*w(imin,:);
    Cf(imin,:) = Ceq(:,imin).*(1-exp(-RR(imin,:)'.*z./(q*Ceq(:,imin))));
    ii = find(Cf(imin,:) == 0); Cf(imin,ii) = NaN;
    Cf_max(imin) = max(Cf(imin,:),[],2);
%  end
end

B_0 = B;
%pH_init = pH_base*ones(p,1);
pH_init = pH_base;
pH = pH_init;

outflow = zeros(nmins,1);
outflowCa = 0;
outflowH = 0;
outflowMg = 0;
outflowK = 0;
outflowNa = 0;
maxiters = 1e6;

B_all(:,:,1) = B; C_all(:,:,1) = C; RR_all(:,:,1) = RR;
Cf_all = Cf; t_all = 0; outflow_all = []; B_mass_all = [];
Ca_sol_all(:,1)    = zeros(length(z),1);
Ca_precip_all(:,1) = zeros(length(z),1);
Ca_sat_all = zeros(length(z),1);
outflowCa_all = [];
outflowH_all = [];
outflowMg_all = [];
outflowK_all  = [];
outflowNa_all = [];
%pH_all = ones(length(z),1)*pH_base;
pH_all = pH_base;
alk_all(:,:,1) = zeros(9,size(B,2));

%pH(:,1) = ones(length(z),1)*pH_base;
pH(:,1) = pH_base;

Ca_precip = zeros(length(z),1);
Ca_sol    = zeros(length(z),1);
H_sol     = zeros(length(z),1);
acid_sol  = zeros(length(z),1);

Mg_sol = zeros(length(z),1);
K_sol  = zeros(length(z),1);
Na_sol = zeros(length(z),1);

swvf = run_params.depth*run_params.wfp;
swvf_all(1) = swvf;
%% ---- ADDITION (beerling-2025-model-extension) ------------------------------------
% Record the EFFECTIVE q -- the post-bucket flux that actually advects solutes
% and carries the export (fd15.m:492-496). calc_drivers returns raw infiltration;
% the bucket block below overwrites q with bucket_dampner whenever the column is
% under field capacity, so raw infiltration is NOT what the transport sees. There
% was no way to recover it from the saved outputs.
%
% Index 1 is t=0, before any step has been taken, so there is no q for it yet; it
% is backfilled from index 2 after the loop rather than left at 0, which would put
% a spurious zero into the interpolation near t=0.
q_eff_all(1) = NaN;

% tolerences is output #21 and upstream only ever assigns it inside conditional
% branches (lines 502-512), so on a run where none fire it stays undefined and any
% caller requesting output >20 dies with 'output argument not assigned'. Since
% q_eff_new is #22, initialising it here is what makes the new output requestable.
% Assigning [] is harmless: the indexed assignments later grow it as before.
tolerences = [];
%% ------------------------------------------------------------------------

SA0 = [];
VOL0 = [];
T0 = [];

for imin=1:length(params.names)
  [SA,VOL,T] = SA_VOL_2(rad0,mfd0,mass,params.rho(imin),fd,fd_params.SA_VOL_bins);
  SA0(imin,:) = SA;
  VOL0(imin,:) = VOL;
  T0(imin,:) = T;
end

profiles = [];
for imin=1:length(params.names)
  for iz=1:p
    profiles(imin,iz).VOL = VOL0(imin,:);
    profiles(imin,iz).SA = SA0(imin,:);
    profiles(imin,iz).T = T0(imin,:);
    profiles(imin,iz).mfd0 = mfd0;
    profiles(imin,iz).rad0 = rad0;
  end
end

iter = 0;
iter_yearly = 0;
while (max(max(C(:,:)))>1e-6 || max(Ca_sol(:,:))>1e-6 || max(max(B(:,:)))>1e-6) && t<tf && iter<maxiters

  Delt_tmp = Delt;
  t_old = t;

  iter = iter + 1;
  iter_yearly = iter_yearly + 1;
  if t+Delt > floor(t + 1)
    Delt = floor(t + 1) - t;
    newYear = 1;
  else
    newYear = 0;
  end

  t = t + Delt;

% Set driving data
  [tmp,q,npp,yield,soilresp,CO2_air] = calc_drivers(data,t,yieldV);

%  alk_acid = carbon2alk(run_params.soy,yield,phi,run_params.flowrate,B_depth,Delz);
  alk_acid = acid_sol;

  soil_CO2 = co2_profile(run_params.depth,fd_params.Delz, ...
  run_params.rooting_depth,CO2_air,soilresp,0)*1e6;

  if isempty(Ceq_override)
    Ceq = Ceq_comp2(params,tmp,q,basalt_name,run_params.affinity,eq_phase);
  else
    Ceq = tmp*0 + Ceq_override;
  end
  Ceq = Ceq/(1 - run_params.Ceq_dampner);

%  Ceq(:,1) = 0.1;
%  Ceq = Ceq*0 + 10;

% Accounting for soil water content by adjusting flow rate
  soil_volume_capacity     = run_params.depth*run_params.wfp;
  soil_volume_capacity_min = run_params.depth*run_params.wfp_min;
  if q < 0
    swvf_new = max(swvf + q*Delt,soil_volume_capacity_min);
    q = run_params.bucket_dampner;
  else
    if swvf + q*Delt < soil_volume_capacity
      swvf_new = swvf + q*Delt;
      q = run_params.bucket_dampner;        
    else
      q = (q*Delt - (soil_volume_capacity - swvf))/Delt;
      swvf_new = soil_volume_capacity;
    end
  end

%  disp([soil_volume_capacity,swvf_new,swvf]);

%  [pH,Ca_precip_new,Ca_sol] = solution2pH(C,Ca_precip,params,phi,pH_base,alk2pH,CaSat);
  w = zeros(length(params.rho),p);
  if  strcmp(fd_params.test,'yes')
    for i=1:length(pH)
      w(:,i) = 50e-6*params.rho;
    end 
  else
    for i=1:length(pH)
      w(:,i) = m2k(comp_k(pH(i),tmp(i),params),params.mol_mass)';
%      w(:,i) = min(m2k(comp_k(pH(i),tmp,params),params.mol_mass)',.1);
    end
    w = w*run_params.lambda*comp_npp_enhancement( ...
 npp2nppnorm(npp,run_params.nppnormscale),run_params.woody);
  end

  alpha = fd_params.min_alpha; beta = fd_params.min_beta; Diff = fd_params.min_Diff;
  
  C_new  = zeros(length(params.names),p);
  B_new  = zeros(length(params.names),p);
  RR_new = zeros(length(params.names),p);
  Cf_new = zeros(length(params.names),p);
  delB   = zeros(length(params.names),p);

% weather particles
  wP = w'./params.rho;
  imin = 1;
  C0 = C(imin,:)';
  RR0 = RR(imin,:)';

%  Ceq = Ceq*0 + 30000;
%  if (strcmp(run_params.affinity,'yes'))
  wP = wP.*max(0,max(0,(1 - C'./Ceq)));
    
%  wP(1:3,8)'
%return

%  end
%  wP = wP.*max(0,RR0.*max(0,(1 - C0/Ceq(imin))));
%  wP = repmat(wP,length(z)-1,1);
  
  [PB_new,MW,SA,MB] = PSD_weather_discrete_basalt(PB,Delt,wP,z);
  if strcmp(run_params.transport,'yes')
    PB_new = PSD_transport_basalt(PB_new,Delt,z(end));
  end
  SAP = SA.*params.mf/delZ;
%
  for imin=1:length(params.names)

    Mp = MB(:,imin)/delZ;
    Mp = [3*Mp(1) - Mp(2);(Mp(2:end) + Mp(1:end-1));3*Mp(end) - Mp(end-1)]/2;
    SAp = SAP(:,imin);
    SAp = [3*SAp(1) - SAp(2);(SAp(2:end) + SAp(1:end-1));3*SAp(end) - SAp(end-1)]/2;
    
    if ~strcmp(params.names{imin},'Apatite') || strcmp(apatite_inhibiter,'no')
%&& strcmp(params.apatite_inhibiter,'yes')
      C0 = C(imin,:)';
      B0 = B(imin,:)';
      RR0 = RR(imin,:)';
    
      Ct = C0;
      Bt = B0;
      RRt = RR0;
      
%%  
      for iBC=1:fd_params.BC_iter
        Ct = findiff(C0,p,Delz,Delt,q,phi,Ceq(:,imin),(RR0+RRt)/2,alpha,beta,Diff); 
        ii = Ct<0; Ct(ii) = 0;

%        Bt = B0 - Delt*((RR0.*max(0,(1 - C0/Ceq(imin))) + RRt.*max(0,(1 - Ct/Ceq(imin)))))/2;
%        Bt = B0 - Delt*(((RR0+RRt)/2.*(1 - (C0+Ct)/2/Ceq(imin))));   ii = Bt<0; Bt(ii) = 0;

        if strcmp(run_params.model_P_or_C,'C')
          ii = find(C0./Ceq(:,imin) < 1);
          Bt(ii) = B0(ii) - Delt*((RR0(ii).*max(0,(1 - C0(ii)./Ceq(ii,imin))) + RRt(ii).*max(0,(1 - Ct(ii)./Ceq(ii,imin)))))/2;
%          Bt(ii) = B0(ii) - Delt*((RR0(ii).*(1 - min(1,C0(ii)./Ceq(ii,imin))) + RRt(ii).*(1 - min(1,Ct(ii)./Ceq(ii,imin)))))/2;
          ii = Bt<0; Bt(ii) = 0;

          SA = zeros(p,1);
          for iz=1:p
            VOL_MRL = profiles(imin,iz).VOL;
            SA_MRL = profiles(imin,iz).SA;
            volume = (Bt(iz)+B0(iz))/2*B_depth/params.rho(imin)/params.mf(imin);
            SA(iz,1) = params.mf(imin)/B_depth*interp1_MRL(VOL_MRL,SA_MRL,volume,METHOD,'extrap');
          end
          RRt = w(imin,:)'.*SA;
          Mp = Bt;
        else
          RRt = w(imin,:)'.*SAp;
        end
      end
      
%      [SA,SAp]
%      [Bt,Mp]
      Bt = Mp;

%%
%    Ct = findiff(C0,p,Delz,Delt,q,phi,Ceq(imin),(RR0+RRt)/2,alpha,beta,Diff); ii = Ct<0; Ct(ii) = 0;
%    Bt = B0 - Delt*((RR0.*(1 - C0/Ceq(imin)) + RRt.*(1 - Ct/Ceq(imin))))/2; ii = Bt<0; Bt(ii) = 0;
 
%    VOL_MRL = []; SA_MRL = []; SA = [];
%    for iz=1:p
%      VOL_MRL = profiles(imin,iz).VOL;
%      SA_MRL = profiles(imin,iz).SA;
%      volume = Bt(iz)*B_depth/params.rho(imin)/params.mf(imin);
%      SA(iz,1) = params.mf(imin)/B_depth*interp1_MRL(VOL_MRL,SA_MRL,volume,METHOD,'extrap');
%    end
%    SA = interp1(SAvsVol_vol_org/B_depth*B_total(imin),SAvsVol_SA_org/params.rho(imin)/B_depth*B_total(imin),Bt,METHOD,'extrap');
%    RRt = w(imin,:)'.*SA;
%%
%    Ct = findiff(C0,p,Delz,Delt,q,phi,Ceq(imin),(RRt+RR0)/2,alpha,beta,Diff); ii = Ct<0; Ct(ii) = 0;
%    Bt = B0 - Delt*((RR0.*(1 - C0/Ceq(imin)) + (RRt.*(1 - Ct/Ceq(imin)))))/2; ii = Bt<0; Bt(ii) = 0;
%    SA = interp1(SAvsVol_vol_org/B_depth*B_total(imin),SAvsVol_SA_org/params.rho(imin)/B_depth*B_total(imin),Bt,METHOD,'extrap');
%    RRt = w(imin,:)'.*SA;
%%
      Cft = Ceq(:,imin).*(1-exp(-RRt.*z./(q*Ceq(:,imin))));
  
    else
% Appetite dynamics when appetite inhibitor is switched on
      C0 = C(imin,:)';
      B0 = B(imin,:)';
      RR0 = RR(imin,:)';
    
      Ct = C0;
      RRt = RR0;
 
      B_vol = (B_new(1:imin-1,:)'./params.rho(1:imin-1))'*Delz;
      B_vol = sum(B_vol,1)';
      Vap = params.vf0(end)*B_vol/(1 - params.vf0(end));
      Bt = Vap*params.rho(end)/Delz;

    end
    C_new(imin,:) = Ct;
    B_new(imin,:) = Bt;
    RR_new(imin,:) = RRt;
    Cf_new(imin,:) = Cft;

    delB(imin,:) = B0 - Bt;
    
%    delB'
%    MW/delZ
%    error('doh')
    
  end

%----------------------------------------------
% Acidifier dynamics
%----------------------------------------------
% Compute acidifier source rate in terms of alkalinity.
  [~, del_acid] = carbon2alk(run_params.soy,yield,phi,run_params.flowrate,B_depth,Delz,run_params.rooting_depth);
  alpha = fd_params.H_alpha; beta = fd_params.H_beta; Diff = fd_params.H_Diff;
  acid_sol_new = findiff(acid_sol,p,Delz,Delt,q,phi,[],del_acid,alpha,beta,Diff);

%----------------------------------------------
% H+ dynamics
%----------------------------------------------
% Compute H+ source rate (read from LCM data at the mo)
  del_H = H_del(data,t,run_params);

  alpha = fd_params.H_alpha; beta = fd_params.H_beta; Diff = fd_params.H_Diff;
  H_sol_new = findiff(H_sol,p,Delz,Delt,q,phi,[],del_H,alpha,beta,Diff);

%----------------------------------------------
% Ca dynamics
%----------------------------------------------

  [Ca_sat_new,Mg_sol_new,K_sol_new,Na_sol_new] = ...
 solution2CaSat(alk0,alk_acid,H_sol_new,C_new,params,phi,pH_base,soil_CO2,alk2pH,pH2Alk,CaSat);
  
% Compute Ca source rate from weathering of basalt.
  del_Ca = Ca_del(delB,params);

  Ca_total = Ca_sol + Ca_precip;
  Ca_sol_new = min(Ca_sat_new,Ca_total);
  Ca_precip_new = max(Ca_total - Ca_sat_new,0);
  
  alpha = fd_params.Ca_alpha; beta = fd_params.Ca_beta; Diff = fd_params.Ca_Diff;
  Ca_tmp = findiff(Ca_sol_new,p,Delz,Delt,q,phi,[],del_Ca/Delt,alpha,beta,Diff);
  
  Ca_total = Ca_tmp + Ca_precip_new;
  Ca_sol_new = min(Ca_sat_new,Ca_total);
  Ca_precip_new = max(Ca_total - Ca_sat_new,0);
  Ca_sol_new = Ca_sol_fix_negative(Ca_sol_new);
  
%----------------------------------------------
% H+ dynamics
%----------------------------------------------
% Compute H+ source rate (read from LCM data at the mo)
%  del_H = H_del(data,t,run_params);
%del_H
%  alpha = fd_params.H_alpha; beta = fd_params.H_beta; Diff = fd_params.H_Diff;
%  H_sol_new = findiff(H_sol,p,Delz,Delt,q,phi,1e20,del_H,alpha,beta,Diff);

%----------------------------------------------
% Compute pH
%----------------------------------------------
  
  [pH_new,alk_new] = calc_pH(params,run_params,alk_acid,H_sol_new,C_new,Ca_sol_new,phi,pH_base,soil_CO2,alk0,alk2pH,pH2Alk);
%  pH_new = zeros(p,1) + pH_base;

%  pH_new = min(pH_new,11)*0+7;
  pH_new = min(pH_new,11);

%  pH_new = max(pH_new,3);
%----------------------------------------------

%  Omega = Ca_sat_index(soil_CO2,Ca_sol_new,pH_new);
  
%----------------------------------------------
% Compute time-step and update new variables where appropriate
%----------------------------------------------
  
  limC  = fd_params.min_tol;
  limCa = fd_params.Ca_tol;
  limH_sol  = fd_params.H_tol;
  
  if t-floor(t)<spinup_length
    Delt_min = min(del_min_ts*spinup_power^iter_yearly,fd_params.min_Delt);
  else
    Delt_min = fd_params.min_Delt;
  end

  if (iter_yearly > spinup_steps) && (Delt > Delt_min) && ...
 (max(max(abs(C_new-C),[],2))> limC || ... 
  max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)) > limCa || ...
  max(abs(H_sol_new - H_sol)) > limH_sol)
%    'oh no'
%        fprintf('%4d %0.4f %0.6f %0.3f %0.3f %0.5f\n',iter_yearly,t,Delt, ...
%        max(max(abs(C_new-C),[],2)), ...
%        max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)), ...
%        max(abs(H_sol_new - H_sol)));
%    iter_yearly > spinup_steps
%    Delt > Delt_min
%  max(max(abs(C_new-C),[],2))> limC
%  max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)) > limCa
%  max(abs(H_sol_new - H_sol)) > limH_sol

% Gradients too big, ingnore calculations and wind the clock back.
    if verbose
      disp('failure winding back and decreasing delt')
      fprintf('wnd %4d %0.4f %0.6f %0.3f %0.3f %0.5f\n',iter_yearly,t,Delt, ...
 max(max(abs(C_new-C),[],2)), ...
 max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)), ...
 max(abs(H_sol_new - H_sol)));
    end
    iter = iter - 1;
    iter_yearly = iter_yearly - 1;
    t = t - Delt;
    Delt = max(Delt/3.1,Delt_min);
  else
% Succesful time step iteration.

    outflow   = outflow   + (C(:,end)      + C_new(:,end))     /2*q*Delt;
% Need to multiply flow by 1000 as Ca is in mols per litre which is 
% effectively mols per mm per m^2 and flow is in m.
    outflowCa = outflowCa + (Ca_sol(end)   + Ca_sol_new(end))  /2*q*Delt*1000;
    outflowH  = outflowH  + (H_sol(end)    + H_sol_new(end))   /2*q*Delt*1000;
%    outflowMg = outflowMg + (Mg_sol(end)   + Mg_sol_new(end))  /2*q*Delt*1000;
%    outflowK  = outflowK  + ( K_sol(end)   +  K_sol_new(end))  /2*q*Delt*1000;
%    outflowNa = outflowNa + (Na_sol(end)   + Na_sol_new(end))  /2*q*Delt*1000;
    
    if (iter_yearly < spinup_steps)
      tolerences(1,iter,1) = max(max(abs(C_new-C),[],2));
      tolerences(1,iter,2) = max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip));
      tolerences(1,iter,3) = max(abs(H_sol_new - H_sol));
    elseif (iter_yearly > spinup_steps) && (Delt > Delt_min)
      tolerences(2,iter,1) = max(max(abs(C_new-C),[],2));
      tolerences(2,iter,2) = max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip));
      tolerences(2,iter,3) = max(abs(H_sol_new - H_sol));
    elseif (iter_yearly > spinup_steps) && (Delt == Delt_min)
      tolerences(3,iter,1) = max(max(abs(C_new-C),[],2));
      tolerences(3,iter,2) = max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip));
      tolerences(3,iter,3) = max(abs(H_sol_new - H_sol));
    end

    if max(max(abs(C_new-C),[],2)) > limC/2 || ...
 max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)) > limCa/2 ...
 || max(abs(H_sol_new - H_sol)) > limH_sol/2
      if verbose
        fprintf('dec %4d %0.3f %0.4f %0.3f %0.4f %0.4f\n',iter_yearly,t,Delt, ...
 max(max(abs(C_new-C),[],2)), ...
 max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)), ...
 max(abs(H_sol_new - H_sol)));
      end
      Delt = max(Delt*0.9,Delt_min);
    else
      if verbose
        fprintf('inc %4d %0.3f %0.4f %0.3f %0.4f %0.4f\n',iter_yearly,t,Delt, ...
 max(max(abs(C_new-C),[],2)), ...
 max(abs(Ca_sol_new + Ca_precip_new - Ca_sol - Ca_precip)), ...
 max(abs(H_sol_new - H_sol)));
      end
      Delt = min(Delt*2,fd_params.max_Delt);
    end

    if (newYear) && (t<tf)
      if strcmp(run_params.model_P_or_C,'C')
      for imin=1:length(params.names)
        Bt = B(imin,:)';
        for iz=1:p
          VOL_MRL = profiles(imin,iz).VOL;
          T_MRL = profiles(imin,iz).T;
          rad1 = profiles(imin,iz).rad0;
          mfd1 = profiles(imin,iz).mfd0;
          mass1 = Bt(iz)*B_depth/params.mf(imin);
          volume = Bt(iz)*B_depth/params.rho(imin)/params.mf(imin);

          T_star = interp1_MRL(VOL_MRL,T_MRL,volume,METHOD,'extrap');

          if isnan(T_star)
            save
            error('T_star is NaN')
          end
        
          [rad1,mfd1,mass1] = get_pdf_donkey(T_star,rad1,mfd1,mass1,params.rho(imin),fd,0);
          [rad2,mfd2,mass2] = add_pdfs(rad1,mfd1,mass1,rad0,mfd0,mass);

          [SA,VOL,T] = SA_VOL_2(rad2,mfd2,mass2,params.rho(imin),fd,fd_params.SA_VOL_bins);
          profiles(imin,iz).VOL = VOL;
          profiles(imin,iz).SA = SA;
          profiles(imin,iz).T = T;
          profiles(imin,iz).rad0 = rad2;
          profiles(imin,iz).mfd0 = mfd2;
        end
      end
      end
      Delt = del_min_ts;
      iter_yearly = 0;
    end
    
    C  = C_new;
    B  = B_new;
    PB = PB_new;
    RR = RR_new;
    Cf = Cf_new;
    Ca_sat = Ca_sat_new;
    Ca_sol = Ca_sol_new;
    H_sol  = H_sol_new;
    acid_sol = acid_sol_new;
 %   Mg_sol = Mg_sol_new;
 %   K_sol  =  K_sol_new;
 %   Na_sol = Na_sol_new;
    Ca_precip = Ca_precip_new;
    pH = pH_new;
    alk = alk_new;
    swvf = swvf_new;

    t_all                   = [t_all,t];
    B_all(:,:,iter+1)       = B;
    C_all(:,:,iter+1)       = C;
    RR_all(:,:,iter+1)      = RR;
    Cf_all(:,:,iter+1)      = Cf;
    Ca_sat_all(:,iter+1)    = Ca_sat;
    outflow_all(:,iter+1)   = outflow;
    outflowCa_all(1,iter+1) = outflowCa;
    outflowH_all(1,iter+1)  = outflowH;
    outflowMg_all(1,iter+1) = outflowMg;
    outflowK_all(1,iter+1)  = outflowK;
    outflowNa_all(1,iter+1) = outflowNa;
    Ca_precip_all(:,iter+1) = Ca_precip;
    Ca_sol_all(:,iter+1)    = Ca_sol;
    H_sol_all(:,iter+1)     = H_sol;
    acid_sol_all(:,iter+1)  = acid_sol;
%    Mg_sol_all(:,iter+1)    = Mg_sol;
%    K_sol_all(:,iter+1)     = K_sol;
%    Na_sol_all(:,iter+1)    = Na_sol;
    pH_all(:,iter+1)        = pH;
    alk_all(:,:,iter+1)     = alk;
    swvf_all(1,iter+1)       = swvf;
    q_eff_all(1,iter+1)      = q;   % ADDITION: post-bucket effective flux, m/yr
    
    if (newYear) && (t<tf)
      B = B + B_0;
      if strcmp(run_params.model_P_or_C,'P')
        PB.r = [PB.r; PB_add.r];
        PB.n = [PB.n; PB_add.n];
        size(PB.sa)
        size(PB_add.sa)
%        PB.sa = [PB.sa;PB_add.sa];
%        PB.v = [PB.v;PB_add.v];
        PB.depth = [PB.depth; PB_add.depth];      
      end
    end
  end
end

if regularGrid>0
  t = linspace(0,tf,tf*regularGrid+1);
  [a b c] = size(C_all);

  C_new  = zeros(a,b,length(t));
  B_new  = zeros(a,b,length(t));
  Cf_new = zeros(a,b,length(t));
  RR_new = zeros(a,b,length(t));
  outflow_new   = zeros(a,length(t));
  outflowCa_new = zeros(1,length(t));
  outflowH_new  = zeros(1,length(t));
  outflowMg_new = zeros(a,length(t));
  outflowK_new  = zeros(a,length(t));
  outflowNa_new = zeros(a,length(t));
  Ca_precip_new = zeros(b,length(t));
  Ca_sat_new    = zeros(b,length(t));
  Ca_sol_new    = zeros(b,length(t));
  H_sol_new     = zeros(b,length(t));
  acid_sol_new  = zeros(b,length(t));
  pH_new = zeros(b,length(t));
%  Mg_sol_new = zeros(b,length(t));
%  K_sol_new  = zeros(b,length(t));
%  Na_sol_new = zeros(b,length(t));
  swvf_new = zeros(1,length(t));
  q_eff_new = zeros(1,length(t));   % ADDITION

  alk_new = zeros(9,b,length(t));
  
  METHOD = 'linear';
  for i=1:nmins
    for j=1:b
      B_new(i,j,:)  = interp1(t_all,squeeze(B_all(i,j,:)), t,METHOD,'extrap');
      C_new(i,j,:)  = interp1(t_all,squeeze(C_all(i,j,:)) ,t,METHOD,'extrap');
      Cf_new(i,j,:) = interp1(t_all,squeeze(Cf_all(i,j,:)),t,METHOD,'extrap');
      RR_new(i,j,:) = interp1(t_all,squeeze(RR_all(i,j,:)),t,METHOD,'extrap');
    end
    outflow_new(i,:) = interp1(t_all,outflow_all(i,:),t,METHOD,'extrap');
  end
  
  for i=1:9
    for j=1:b
      alk_new(i,j,:) = interp1(t_all,squeeze(alk_all(i,j,:)) ,t,METHOD,'extrap');
    end
  end
 
  for j=1:b
    Ca_precip_new(j,:) = interp1(t_all,squeeze(Ca_precip_all(j,:)),t,METHOD,'extrap');
    Ca_sat_new(j,:)    = interp1(t_all,squeeze(Ca_sat_all(j,:)),   t,METHOD,'extrap');
    Ca_sol_new(j,:)    = interp1(t_all,squeeze(Ca_sol_all(j,:)),   t,METHOD,'extrap');
    H_sol_new(j,:)     = interp1(t_all,squeeze(H_sol_all(j,:)),    t,METHOD,'extrap');
    acid_sol_new(j,:)  = interp1(t_all,squeeze(acid_sol_all(j,:)), t,METHOD,'extrap');
%    Mg_sol_new(j,:) = interp1(t_all,Mg_sol_all(j,:),t,METHOD,'extrap');
%    K_sol_new(j,:) = interp1(t_all,K_sol_all(j,:),t,METHOD,'extrap');
%    Na_sol_new(j,:) = interp1(t_all,Na_sol_all(j,:),t,METHOD,'extrap');
    pH_new(j,:) = interp1(t_all,squeeze(pH_all(j,:)),t,METHOD,'extrap');
  end

  outflowCa_new(:) = interp1(t_all,outflowCa_all(:),t,METHOD,'extrap');
  outflowH_new(:)  = interp1(t_all,outflowH_all(:), t,METHOD,'extrap');
  swvf_new(:)       = interp1(t_all,swvf_all(:),      t,METHOD,'extrap');
  % ADDITION: backfill index 1 (t=0, no step taken yet) before interpolating.
  if numel(q_eff_all) > 1, q_eff_all(1) = q_eff_all(2); end
  q_eff_new(:)      = interp1(t_all,q_eff_all(:),     t,METHOD,'extrap');
%  outflowMg_new(:) = interp1(t_all,outflowMg_all(:),t,METHOD,'extrap');
%  outflowK_new(:)  = interp1(t_all,outflowK_all(:),t,METHOD,'extrap');
%  outflowNa_new(:) = interp1(t_all,outflowNa_all(:),t,METHOD,'extrap');
else
  t             = t_all;
  B_new         = B_all;   
  C_new         = C_all;   
  Cf_new        = Cf_all;
  Ca_sat_new    = Ca_sat_all;
  RR_new        = RR_all;   
  outflow_new   = outflow_all;
  outflowCa_new = outflowCa_all;
  outflowH_new = outflowH_all;
  outflowMg_new = outflowMg_all;
  outflowK_new  = outflowK_all;
  outflowNa_new = outflowNa_all;
  Ca_precip_new = Ca_precip_all;
  Ca_sol_new    = Ca_sol_all;
  H_sol_new     = H_sol_all;
  acid_sol_new  = acid_sol_all;
%  Mg_sol_new    = Mg_sol_all;
%  K_sol_new     = K_sol_all;
%  Na_sol_new    = Na_sol_all;
  pH_new        = pH_all;
  alk_new       = alk_all;
  swvf_new       = swvf_all;
  if numel(q_eff_all) > 1, q_eff_all(1) = q_eff_all(2); end   % ADDITION
  q_eff_new      = q_eff_all;
end

