function mM=molMass(element)
%https://www.convertunits.com/molarmass/He

switch element
  case 'Al'
    mM = 26.981538;
  case 'Ca'
    mM = 40.078;
  case 'Cl'
    mM = 35.453;
  case 'F'
    mM = 18.9984832;
  case 'K'
    mM = 39.0983;
  case 'Mg'
    mM = 24.3050;
  case 'Na'
    mM = 22.989770;
  case 'O'
    mM = 15.9994;
  case 'P'
    mM = 30.973762;
  case 'Si'
    mM = 28.0855;
  otherwise
    error('unknown element');
end
