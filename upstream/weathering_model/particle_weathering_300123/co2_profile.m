function C=co2_profile(depth,Delz,L,Cair,NPP,verbose)
%% 
%% Soil ${\mathrm{CO}}_2$Profile
%% 
%% $$\frac{\partial \;C_s }{\partial \;t}=D_{\mathrm{air}} \;\varepsilon \;\rho \frac{\partial^2 C_s \;}{\partial \;z^2 }+\phi \left(z\right)$$
% where $C_s$ is the concentration of ${\mathrm{CO}}_2$ in soil, $D_{\mathrm{air}}$ 
% is the diffusion constant for ${\mathrm{CO}}_2$ in air, $\varepsilon$ is the 
% free-air porosity, $\rho \;$ is tortuosity, z is depth, and $\phi \left(z\right)$ 
% is a ${\mathrm{CO}}_2$ production function for the soil.
%% 
%% Taylor Model
% 
% 
% Following Cerling (1991), we use an exponential soil CO2 production function:
% 
% 
% 
% $$\phi \left(z\right)=\phi \left(0\right)\;\mathrm{exp}\left(-\frac{z}{z^* 
% }\right)$$
% 
% 
% 
% where $z^*$ is a characteristic depth which, when multiplied by the fine 
% root or hyphal length density $\phi \left(0\right)$ at the top of the soil (depth 
% $z=0$), gives the integral of the production function, that is, the toald length 
% of fine roots or hyphae over all depths. We expect the above equation to describe 
% the distribution of respiring organisms with depth, and therefore also the lengths 
% of fine roots and mychorrhizal hyphae and the soil volume containing them.
% 
% 
% 
% $$z^* =10\ldotp 1+0\ldotp 026\;\mathrm{NPP}$$
% 
% 
% 
% Define 
% 
% $R=\frac{\phi \left(\mathrm{elev}\right)}{\phi \left(\mathrm{amb}\right)}$ 
% to be the fine root or hyphal response, and
% 
% $P=\frac{\mathrm{plant}\left(\textrm{elev}\right)}{\mathrm{plant}\left(\textrm{amb}\right)}$ 
% to be the response of the coarse roots and aboveground parts to evevated (twice 
% ambient, linearly scaled as necessary). These values give the response to a 
% unit change in RCO2, the ratio of CO2 at time t to that at 0 Ma.
% 
% The change in NPP for an arbitrary RCO2 is RNPP, which is the ratio of 
% our calculated NPP for time t and that for 0 Ma. $\phi \left(0\right)$and $\phi 
% \left(t\right)$are the fine root or hyphal lengths at the top of the soil (z=0) 
% at time 0 Ma and time t respectively.
% 
% 
% 
% $$\phi_t \left(0\right)=\phi_0 \left(0\right)\;\left(1+\frac{\left(R-1\right)}{\left(P-1\right)}\left(\mathrm{RNPP}-1\right)\right)$$
% 
% 

zs = (10.1 + 0.026*NPP)/100;

p = round(depth/Delz+1);
z = [0:Delz:(p-1)*Delz]';

phi0 = .00000003; 
L   = L*100; 
Dair = .14;    % Carbon dioxide diffusion coefficient in air (cm^2/s) 
e    = 0.24;   % free air porosity
rho  = 0.6;    % tortuosity factor
%Cair = 350/1e6;
%Cair = 410/1e6;
%Cair = 600/1e6;
Cair = Cair/1e6;

%z = 0:.01:100';
%z = 0:.01:15';
z = z*100;
zs = zs*100;

C = phi0*L^2/(Dair*e*rho)*(1-exp(-z/L))+Cair;
%% 
% There is an implied boundary condition to get to the above equation which 
% isn't explained, only one is given and two are needed.
% 
% ???  I don't understand.


if verbose
  figure;
  plot(log10(C),z,'-','linewidth',2); set(gca,'fontsize',12,'YDir','reverse');
  title('Soil CO_2 Profile');
end

%% Cerling Model
%%
Q = 4.4e-6;
phi0 = Q/L;
%% 
% Here L is defined as the depth of the box with an impermiable base.

C = phi0/(Dair*e*rho)*(z*L - z.^2/2) + Cair; CC = C;
if verbose
  plot(log10(C),z,'-','linewidth',2); set(gca,'fontsize',12,'YDir','reverse'); grid
  title('Soil CO_2 Profile');
end
 %% Combining Taylor & Cerling
% 
% 
% Take the idea from Cerling that the integral of the production function 
% over depth is equal to soil respiration (which is more or less equal to NPP), 
% and use the Taylor production function.
% 
% 
% 
% $$\phi \left(z\right)=A\;\exp \left(-\frac{z}{z^* }\right)$$
% 
% then integrating over depth gives
% 
% $$\begin{array}{l}\mathrm{NPP}=\int_0^L A\;\mathrm{exp}\left(-\frac{z}{z^* 
% }\right)\;\mathrm{dz}={\left\lbrack -A\;z^* \;\mathrm{exp}\left(-\frac{z}{z^* 
% }\right)\right\rbrack }_0^L =A\;z^* \;\left(1-\mathrm{exp}\left(-\frac{L}{z^* 
% }\right)\right)\\A=\frac{\mathrm{NPP}}{z^* \;\left(1-\mathrm{exp}\left(-\frac{L}{z^* 
% }\right)\right)}\end{array}$$
% 
% 

%NPP = 700; % g/m^2/year

moleculesInAir = 2.53e25;
av = 6.022e23;
molAir = 28.97;
molCO2 = 44.01;
molesInAir = moleculesInAir/av;

convC2CO2 = 44/12;

gramsCO2 = NPP/3600/24/365*convC2CO2/10000; % the 10000 comes from the fact that Dair is in units of per cm^2
Q = gramsCO2/molCO2/molesInAir*1e6;

%% 
% First boundary condition, z = 0, C = Cair.

A = Q/(zs*(1 - exp(-L/zs)));
%% 
% Second boundary condition, the rate of change of C is zero at L. 
% 
% Not sure if this is sensible but its the approach taken in the Cerling 
% paper.

B =-A*zs/(Dair*e*rho)*exp(-L/zs);

phi = A*exp(-z/zs);

if verbose
plot(phi,z,'-','linewidth',2); set(gca,'fontsize',12,'YDir','reverse'); grid; 
xlim([0 inf]); title('CO_2 Production'); xlabel('\phi (concentration)'); ylabel('depth')
end

C = A*zs^2/(Dair*e*rho)*(1 - exp(-z/zs)) + B*z + Cair;

if verbose
  subplot(2,1,1)
  plot(log10(C),z,'-','linewidth',2); set(gca,'fontsize',12,'YDir','reverse'); grid;
  xlabel('log(C) (concentration)'); ylabel('depth'); title('Soil CO_2 Profile'); 
  subplot(2,1,2)
  plot(C*1e6,z,'-','linewidth',2); set(gca,'fontsize',12,'YDir','reverse'); grid;
  xlabel('concentration'); ylabel('depth'); title('Soil CO_2 Profile'); 
%% Uniform Source vs Exponential Source
% plot(log10(C),z,'-',log10(CC),z,'-r','linewidth',2); set(gca,'fontsize',12,'YDir','reverse'); grid;
% xlabel('log(C) (concentration)'); ylabel('depth'); 
% legend({'Exponential source','Uniform source'},'location','southwest');
%%
end


%%
%.009*24*365*molCO2*.2727