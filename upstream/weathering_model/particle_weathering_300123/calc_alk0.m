function alk0 = calc_alk0(data,run_params,fd_params,soil_CO2,pH2Alk,alk2pH)

soy = run_params.soy;

H = sum(data.N.Flux(1:run_params.spinup*12,:),1)/(run_params.spinup*12);
% not including nitrogen fluxes in the equilibrium calculation
% as highly dependent on fertilizers which we are assuming to be recent
H = H*0;

q = run_params.flowrate/365/24/3600;

z = 0:fd_params.Delz:run_params.depth;
H_eq = zeros(length(z),1);
for i=2:length(H)
  H_eq(i) = trapz(z(1:i),H(1:i));
end
H_eq = H_eq/q;

% convert from gN/m^3 to mol N/m^3
H_eq = H_eq/14/1000;

N_alk = H_eq;

acidifier_source_avg = run_params.yield;

alk_acid = carbon2alk(soy,acidifier_source_avg,run_params.wfp, ...
 run_params.flowrate,run_params.depth,fd_params.Delz,run_params.rooting_depth);

if strcmp(run_params.N_alk,'no')
  N_alk = N_alk*0;
end

alk0 = pH2Alk(run_params.pH0,soil_CO2) + alk_acid - N_alk;

%pH = alk2pH(soil_CO2,alk0 - alk_acid + N_alk');
