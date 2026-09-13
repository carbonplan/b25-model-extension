function [CaSat,H0]=Ca_sat_buffered(CO2,delAlk)
% Function to calculate the saturation of Ca (mol/l).
% This is based on the following logic.
%
% Omega = CO3^2 Ca / ksp
% where Omega is a measure of saturation.
% At saturation Omega = 1 and so
% Ca = ksp / CO3^2
%
% C = Kh rho CO2 / alpha0
% CO3 = C alpha2
% Elliminating C and CO3 from the above 3 equations 
% gives an equation relating Ca to H at saturation.
%
% Next, the two alkalinity equations can be equated 
% and solved for H, after substituting in Ca as a 
% function of H from above.
% Alk = Kh*rho*CO2*(a1(H) + a2(H))./a0(H) + Kw./H - H
% Alk = delAlk + 2 Ca
% wehere delAlk = Alk0 + 2 Mg + K + na - 2 SO4 - Cl - NO3
% so
% 0 = 2 Ca(H) + delAlk -[Kh*rho*CO2*(a1(H) + a2(H))./a0(H) + Kw./H - H]
% The above equation is solved using a simple bisection method.

global alk2pH_theoretical

ksp = 3.3e-9;
Kw = 14.16; Kw = 10^-Kw;
Kh = 1.41;  Kh = 10^-Kh;
K1 = 6.38;  K1 = 10^-K1;
K2 = 10.38; K2 = 10^-K2;
rho = 10^-6;

a0  = @(H) 1./(1 + K1./H + K1*K2./H.^2);
a1  = @(H) 1./(1 + H/K1 + K2./H);
a2  = @(H) 1./(1 + H/K2 + H.^2/K1/K2);
Alk = @(H) Kh*rho*CO2*(a1(H) + 2*a2(H))./a0(H) + Kw./H - H;

pHmin = 1; pHmax = 13;
pHmax = alk2pH_theoretical(CO2,CO2*0+.1);

Amid = 0;
a = pHmax - pHmin;
b = -26.6*1/1000;
%Alk = @(pH) Amid + b*log((a - pH + pHmin)./(pH - pHmin))
Alk = @(H) Amid + b*log((a - log10(1./H) + pHmin)./(log10(1./H) - pHmin));

C   = @(H) Kh*rho*CO2/a0(H);
CO3 = @(H) C(H)*a2(H);
Ca  = @(H) ksp/CO3(H);

equilib = @(H) Alk(H) - (2*Ca(H) + delAlk);

% Hm & Hp in units of pH
Hm = .1;
Hp = 12;

tol = 1e-10;
iter = 0; err = 100;
while iter<100 && err>tol
  iter = iter + 1;
  H0 = (Hm + Hp)/2;
  eq = equilib(10^-H0);
  if eq>0
    Hp = H0;
  else
    Hm = H0;
  end
  err = abs(eq);
end
%fprintf('%d %g %.3f %g\n',iter,err,H0,Ca(10^-H0));
CaSat = Ca(10^-H0);
