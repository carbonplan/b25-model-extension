% fraction of moles that is K

params = set_basalt('Cragmill');

B_mass = 4*params.mf';

C_molperl = 1000*B_mass./params.mol_mass'; % mols per m^2

Al_m = C_molperl.*params.elements.Al';
C_m  = C_molperl.*params.elements.C';
Ca_m = C_molperl.*params.elements.Ca';
Cl_m = C_molperl.*params.elements.Cl';
F_m  = C_molperl.*params.elements.F';
Fe_m = C_molperl.*params.elements.Fe';
H_m  = C_molperl.*params.elements.H';
K_m  = C_molperl.*params.elements.K';
Mg_m = C_molperl.*params.elements.Mg';
Na_m = C_molperl.*params.elements.Na';
O_m  = C_molperl.*params.elements.O';
P_m  = C_molperl.*params.elements.P';
Si_m = C_molperl.*params.elements.Si';
Ti_m = C_molperl.*params.elements.Ti';

Al = Al_m*molMass2('Al')/1000;
C  = C_m*molMass2('C')/1000;
Ca = Ca_m*molMass2('Ca')/1000;
Cl = Cl_m*molMass2('C')/1000;
F  = F_m*molMass2('F')/1000;
Fe = Fe_m*molMass2('Fe')/1000;
H  = H_m*molMass2('H')/1000;
K  = K_m*molMass2('K')/1000;
Mg = Mg_m*molMass2('Mg')/1000;
Na = Na_m*molMass2('Na')/1000;
O  = O_m*molMass2('O')/1000;
P  = P_m*molMass2('P')/1000;
Si = Si_m*molMass2('Si')/1000;
Ti = Ti_m*molMass2('Ti')/1000;

mass_els = [Al,C,Ca,Cl,F,Fe,H,K,Mg,Na,O,P,Si,Ti];

el_names = {'Al','C','Ca','Cl','F','Fe','H','K','Mg','Na','O','P','Si','Ti'};

sum(sum(mass_els));
sum(mass_els,1)/4*100;
sum(sum(mass_els'/4*1000));

%disp('        Qu       Lab       San      Clin       Ill      Kaol    Augite     Phlog      Cord      Apat')
%disp(mass_els'/4*1000);

B_avg = squeeze(sum(B_sim,2));
w_mins = (B_avg(:,1) - B_avg(:,end))./B_avg(:,1)*100;

initial_rock = sum(B_avg(:,1))/61*.15;
weathered_rock = (sum(B_avg(:,1)) - sum(B_avg(:,end)))/sum(B_avg(:,1))*initial_rock;

disp('-----------------------')
disp(' ')
disp(' ')
perc_els = mass_els/4*100;

disp('Rock Minerals & Elements (m%)')
disp(['       min              ' ...
'Al     C      Ca     Cl     F      Fe     H      K      Mg     Na     ' ...
'O      P      Si     Ti']);
st1 = repmat('%7.2f',1,14);
for i=1:length(w_mins)
  fprintf(['%12s  %4.1f   ',st1,'\n'],params.names{i}, ...
 params.mf(i)*100, ...
 perc_els(i,:));
end
disp(' ')
fprintf('Weathered Mineral & Elements (g): %4.0fg/M^2 (weathered = %4.0fg/M^2)\n', ...
 initial_rock*1000,weathered_rock*1000)
disp(['       min  w_min(%)    ' ...
'Al     C      Ca     Cl     F      Fe     H      K      Mg     Na     ' ...
'O      P      Si     Ti']);
sum_weathered = 0;
st1 = repmat('%7.2f',1,14);
for i=1:length(w_mins)
  fprintf(['%12s  %4.1f   ',st1,'\n'],params.names{i}, ...
  w_mins(i),w_mins(i)/100*perc_els(i,:)/100*4000);
  sum_weathered = sum_weathered + sum(w_mins(i)/100*perc_els(i,:)/100*4000);
end








