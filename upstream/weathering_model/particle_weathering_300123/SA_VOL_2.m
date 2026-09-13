function [SA,VOL,T]=SA_VOL_2(rad0,mfd0,total_mass,rho,d,nsteps)

delr = rad0(2) - rad0(1);

total_particle_mass = delr*mfd0*total_mass;
particle_mass = 4/3*pi*rad0.^3*rho;
particle_SA = 4*pi*rad0.^2;
no_of_particles = total_particle_mass./particle_mass;

delr = max(rad0);
delrx = linspace(delr,0,nsteps);
delrx = delrx.^(1/4)./delr^(1/4)*delr;

SA = zeros(1,nsteps); VOL = SA; T = SA;
for istep = 1:nsteps
  delt = tfun(max(rad0),delrx(istep),d);
  radf = rfun(delt,rad0,d);
  particle_SA = 4*pi*radf.^2;
  particle_SA = particle_SA.*radf.^d;
  particle_VOL = 4/3*pi*radf.^3;
  SA(istep) = no_of_particles*particle_SA';
  VOL(istep) = no_of_particles*particle_VOL';
  T(istep) = delt;
end
SA = SA*1e10^d;
