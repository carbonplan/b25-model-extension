function [SAvsVol_SA, SAvsVol_vol] = SA_vs_Vol_9(rad,mfd,p,verbose)

%p = 0;

k = 100e-6;
%w = rho*k;

k = k*1e10^p;

deltfun = @(r,r0) (r^(1-p) - r0^(1-p))/(p-1)/k;

x = rad;
y = mfd;

if verbose
  figure(11); clf;
  subplot(2,2,1)
  plot(x*1e6,y,'o','markerfacecolor','b','markeredgecolor','b','markersize',2)
  ax = axis; xlabel('r (\mum)');
end
  
tf = deltfun(0,x(end)*.9);
nSA = 1000;
delt = tf/nSA;

massv = []; SAtot = [];
for idelt = 0:nSA
  [rs, r0, f] = rfun2(delt*idelt,x,y,p,k);
  fs = f.*lambda2(r0,p,k)./lambda2(rs,p,k).*(rs./r0).^3;

  massv(idelt+1) = trapz(rs,fs);
%  SAtot(idelt+1) = 3/rho*trapz(rs,fs./rs);
  SAtot(idelt+1) = 3*trapz(rs,fs.*(10^10*rs).^p./rs);
  
  if (mod(idelt,10)==0) && (verbose)
    subplot(2,2,2)
    plot(rs*1e6,fs,'color','b','linewidth',2); axis(ax); xlabel('r (\mum)');
    drawnow;
  end
end

ii = find(massv < 1e-50); massv(ii) = []; SAtot(ii) = [];
ii = find(SAtot == 0); massv(ii) = []; SAtot(ii) = [];

if verbose
  subplot(2,2,3);
  plot(massv,SAtot,'o','markerfacecolor','r','markeredgecolor','r','markersize',3)
  grid; xlim([0,inf]); ylim([0,inf]);
  xlabel('mass kg'); ylabel('SA m^2/kg')
end

SAvsVol_SA = [SAtot,0];
%SAvsVol_vol = [massv/rho,0];
SAvsVol_vol = [massv,0];