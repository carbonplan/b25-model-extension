function mM=molMass2(element)

elements = {
'H',  1.00797
'He', 4.00260
'Li', 6.941
'Be', 9.01218
'B',  10.81
'C',  12.011
'N',  14.0067
'O',  15.9994
'F',  18.998403
'Ne', 20.179
'Na', 22.98977
'Mg', 24.305
'Al', 26.98154
'Si', 28.0855
'P',  30.97376
'S',  32.06
'Cl', 35.453
'K',  39.0983
'Ar', 39.948
'Ca', 40.08
'Sc', 44.9559
'Ti', 47.90
'V',  50.9415
'Cr', 51.996
'Mn', 54.9380
'Fe', 55.847
'Ni', 58.70
'Co', 58.9332
'Cu', 63.546
'Zn', 65.38
'Ga', 69.72
'Ge', 72.59
'As', 74.9216
'Se', 78.96
'Br', 79.904
'Kr', 83.80
'Rb', 85.4678
'Sr', 87.62
'Y',  88.9059
'Zr', 91.22
'Nb', 92.9064
'Mo', 95.94
'Tc', 98.00
};

if sum(strcmp(elements(:,1),element)) == 0
  error(['Element not in database ''molMass2.m'':',element]);
end

if sum(strcmp(elements(:,1),element)) > 1
  element
  error('Multiple entries for element in database ''molMass2.m''.');
end

for i=1:size(elements,1)
  if strcmp(elements{i,1},element)
    ind = i;
    mM = elements{i,2};
  end
end
