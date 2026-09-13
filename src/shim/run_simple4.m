function [pH_avg_sim,alk_sim,CaCO3_sim,RCO2_sim,c2b_ratio,CO2_mass, ...
 Application_Basalt_mass,pH_t,K_mass,P_mass,CO2_mass_outflow,CO2_mass_precip,outElements,totals,t,CDR2,charge_outflow, ...
 B_mass_t]= run_simple4(data,run_params,fd_params,params, ...
 basalt,eq_phase,SA_org,vol_org,rad0,mfd0,soil_CO2,alk2pH,pH2Alk,CaSat,verbose)

depth  = run_params.depth;
wfp    = run_params.wfp;
b_mass = run_params.b_mass;
tf     = run_params.tf;

Delz = fd_params.Delz;
p = round(depth/Delz+1);

nppavg = run_params.npp;
enhancement = comp_npp_enhancement( ...
 npp2nppnorm(nppavg,run_params.nppnormscale),run_params.woody);

phi = wfp;

run_params.pH0 = run_params.pH0 + run_params.add_pH;
% Calculate baseline alkaninity to give rise to constant pH profile
%alk0 = pH2Alk(ones(size(CO2))*pH0,CO2);
alk0 = calc_alk0(data,run_params,fd_params,soil_CO2,pH2Alk,alk2pH);


% Adjust drivers
data.npp = data.npp/sum(data.npp)*(run_params.npp + run_params.add_npp)*size(data.npp,1)/12;
data.tmp = data.tmp + run_params.add_tmp;
%data.flowrate = data.flowrate + run_params.add_flowrate/12;
data.flowrate = adjust_multiplicatively(data.flowrate,run_params.add_flowrate);

% Run simple model
% ADDITION (beerling-2025-model-extension): three more outputs requested. profiles_t and
% tolerences_t (#20, #21) are not wanted for themselves -- they simply have to be
% named to reach q_eff_t at #22. src/shim/fd15.m initialises tolerences for exactly
% this reason; upstream leaves it possibly-unassigned, which would abort the call.
[PB,alk_sim,H_sol_t,C_t,B_t,pH_t,Ca_sol_t,Ca_precip_t, ...
 Ca_sat_t,Cf_t,R_t,outflow_t,outflowCa_t,outflowH_t, ...
 swvf_t,z,t,Delz,Delt,profiles_t,tolerences_t,q_eff_t] = ...
fd15(data,run_params,fd_params,params,basalt,eq_phase,rad0,mfd0, ...
 enhancement,SA_org,vol_org,soil_CO2,alk2pH,pH2Alk,CaSat,alk0,[],100,0);

pH_avg_sim = sum(pH_t,1)/size(pH_t,1);
[totals,CaCO3_sim,RCO2_sim,K_mass,P_mass,Ca_mass_precip, ...
 c2b_ratio,CO2_mass,CO2_mass_precip,CO2_mass_outflow, ...
 Application_Basalt_mass,outElements] = ...
 mass_balance(41,params,fd_params, ...
 run_params,data,t,B_t,C_t,outflow_t,run_params.depth, ...
 Ca_sol_t,Ca_precip_t,outflowCa_t,run_params.wfp, ...
 run_params.b_mass,H_sol_t,outflowH_t,swvf_t,0);

%disp(['c2b ratio = ',num2str(RCO2_sim(end)*100,'%0.6f%%')]);
%disp(['K = ',num2str(K_mass(end)*1000,'%0.2f'),'g/m^2']);
%disp(['P = ',num2str(P_mass(end)*1000,'%0.2f'),'g/m^2']);

%% ---- ADDITION (beerling-2025-model-extension) --------------------------------------
% Surface the carbonate state that upstream computes and then throws away.
%
% fd15 returns Ca_sol_t, Ca_sat_t, Ca_precip_t and the alkalinity budget; this
% function captures all four (line 33) but returns only alk_sim, and mod5 then
% discards even that with a `~`. Without them there is no way to evaluate Omega
% at the model's own state, which beerling-2025-analysis needs for E1 and E2.
%
% WHY THIS GOES IN `totals` RATHER THAN THE SIGNATURE
%   Appending outputs looks tidier but cannot work. CDR2 is declared as output
%   #16 and is NEVER ASSIGNED -- every mention of it in this file is commented
%   out (lines 131-160). Requesting any output past #15 therefore raises
%   'output argument CDR2 not assigned'. `totals` is already returned at
%   position 14 and already flows through mod5 to run_site, so adding fields to
%   it changes no call signature and cannot break a positional call.
%
% Everything here is on fd15's regular output grid (regularGrid=100 -> 100
% steps per simulated year), EXCEPT pH_avg which is the column mean. Note this
% block runs BEFORE the pH_t monthly re-interpolation at the end of this file,
% so diag.pH is the native-resolution profile, not the monthly one mod5 returns.
totals.diag = struct();
totals.diag.grid_note = 'depth x time; time = fd15 regularGrid (100/yr); z in m from surface';
totals.diag.z        = z;              % 31 nodes, 0 to 0.15 m
totals.diag.t        = t;              % years since first application
totals.diag.pH       = pH_t;           % 31 x nt, native grid
totals.diag.pH_avg   = pH_avg_sim;     % 0-15 cm column mean -- run_simple4.m:39,
                                       % the reduction the published pH series uses
totals.diag.Ca_sol   = Ca_sol_t;       % 31 x nt, mol/L dissolved Ca
totals.diag.Ca_sat   = Ca_sat_t;       % 31 x nt, mol/L Ca at calcite saturation
                                       % (the model's buffered ceiling)
totals.diag.Ca_precip= Ca_precip_t;    % 31 x nt, mol/L precipitated Ca (SIC)
totals.diag.H_sol    = H_sol_t;        % 31 x nt, nitrification acidity
totals.diag.q        = q_eff_t;        % 1 x nt, m/yr -- the EFFECTIVE post-bucket
                                       % flux that advects solutes and sets the
                                       % export, NOT raw infiltration. See
                                       % src/shim/fd15.m. Needed by E1 and E2.
% Per-mineral state, nmin x 31 x nt. Upstream computes both, uses them for the mass
% balance, and returns neither. Units follow fd15.m:83 -- 'min is kg/m^3':
%   B  undissolved mineral mass per bulk volume, kg/m^3
%   C  dissolved mineral-equivalent, kg/m^3 == g/L, so C./mol_mass is mol/L
% Mineral order is diag.mineral_names. These are the only route to per-mineral
% dissolution: totals.Basalt/.Solution aggregate to elements and lose which phase
% supplied them.
totals.diag.B        = B_t;
totals.diag.C        = C_t;
% Two soil-CO2 profiles are available and they are NOT the same thing:
%   diag.soil_CO2   static, from co2_profile.m at the SPIN-UP MEAN respiration. This is
%                   the one mod5 passes to calc_alk0, so it is what sets alk0.
%   diag.alk(9,:,:) the profile the chemistry actually saw, rebuilt EVERY timestep at
%                   fd15.m:210 from the instantaneous monthly soilresp. Seasonal swing
%                   is large, so use this one for anything time-resolved.
totals.diag.soil_CO2 = soil_CO2;       % 31 x 1, ppm; spin-up mean (sets alk0)
% alk budget, 9 x 31 x nt. Row order is set by calc_pH.m:18 --
%   [alk, alk0, -alk_acid, N_alk, 2*Ca_sol, 2*Mg, K, Na, CO2]
totals.diag.alk      = alk_sim;
totals.diag.alk_rows = {'alk','alk0','-alk_acid','N_alk','2Ca','2Mg','K','Na','CO2'};
% enough of params/run_params to reconstruct concentrations downstream
totals.diag.mineral_names = params.names;
totals.diag.mol_mass      = params.mol_mass;
totals.diag.mf            = params.mf;
totals.diag.elements      = params.elements;
totals.diag.phi           = run_params.wfp;
totals.diag.depth         = run_params.depth;
totals.diag.b_mass        = run_params.b_mass;
totals.diag.buffer        = run_params.buffer;
%% --------------------------------------------------------------------------

Delz = fd_params.Delz;
p = round(depth/Delz+1);
z = [0:Delz:(p-1)*Delz]';

B_mass_t = []; C_mass_t = []; Ca_mass_t = []; Ca_mass_sol_t = []; Ca_mass_precip_t = [];
nmins = length(params.names);
for i=1:nmins
  for j=1:size(B_t,3)
    B_mass_t(i,j) = trapz(z,squeeze(B_t(i,:,j)));
    C_mass_t(i,j) = trapz(z,squeeze(C_t(i,:,j)));
  end
end

for j=1:length(t)
% times by a thousand as we are integrating mols per litre over meters
% and mols per litre are effectively mols per millimeter per meter squared.
  Ca_mass_sol_t(j) = trapz(z,squeeze(Ca_sol_t(:,j)))*1000*phi;
  Ca_mass_precip_t(j) = trapz(z,squeeze(Ca_precip_t(:,j)))*1000*phi;
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

C_molperl = 1000*outflow_t./params.mol_mass'; % mols per m^2
Ca_O = C_molperl.*params.elements.Ca'; Ca_O = squeeze(sum(Ca_O,1));
Mg_O = C_molperl.*params.elements.Mg'; Mg_O = squeeze(sum(Mg_O,1));
K_O  = C_molperl.*params.elements.K';  K_O  = squeeze(sum(K_O ,1));
Na_O = C_molperl.*params.elements.Na'; Na_O = squeeze(sum(Na_O,1));

totCa = Ca_B + Ca_O + Ca_C*phi;
totMg = Mg_B + Mg_O + Mg_C*phi;
totK  = K_B +  K_O +  K_C*phi;
totNa = Na_B + Na_O + Na_C*phi;

%figure(3)
%plot(t,totCa,t,totMg,t,totK,t,totNa)
%ylim([0 inf])
%legend({'Ca','Mg','K','Na'})

C_molperl = C_t./params.mol_mass';
Mg = C_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1));
K  = C_molperl.*params.elements.K';  K  = squeeze(sum(K ,1));
Na = C_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1));

xx = 1000*(sum(B_mass_t./params.mol_mass'.*params.elements.Ca') + Ca_mass_sol_t*phi + Ca_mass_precip_t*phi + outflowCa_t/1000);
(xx(1) - xx(end))/xx(1)*100;

%figure(1)
%subplot(2,1,1)
%plot(t,xx); ylim([0 inf])
%subplot(2,1,2)
%plot(t,totCa); ylim([0 inf])

%figure(1)
%subplot(3,1,1)
%plot(t,[totCa; totMg; totK; totNa])
%legend({'Ca','Mg','K','Na'})
%subplot(3,1,2)
%plot(t,[Ca_O; Mg_O; Mg_O; Na_O])
%legend({'Ca','Mg','K','Na'})

%%

%CDR1 = .84*(Na_O + K_O + 2*(Mg_O + Ca_O));

%METHOD = 'linear';
%x = ((1:length(data.tmp))-.5)/12;
%CO2_ = interp1(x,data.CO2,t,METHOD,'extrap');

%CDR2 = neta(CO2_,run_params.ocean_salinity,run_params.ocean_tmp).* ...
% (Na_O + K_O + 2*(Mg_O + Ca_mass_sol_t*0 + outflowCa_t)) + Ca_mass_precip_t;
%CO2_mols = CDR2;
%CO2_mols(1) = 0;

%[CDR2; RCO2_sim]

%Application_Basalt_mass = b_mass*1000*floor([t(1:end-1),t(end)-1e-6]+1);

%c2b_ratio = interp1(t,RCO2_sim,(0:1/12:t(end)),'linear');

%CO2_mass = interp1(t,RCO2_sim*44,(0:1/12:t(end)),'linear');
%CO2_mass = interp1(t,CO2_mols*44,(0:1/12:t(end)),'linear');
%CO2_mass_precip  = interp1(t,Ca_mass_precip_t*44,(0:1/12:t(end)),'linear');
%CO2_mass_outflow = CO2_mass - CO2_mass_precip;

%save

%Application_Basalt_mass = interp1(t,Application_Basalt_mass,(0:1/12:t(end)),'linear');
%K_mass = interp1(t,K_mass,(0:1/12:t(end)),'linear');
%P_mass = interp1(t,P_mass,(0:1/12:t(end)),'linear');

%disp(['c2b ratio ',num2str(c2b_ratio*100),'%'])

charge_outflow = Na_O+K_O+Mg_O+outflowCa_t*phi;

%RCO2_sim(1) 
%CDR2(1)

%RCO2_sim = CDR2;

pH_avg = interp1(t,sum(pH_t)/size(pH_t,1),(0:1/12:t(end)),'linear');

pH_t = interp1(t,pH_t',1/24:1/12:t(end)-1/24,'linear')';




