function [tmp,q,npp,yield,soilresp,CO2] = calc_drivers(data,t,yieldV)

METHOD = 'linear';

x = ((1:length(data.tmp))-.5)/12;
tmp      = interp1(x,data.tmp,      t,METHOD,'extrap');
x = ((1:length(data.flowrate))-.5)/12;
q        = interp1(x,data.flowrate, t,METHOD,'extrap')*12;
x = ((1:length(data.npp))-.5)/12;
npp      = interp1(x,data.npp,      t,METHOD,'extrap')*12;
x = ((1:length(yieldV))-.5)/12;
yield    = interp1(x,yieldV,        t,METHOD,'extrap')*12;
x = ((1:length(data.soilresp))-.5)/12;
soilresp = interp1(x,data.soilresp, t,METHOD,'extrap')*12;
x = ((1:length(data.CO2))-.5)/12;
CO2      = interp1(x,data.CO2,      t,METHOD,'extrap');

x = ((1:length(data.tmp))-.5)/12;
%tmp = zeros(size(data.tmp,2),1);
%for i=1:size(data.tmp,2)
%  tmp(i,1) = interp1(x,squeeze(data.tmp(:,i)),t,METHOD,'extrap'); 
%end
tmp = interp1(x,data.tmp,t,METHOD,'extrap')'; 

npp      = max(npp,0);
%q        = max(q,0);
yield    = max(yield,0);
soilresp = max(soilresp,0);
