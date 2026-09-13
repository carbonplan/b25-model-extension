function kpyr = m2k(x,mol_mass)
% Convert from mols per second to kilograms/year
% mol_mass = 200;

mol2kg = mol_mass/1000;
s2yr = 1/(365.25*24*3600);
mps2kpy = mol2kg/s2yr;

% convert x mol/m^2/s to kg/m^2/year
kpyr = x.*mps2kpy;



