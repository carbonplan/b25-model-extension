function [rad,mfd] = make_profile(rad0,var0,mfd0,n)

xf = 1000e-6;
x0 = xf/n;
rad = linspace(x0,xf,n);

mfd = rad*0;
for i=1:length(rad0)
  mfd = mfd + pdf('Normal',rad,rad0(i)*1e-6,var0(i)*1e-6)*mfd0(i);
end
mfd = mfd/trapz(rad,mfd);


