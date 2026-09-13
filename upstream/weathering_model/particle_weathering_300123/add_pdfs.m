function [rad2,mfd2,mass2]=add_pdfs(rad0,mfd0,mass0,rad1,mfd1,mass1)

METHOD = 'linear';

rad2 = 1e-6:1e-6:1e-3;
if mass0>0
  mfd2 = (interp1(rad0,mfd0,rad2,METHOD,0)*mass0 + interp1(rad1,mfd1,rad2,METHOD,0)*mass1);
else
  mfd2 = interp1(rad1,mfd1,rad2,METHOD,0);
end
mfd2 = mfd2/trapz(rad2,mfd2);
mass2 = mass0 + mass1;
