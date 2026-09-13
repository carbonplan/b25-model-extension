function params = params_reorder(params)

ii = 0;
for i=1:length(params.names)
  if strcmp(params.names{i},'Apatite')
   ii = i;
  end
end

if ii>0
tmp = params.minerals{ii}; params.minerals(ii) = []; params.minerals{end+1} = tmp;
tmp = params.names{ii}; params.names(ii) = []; params.names{end+1} = tmp;
tmp = params.formulae{ii}; params.formulae(ii) = []; params.formulae{end+1} = tmp;

tmp = params.rho(ii); params.rho(ii) = []; params.rho(end+1) = tmp;
tmp = params.mol_mass(ii); params.mol_mass(ii) = []; params.mol_mass(end+1) = tmp;
tmp = params.co2_ratio(ii); params.co2_ratio(ii) = []; params.co2_ratio(end+1) = tmp;

tmp = params.acid.k(ii); params.acid.k(ii) = []; params.acid.k(end+1) = tmp;
tmp = params.acid.e(ii); params.acid.e(ii) = []; params.acid.e(end+1) = tmp;
tmp = params.acid.n(ii); params.acid.n(ii) = []; params.acid.n(end+1) = tmp;
tmp = params.neut.k(ii); params.neut.k(ii) = []; params.neut.k(end+1) = tmp;
tmp = params.neut.e(ii); params.neut.e(ii) = []; params.neut.e(end+1) = tmp;
tmp = params.neut.n(ii); params.neut.n(ii) = []; params.neut.n(end+1) = tmp;
tmp = params.base.k(ii); params.base.k(ii) = []; params.base.k(end+1) = tmp;
tmp = params.base.e(ii); params.base.e(ii) = []; params.base.e(end+1) = tmp;
tmp = params.base.n(ii); params.base.n(ii) = []; params.base.n(end+1) = tmp;

tmp = params.elements.Al(ii); params.elements.Al(ii) = []; params.elements.Al(end+1) = tmp;
tmp = params.elements.C(ii);  params.elements.C(ii)  = []; params.elements.C(end+1)  = tmp;
tmp = params.elements.Ca(ii); params.elements.Ca(ii) = []; params.elements.Ca(end+1) = tmp;
tmp = params.elements.Cl(ii); params.elements.Cl(ii) = []; params.elements.Cl(end+1) = tmp;
tmp = params.elements.F(ii);  params.elements.F(ii)  = []; params.elements.F(end+1)  = tmp;
tmp = params.elements.Fe(ii); params.elements.Fe(ii) = []; params.elements.Fe(end+1) = tmp;
tmp = params.elements.H(ii);  params.elements.H(ii)  = []; params.elements.H(end+1)  = tmp;
tmp = params.elements.K(ii);  params.elements.K(ii)  = []; params.elements.K(end+1)  = tmp;
tmp = params.elements.Mg(ii); params.elements.Mg(ii) = []; params.elements.Mg(end+1) = tmp;
tmp = params.elements.Na(ii); params.elements.Na(ii) = []; params.elements.Na(end+1) = tmp;
tmp = params.elements.O(ii);  params.elements.O(ii)  = []; params.elements.O(end+1)  = tmp;
tmp = params.elements.P(ii);  params.elements.P(ii)  = []; params.elements.P(end+1)  = tmp;
tmp = params.elements.Si(ii); params.elements.Si(ii) = []; params.elements.Si(end+1) = tmp;
tmp = params.elements.Ti(ii); params.elements.Ti(ii) = []; params.elements.Ti(end+1) = tmp;

tmp = params.mf(ii); params.mf(ii) = []; params.mf(end+1) = tmp;
end

