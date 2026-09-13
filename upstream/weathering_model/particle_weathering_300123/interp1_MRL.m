function yy = interp1_MRL(x,y,xx,METHOD,EXTRAP)

ind = find(x < 1e-10);
x(ind) = [];
y(ind) = [];

yy = interp1(x,y,xx,METHOD,EXTRAP);