function alk=pH2Alk_buffer(pH,soil_CO2)


global alk2pH_theoretical;

pHmin = 1; pHmax = 13;
maxAlk = .1;

%load('alk2pH_function.mat');
pHmax = alk2pH_theoretical(soil_CO2,soil_CO2*0 + maxAlk);

Amid = 0;
a = pHmax - pHmin;
b = -26.6/1000;

alk = zeros(size(pH));

for i=1:length(pH)
  if pH(i) >= pHmax(i)
    alk(i) = .1;
  elseif pH(i) <= pHmin
    alk(i) = -.1;
  else
    if ((a(i) - pH(i) + pHmin)./(pH(i) - pHmin) > 0)
      alk(i) = Amid + b*log((a(i) - pH(i) + pHmin)./(pH(i) - pHmin));
    else
      alk(i) = maxAlk;
    end
  end
  if alk(i) > maxAlk
    alk(i) = maxAlk;
  end
end

