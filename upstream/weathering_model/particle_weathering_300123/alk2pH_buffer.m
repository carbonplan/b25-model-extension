function pH=alk2pH_buffer(soil_CO2,alk)

global alk2pH_theoretical;

pHmin = 1; pHmax = 13;

%load('alk2pH_function.mat');
pHmax = alk2pH_theoretical(soil_CO2,soil_CO2*0+.1);

Amid = 0;
a = pHmax - pHmin;
b = -26.6*1/1000;

pH = pHmin + a./(1+exp((alk - Amid)/b));
