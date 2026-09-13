function p_x_val = p_x(mass0,rad0,p_x)
% mass0 (kg)
% rad0 (meters)
% p_x (%) : percentage
% p_x_val (diameter (microns) of which p_x % of mass consists of larger diameters)

if length(mass0) > 1
  cdf = tril(ones(length(mass0)))*mass0/sum(mass0)*100;
  p_x_val = 2*interp1_MRL2(cdf,rad0*1e6,p_x);
else
  p_x_val = rad0*2;
end

