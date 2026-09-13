function r1=rfun(t,r0,d)

r1 = real(r0.^(1-d) - t*(1-d));
r1(find(r1<0)) = 0;
r1 = r1.^(1/(1-d));
