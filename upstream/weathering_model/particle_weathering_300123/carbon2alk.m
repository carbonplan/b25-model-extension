function [alk, source] = carbon2alk(soy,yield,phi,q,depth,delz,rooting_depth)

exp_root_dist = 0;

if soy == 0
  %productivity_2_charge = 1/50;
  productivity_2_charge = 0.0395; % From Lyla's spread sheet (molH/molC)
%  productivity_2_charge = 0.0128; % From Lyla's spread sheet (molH/molC)
  %productivity_2_charge = 0.0395; % From Lyla's spread sheet (molH/molC)
else
  productivity_2_charge = 0.0395 + 0.0128; % From Lyla's spread sheet (molH/molC)
end

z = (0:delz:depth)';

yield_mol = yield/12;

if exp_root_dist
% Calculate concentration of source, 
% assume and exponential distribution
  [yield_mol_metre_year,eqSol] = exp_dist(yield_mol,rooting_depth,z);

% convert to /litre
  yield_mol_litre_year = yield_mol_metre_year/1000;
  eqSol = eqSol/1000;

% convert to charge
  source = yield_mol_litre_year*productivity_2_charge;
  eqSol = eqSol*productivity_2_charge;

% equilibrium solution
  alk = eqSol/q;

else

% Calculate concentration of source, 
% assume a constant source over the depth.
  yield_mol_metre_year = yield_mol/depth;

% convert to /litre
  yield_mol_litre_year = yield_mol_metre_year/1000;

% convert to charge
  source = yield_mol_litre_year*productivity_2_charge;

% put a minimum on q
% this is required as we are using the equilibrium solution
% which is proportional to the inverse of q, which
% would not be reached in a short time when q is small
% and q only remains small for relatively short time intervals.
% q = max(0.01,q);
% Redundant now as we are modelling acidifier dynamically

% equilibrium solution
  alk = z*source/q;
%alk = z*yield_mol_litre_year/phi/q*productivity_2_charge;

  source = source*ones(size(z));

end


%if 0
%figure(2)
%subplot(2,1,1)
%plot(source,z,source2,z,'linewidth',2); set(gca,'YDir','reverse');
%legend({'sourceC','sourceE'})
%subplot(2,1,2)
%plot(alk,z,alk2,z,'linewidth',2); set(gca,'YDir','reverse');
%legend({'alkC','alkE'})
%error('stop')
%end

% assume a constant source over the rooting depth.
%yield_mol_metre_year = yield_mol/rooting_depth*ones(size(z));
% convert to /litre
%yield_mol_litre_year = yield_mol_metre_year/1000;
% convert to charge
%source = yield_mol_litre_year*productivity_2_charge;
% equilibrium solution
%alk = z.*source/q;

