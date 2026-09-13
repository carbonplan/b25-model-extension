function params = read_min_params(params,run_params)

%filename = 'data/minerals/mineral_parameters4_USA.csv';
%filename = 'data/minerals/mineral_parameters4.csv';
filename = [run_params.data_dir,'/minerals/',run_params.minerals_filename,'.csv'];

a = read_csv(filename,2);

indind = zeros(length(params.minerals),1);
for ii=1:length(params.minerals)
   sti = strcmp(char(params.minerals(ii)),a.Mineral);
   [ind, jj] = find(1 == sti);
   if (length(ind) == 1)
     indind (ii) = ind;
   elseif (length(ind) == 0)
     error('Mineral data-base doesn''t contain %s',char(params.minerals(ii))); 
   else
     error('Mineral data-base contains multiple %s',char(params.minerals(ii))); 
   end
end

params.formulae  = a.Formulae(indind)';
params.rho       = a.Density(indind)';
params.names     = a.Mineral(indind)';
params.co2_ratio = a.RCO2(indind)';
params.acid.k    = a.k_Acid(indind)';
params.acid.e    = a.e_Acid(indind)';
params.acid.n    = a.n_Acid(indind)';
params.neut.k    = a.k_Neutral(indind)';
params.neut.e    = a.e_Neutral(indind)';
params.neut.n    = a.n_Neutral(indind)';
params.base.k    = a.k_Base(indind)';
params.base.e    = a.e_Base(indind)';
params.base.n    = a.n_Base(indind)';

params.elements.Al = zeros(1,length(indind));
params.elements.C  = zeros(1,length(indind));
params.elements.Ca = zeros(1,length(indind));
params.elements.Cl = zeros(1,length(indind));
params.elements.F  = zeros(1,length(indind));
params.elements.Fe = zeros(1,length(indind));
params.elements.H  = zeros(1,length(indind));
params.elements.K  = zeros(1,length(indind));
params.elements.Mg = zeros(1,length(indind));
params.elements.Na = zeros(1,length(indind));
params.elements.O  = zeros(1,length(indind));
params.elements.P  = zeros(1,length(indind));
params.elements.Si = zeros(1,length(indind));
params.elements.Ti = zeros(1,length(indind));

for i=1:length(params.formulae)
%  disp(['formulae ',params.minerals{i}]);
%  disp(['formulae ',params.formulae{i}]);
  [els,nums,MM] = parse_formula(params.formulae{i});
  params.mol_mass(i) = MM;
  for j=1:length(els)
     switch els{j}
       case 'Al'
         params.elements.Al(i) = params.elements.Al(i) + nums(j);
       case 'C'
         params.elements.C(i)  = params.elements.C(i)  + nums(j);
       case 'Ca'
         params.elements.Ca(i) = params.elements.Ca(i) + nums(j);
       case 'Cl'
         params.elements.Cl(i) = params.elements.Cl(i) + nums(j);
       case 'F'
         params.elements.F(i)  = params.elements.F(i)  + nums(j);
       case 'Fe'
         params.elements.Fe(i) = params.elements.Fe(i) + nums(j);
       case 'H'
         params.elements.H(i)  = params.elements.H(i)  + nums(j);
       case 'K'
         params.elements.K(i)  = params.elements.K(i)  + nums(j);
       case 'Mg'
         params.elements.Mg(i) = params.elements.Mg(i) + nums(j);
       case 'Na'
         params.elements.Na(i) = params.elements.Na(i) + nums(j);
       case 'O'
         params.elements.O(i)  = params.elements.O(i)  + nums(j);
       case 'P'
         params.elements.P(i)  = params.elements.P(i)  + nums(j);
       case 'Si'
         params.elements.Si(i) = params.elements.Si(i) + nums(j);
       case 'Ti'
         params.elements.Ti(i) = params.elements.Ti(i) + nums(j);
     end
  end
end



