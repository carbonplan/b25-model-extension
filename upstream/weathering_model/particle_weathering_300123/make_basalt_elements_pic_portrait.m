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

%disp('        Qu       Lab       San      Clin       IKaol    Augite     Phlog      Cord      Apat')
%disp(mass_els'/4*1000);

B_tot = run_params.b_mass*run_params.tf;
B_avg = squeeze(sum(B_sim,2))/61*.15;
B_end = B_avg(:,end);
weathered_rock = (B_tot - sum(B_avg(:,end))/61*.15);
w_mins = (B_tot - weathered_rock)./B_tot*100;


initial_rock = B_tot;
weathered_rock = (B_tot - sum(B_avg(:,end))/61*.15);

fprintf('%s\n',params.name);
fprintf('Site %d\n',iSite);
fprintf('p80(%0.0d)\n',run_params.p80);
if run_params.tf == 1
  fprintf('%d year\n',run_params.tf);
else
  fprintf('%d years\n',run_params.tf);
end
  
disp(' ')
perc_els = mass_els/4*100;

min_names = [];
for i=1:length(params.names)
  min_names =  [min_names,' ',params.names{i}(1:6)];
end
min_names;


fprintf('                Minerals & Elements: mass fraction (%%)\n');
disp(' ');
disp([' min  total  ',min_names]);
st1 = repmat('%7.2f',1,length(params.names));
st2 = repmat('%7.1f',1,length(params.names));
fprintf(['  mf        ',st2,'\n'],params.mf*100);
disp(' ');
for i=1:length(el_names)
  fprintf(['%4s  %5.2f ',st1,'\n'],el_names{i},sum(perc_els(:,i)),perc_els(:,i));
end
disp(' ')
disp(' ')

fprintf('                Mineral & Elements: weathered mass (g/m^2)\n');
fprintf('              Application = %4.0fg/m^2, Weathered = %4.0fg/m^2\n',initial_rock*1000,weathered_rock*1000);
disp(' ')
disp([' min  total  ',min_names]);
sum_weathered = 0;
st1 = repmat('%7.2f',1,length(params.names));
st2 = repmat('%7.1f',1,length(params.names));
fprintf([' w(%%)       ',st2,'\n'],w_mins);
disp(' ');
for i=1:length(el_names)
  fprintf(['  %2s %6.1f ',st1,'\n'],el_names{i},'_2',sum(w_mins/100.*perc_els(:,i)/100*4000), ...
      w_mins/100.*perc_els(:,i)/100*4000);
%  sum_weathered = sum_weathered + sum(w_mins(i)/100*perc_els(:,i)/100*4000);
end




