function [Ca,Mg,K,Na] = Ca_del(delB,params)

% Moles of basalt per litre.
C_t_molperl = delB./params.mol_mass';

Ca = C_t_molperl.*params.elements.Ca'; Ca = squeeze(sum(Ca,1))';
Mg = C_t_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1))';
K  = C_t_molperl.*params.elements.K';  K  = squeeze(sum(K, 1))';
Na = C_t_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1))';
