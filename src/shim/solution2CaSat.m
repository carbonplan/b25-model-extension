function [Ca_sat,Mg,K,Na]=solution2CaSat(alk0,alk_acid,N_alk,C,params,phi,pH0,CO2,alk2pH,pH2Alk,CaSat)

C_molperl = C./params.mol_mass';

%Ca = C_molperl.*params.elements.Ca'; Ca = squeeze(sum(Ca,1))';
Mg = C_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1))';
K  = C_molperl.*params.elements.K';  K  = squeeze(sum(K ,1))';
Na = C_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1))';

% Calculate effects of baseline/rainwater alkalinity and yield 
%alk0 = pH2Alk(ones(size(CO2))*pH0,CO2) - alk_yield;

%alk0(end)

%Na = .00;
% Compute Ca precipitation
delAlk = alk0 - alk_acid + 2*Mg + K + Na + N_alk;
%delAlk = alk0;

%% ---- OVERRIDE (beerling-2025-model-extension) ------------------------------------
% Upstream branches on `size(CaSat.GridVectors) == 1` to tell a 1-D lookup
% from a 2-D one. GridVectors is a griddedInterpolant property, and our CaSat
% is a plain function handle rebuilt from CaSat*_data.mat (src/shim/mk_interp2d.m),
% which has no such property -- so the test itself would error under Octave.
% Nothing is lost: both CaSat tables the model ships are 2-D (CO2 x delAlk),
% so the `else` branch is the only one ever taken. We call it directly.
%   was:  if size(CaSat.GridVectors) == 1
%           Ca_sat = CaSat(delAlk);
%         else
%           Ca_sat = CaSat(CO2+delAlk*0,delAlk);
%         end
%% ------------------------------------------------------------------------
Ca_sat = CaSat(CO2+delAlk*0,delAlk);
