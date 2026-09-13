function [r,r0,fs] = rfun2(delt,r0,fs,p,k)

ii = find((p - 1)*k*delt+ r0.^(1-p) <= 0);
r0(ii) = [];
fs(ii) = [];
r = ((p - 1)*k*delt+ r0.^(1-p)).^(1/(1 - p));





