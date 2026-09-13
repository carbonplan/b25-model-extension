function [parms,mol_lpw_min,sa_prop,lpw_m2,basalt_g_lpw]=calc_phc_params(params,SA,b_mass,depth,wfp)
% kg's and m's ans seconds
%rad = 25e-6;
%b_mass = 4;  % mass of basalt per m^2
%depth = lengths; % total depth
%wfp = .25;   % water filled porosity (vol pore water/vol soil)
rho = 3000;  % density of basalt

%lambda = (rad/10^-10).^.33;  % roughness factor

%rel_SA = (params.mf./params.rho).^(2/3);   % relative surface areas (vol to area)
%rel_SA = rel_SA/sum(rel_SA); % normalise

lpw_m2 = depth*wfp*1000;     % litres of pore water per m^2

%sa = 3*b_mass/(rad*rho)*lambda; % total surface area of basalt per m^2 (scaled by roughness)
%sa_lpw = sa/lpw_m2;             % reactive surface area per litre of pore water
%sa_lpw_min = sa_lpw.*rel_SA;

sa_prop = (params.mf./params.rho).^(2/3);
sa_prop = sa_prop'/sum(sa_prop);
p_vol = 1; p_prop_reacting = 1;
basalt_g_lpw = b_mass/depth/wfp;
sa_lpw = SA*basalt_g_lpw;

mol_lpw_min = zeros(length(params.names));
parms = zeros(length(params.names),3);
for i=1:length(params.names)
  mol_lpw_min(i) = b_mass.*params.mf(i)./params.mol_mass(i)*1000/lpw_m2;
  parms(i,:) = [sa_lpw, sa_prop(i), p_prop_reacting];
end



