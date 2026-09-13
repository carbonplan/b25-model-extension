function [rad1,mfd1,mass1] = get_pdf_donkey(delt,rad0,mfd0,mass0,rho,d,verbose)
% compute the pdf after time delt
% and interpolate to 1-1000 micron 

delr = rad0(2) - rad0(1);

total_particle_mass = delr*mfd0*mass0;
particle_mass = 4/3*pi*rad0.^3*rho;
no_of_particles = total_particle_mass./particle_mass;

radf = rfun(delt,rad0,d);
ind = find(radf==0); radf(ind) = []; no_of_particles(ind) = [];

n=length(radf);
delr = [radf(2)-radf(1),(radf(3:end)-radf(1:end-2))/2,radf(end)-radf(end-1)];

particle_mass = 4/3*pi*radf.^3*rho;
mass_of_particles = particle_mass.*no_of_particles;
mfdf = mass_of_particles./delr;

rad1 = [0:1e-6:.001];
mfd1 = interp1(radf,mfdf,0:1e-6:.001,'SPLINE',0);

[rad1,mfd1] = pdf_maker(radf,mfdf,10e-6);

mass1 = sum(mass_of_particles);
%mfd1 = mfd1/mass1;

if verbose
  plot(rad0,mfd0,rad1,mfd1,'linewidth',2);
  l1 = legend({sprintf('%.2f kg',mass0),sprintf('%.2f kg',mass1)});
  set(l1,'itemtokensize',[10 3]);
end
