function [pH,alk_bits] = calc_pH(params,run_params,alk_acid,N_alk,C_t,Ca_sol,phi,pH0,CO2,alk0,alk2pH,pH2Alk)

if strcmp(run_params.N_alk,'no')
  N_alk = N_alk*0;
end

C_t_molperl = C_t./params.mol_mass';

%Ca = C_t_molperl.*params.elements.Ca'; Ca = squeeze(sum(Ca,1))';
Mg = C_t_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1))';
K  = C_t_molperl.*params.elements.K';  K  = squeeze(sum(K ,1))';
Na = C_t_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1))';

alk = alk0 - alk_acid + 2*Ca_sol + 2*Mg + K + Na + N_alk;
pH = alk2pH(CO2,alk);

alk_bits = [alk,alk0,-alk_acid,N_alk,2*Ca_sol,2*Mg,K,Na,CO2]';
