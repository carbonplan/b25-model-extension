clear
load('alk2pH_function.mat');
alk2pH
CO2 = alk2pH.GridVectors{1};
alk = alk2pH.GridVectors{2};
values = alk2pH.Values;

save('alk2pH_data','CO2','alk','values')

%%
clear

load('CaSatBuffered_function.mat')
CaSat
CO2 = CaSat.GridVectors{1};
delAlk = CaSat.GridVectors{2};
values = CaSat.Values;

save('CaSatBuffered_data','CO2','delAlk','values')


%%

clear

load('CaSatNotBuffered_function.mat')
CaSat
CO2 = CaSat.GridVectors{1};
delAlk = CaSat.GridVectors{2};
values = CaSat.Values;

save('CaSatNotBuffered_data','CO2','delAlk','values')

CaSat
