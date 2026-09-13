function Alk=pH2Alk(pH,CO2)

H = 10.^(-pH);

Kw = 14.16; Kw = 10^-Kw;
Kh = 1.41;  Kh = 10^-Kh;
K1 = 6.38;  K1 = 10^-K1;
K2 = 10.38; K2 = 10^-K2;
rho = 10^-6;

%a0 = @(H) 1./(1 + K1./H + K1*K2./H.^2);
%a1 = @(H) 1./(1 + H/K1 + K2./H);
%a2 = @(H) 1./(1 + H/K2 + H.^2/K1/K2);
%Alk = @(H) Kh*rho*CO2*(a1(H) + a2(H))./a0(H) + Kw./H - H;

a0 = 1./(1 + K1./H + K1*K2./H.^2);
a1 = 1./(1 + H/K1 + K2./H);
a2 = 1./(1 + H/K2 + H.^2/K1/K2);
Alk = Kh*rho*CO2.*(a1 + 2*a2)./a0 + Kw./H - H;


