function [Ca_sat,pH,Ca_precip,Ca_sol]=solution2pH(C_t,Ca_precip,params,phi,pH0,CO2,alk2pH,CaSat)

C_t_molperl = C_t./params.mol_mass'/phi;

Ca = C_t_molperl.*params.elements.Ca'; Ca = squeeze(sum(Ca,1))';
Mg = C_t_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1))';
K  = C_t_molperl.*params.elements.K';  K  = squeeze(sum(K ,1))';
Na = C_t_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1))';

pHmin = 1; pHmax = 13; 
Amid = 0;
a = pHmax - pHmin;
b = -26.6/1000;

% Calculate baseline/rainwater alkalinity
alk0 = Amid + b*log((a - pH0 + pHmin)./(pH0 - pHmin));


% Compute Ca precipitation
delAlk = alk0 + 2*Mg + K + Na;

%Ca_sat = CaSat(CO2+delAlk*0,delAlk);
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

Ca = Ca + Ca_precip;
Ca_sol = min(Ca_sat,Ca);
Ca_precip = max(Ca - Ca_sat,0);

% Calculate pH
alk = alk0 + 2*Ca_sol + 2*Mg + K + Na;
%pH = alk2pH(CO2+alk*0,alk);
alk = alk0;

pHmin = 1; pHmax = 13; 
Amid = 0;
a = pHmax - pHmin;
b = -26.6/1000;
pH = pHmin + a./(1+exp((alk - Amid)/b));

