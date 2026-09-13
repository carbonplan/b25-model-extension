function neta = neta(CO2,salinity,tmp)

S_term = salinity*10^-3.009 + 10^-1.519;
G13 = S_term*log(CO2) - salinity*10^-2.1;
H13 = CO2.*tmp*(salinity*10^-7.501 - 10^-5.598);
I13 = tmp*10^-2.337;

neta = G13 - H13 - I13 + 10^-.102;
