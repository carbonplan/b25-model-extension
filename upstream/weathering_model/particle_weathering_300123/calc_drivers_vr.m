function out=calc_drivers_vr(data,t)

METHOD = 'linear';

xt = ((1:size(data.N.Flux,1))-.5)/12;

out = zeros(size(data.N.Flux,2),1);
for i=1:size(data.N.Flux,2)
  out(i,1) = interp1(xt,squeeze(data.N.Flux(:,i)),t,METHOD,'extrap');
end
