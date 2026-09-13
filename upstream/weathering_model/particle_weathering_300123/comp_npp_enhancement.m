function npp_enhancement = comp_npp_enhancement(npp_norm,woody);
% Arguments: npp_norm [0-1] : woody [0|1] ie 1=woody.

if (npp_norm > 1) | (npp_norm < 0)
  error('1st argument must be 0<arg1<1.');
end

if woody
  a = 0.0659059;
  b = 1.48934;
  xnorm = 18;
else
  a = 0.140386;
  b = 3.54559;
  xnorm = 3;
end
a = a*xnorm^b;
npp_enhancement = a*npp_norm^b + 1;

