function [Bp,weathered_mass] = weather_particles(Bp,delt,k,fd,rho)

weathered_mass = Bp.m;
Bp.r = (Bp.r.^(1 - fd) - k/rho*(1 - fd)*delt).^(1/(1 - fd));
ii = find(real(Bp.r<=0));
Bp.r(ii) = 0;
Bp.m = rho*4/3*pi*Bp.r.^3.*Bp.n;

weathered_mass = weathered_mass - Bp.m;

%r_new = (single(r0).^(1 - single(fd)) - single(k)/single(rho)*(1 - single(fd))*single(delt)).^(1/(1 - single(fd)));
