function [totals,Ca_sim,RCO2_sim,K_mass,P_mass,Ca_mass_precip_t, ...
 c2b_ratio,CO2_mass,CO2_mass_precip,CO2_mass_outflow, ...
 Application_Basalt_mass,outElements] = ...
 mass_balance(fid,params,fd_params,run_params,data,t,B_t,C_t,outflow_t,depth, ...
 Ca_sol_t,Ca_precip_t,outflowCa_t,phi,b_mass,H_sol_t,outflowH_t, ...
 swvf_t,verbose)

Delz = fd_params.Delz;

tf = t(end);
its = [8 2];
newUnits = 'normal';
fsl = 6;

p = round(depth/Delz+1);
z = [0:Delz:(p-1)*Delz]';

B_mass_t = []; C_mass_t = [];
Ca_mass_sol_t = []; Ca_mass_precip_t = [];
H_mass_sol_t = [];
nmins = length(params.names);

for i=1:nmins
  for j=1:size(B_t,3)
    B_mass_t(i,j) = trapz(z,squeeze(B_t(i,:,j)));
    C_mass_t(i,j) = trapz(z,squeeze(C_t(i,:,j)));
  end
end

for j=1:length(t)
% times by a thousand as we are integrating mols per litre over meters
% and mols per litre are effectively mols per millimeter per meter squared.
  Ca_mass_sol_t(j) = trapz(z,squeeze(Ca_sol_t(:,j)))*1000*phi;
  Ca_mass_precip_t(j) = trapz(z,squeeze(Ca_precip_t(:,j)))*1000*phi;
  
  H_mass_sol_t(j) = trapz(z,squeeze(H_sol_t(:,j))*1000*phi);
end

tot = B_mass_t + C_mass_t*phi + outflow_t;
tottot = sum(tot);
error = (tottot(1)*ceil(t(end)) - tottot(end))/(tottot(1)*ceil(t(end)))*100;
errorx = (tottot(1)*ceil(t) - tottot)/(tottot(1)*ceil(t(end)))*100;

totals.tot = tot;

if verbose
figure(fid); clf;
subplot(3,2,1);
plot(t,tot,'linewidth',2);
hL = legend(params.names);
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
title(['min mass loss = ',sprintf('%.2f%%',error)])
xlim([0 t(end)]); grid;
end

C_molperl = 1000*B_mass_t./params.mol_mass'; % mols per m^2
Ca_B = C_molperl.*params.elements.Ca'; Ca_B = squeeze(sum(Ca_B,1));
Mg_B = C_molperl.*params.elements.Mg'; Mg_B = squeeze(sum(Mg_B,1));
K_B  = C_molperl.*params.elements.K';  K_B  = squeeze(sum(K_B ,1));
Na_B = C_molperl.*params.elements.Na'; Na_B = squeeze(sum(Na_B,1));
if isfield(params.elements,'Si')
  Si_B = C_molperl.*params.elements.Si'; Si_B = squeeze(sum(Si_B,1));
end
if isfield(params.elements,'Fe')
  Fe_B = C_molperl.*params.elements.Fe'; Fe_B = squeeze(sum(Fe_B,1));
end
if isfield(params.elements,'P')
  P_B = C_molperl.*params.elements.P'; P_B = squeeze(sum(P_B,1));
end

C_molperl = 1000*C_mass_t./params.mol_mass'; % mols per m^2
Ca_C = C_molperl.*params.elements.Ca'; Ca_C = squeeze(sum(Ca_C,1));
Mg_C = C_molperl.*params.elements.Mg'; Mg_C = squeeze(sum(Mg_C,1));
K_C  = C_molperl.*params.elements.K';  K_C  = squeeze(sum(K_C ,1));
Na_C = C_molperl.*params.elements.Na'; Na_C = squeeze(sum(Na_C,1));
if isfield(params.elements,'Si')
  Si_C = C_molperl.*params.elements.Si'; Si_C = squeeze(sum(Si_C,1));
end
if isfield(params.elements,'Fe')
  Fe_C = C_molperl.*params.elements.Fe'; Fe_C = squeeze(sum(Fe_C,1));
end
if isfield(params.elements,'P')
  P_C = C_molperl.*params.elements.P'; P_C = squeeze(sum(P_C,1));
end

C_molperl = 1000*outflow_t./params.mol_mass'; % mols per m^2
Ca_O = C_molperl.*params.elements.Ca'; Ca_O = squeeze(sum(Ca_O,1));
Mg_O = C_molperl.*params.elements.Mg'; Mg_O = squeeze(sum(Mg_O,1));
K_O  = C_molperl.*params.elements.K';  K_O  = squeeze(sum(K_O ,1));
Na_O = C_molperl.*params.elements.Na'; Na_O = squeeze(sum(Na_O,1));
if isfield(params.elements,'Si')
  Si_O = C_molperl.*params.elements.Si'; Si_O = squeeze(sum(Si_O,1));  
end
if isfield(params.elements,'Fe')
  Fe_O = C_molperl.*params.elements.Fe'; Fe_O = squeeze(sum(Fe_O,1));  
end
if isfield(params.elements,'P')
  P_O = C_molperl.*params.elements.P'; P_O = squeeze(sum(P_O,1));
end

totCa = Ca_B + Ca_O + Ca_C*phi;
totMg = Mg_B + Mg_O + Mg_C*phi;
totK  =  K_B +  K_O +  K_C*phi;
totNa = Na_B + Na_O + Na_C*phi;
if isfield(params.elements,'Si')
  totSi = Si_B + Si_O + Si_C*phi;  
end
if isfield(params.elements,'Fe')
  totFe = Fe_B + Fe_O + Fe_C*phi;  
end
if isfield(params.elements,'P')
  totP = P_B + P_O + P_C*phi;  
end

totals.Ca = totCa;
totals.Mg = totMg;
totals.K  = totK;
totals.Na = totNa;
if isfield(params.elements,'Si')
  totals.Si = totSi;
end
if isfield(params.elements,'Fe')
  totals.Fe = totFe;
end
if isfield(params.elements,'P')
  totals.P = totP;
end

totals.Basalt.Ca = Ca_B;
totals.Basalt.Mg = Mg_B;
totals.Basalt.K  = K_B;
totals.Basalt.Na = Na_B;
if isfield(params.elements,'Si')
  totals.Basalt.Si = Si_B;
end
if isfield(params.elements,'Fe')
  totals.Basalt.Fe = Fe_B;
end
if isfield(params.elements,'P')
  totals.Basalt.P = P_B;
end

totals.Solution.Ca = Ca_C*phi;
totals.Solution.Mg = Mg_C*phi;
totals.Solution.K  =  K_C*phi;
totals.Solution.Na = Na_C*phi;
if isfield(params.elements,'Si')
  totals.Solution.Si = Si_C*phi;
end
if isfield(params.elements,'Fe')
  totals.Solution.Fe = Fe_C*phi;
end
if isfield(params.elements,'P')
  totals.Solution.P = P_C*phi;
end

totals.Outflow.Ca = outflowCa_t;
totals.Outflow.Mg = Mg_O;
totals.Outflow.K  = K_O;
totals.Outflow.Na = Na_O;
if isfield(params.elements,'Si')
  totals.Outflow.Si = Si_O;
end
if isfield(params.elements,'Fe')
  totals.Outflow.Fe = Fe_O;
end
if isfield(params.elements,'P')
  totals.Outflow.P = P_O;
end

totals.Precip.Ca = Ca_precip_t;

C_molperl = C_t./params.mol_mass';
Mg = C_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1));
K  = C_molperl.*params.elements.K';  K  = squeeze(sum(K ,1));
Na = C_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1));


if verbose
subplot(3,2,2)
plot(t,totCa,t,totMg,t,totK,t,totNa,'linewidth',2)
ylim([0 inf]);
title('min total mols');
hL = legend('Ca','Mg','K','Na');
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t(end)]); grid;
end

totCa2 = Ca_B+outflowCa_t+Ca_mass_precip_t+Ca_mass_sol_t;

if verbose
subplot(3,2,3)
plot(t,totCa2,t,Ca_B,t,outflowCa_t,t,Ca_mass_precip_t,t,Ca_mass_sol_t,'linewidth',2)
ylim([0 inf])
title('Ca mols')
hL = legend({'total','Basalt','outflow','CaCO_3','solution'});
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t(end)]); grid;
end

alk_sim = outflowCa_t + Mg_O + Na_O + K_O;
outElements.Ca = max(0,interp1(t,outflowCa_t,0:1/12:t(end)));
outElements.Mg = interp1(t,totals.Outflow.Mg,0:1/12:t(end));
outElements.Na = interp1(t,totals.Outflow.Na,0:1/12:t(end));
outElements.K  = interp1(t,totals.Outflow.K,0:1/12:t(end));

if verbose
subplot(3,2,4)
plot(t,outflowCa_t,t,Mg_O,t,K_O,t,Na_O,'linewidth',2)
ylim([0 inf]);
title('outflow mols');
hL = legend('Ca','Mg','K','Na');
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t(end)]); grid;
end

if verbose
subplot(3,2,6)
plot(t,B_mass_t,'linewidth',2)
title('Basalt (kg)')
hL = legend(params.names);
set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
xlim([0 t(end)]); grid;
end

%%

METHOD = 'linear';
x = ((1:length(data.CO2))-.5)/12;
CO2_ = interp1(x,data.CO2,t,METHOD,'extrap');

CDR2 = neta(CO2_,run_params.ocean_salinity,run_params.ocean_tmp).* ...
 (Na_O + K_O + 2*(Mg_O + Ca_mass_sol_t*0 + outflowCa_t)) + Ca_mass_precip_t;
RCO2_sim = CDR2*44./(b_mass*1000*ceil(t+1e-20));

CO2_mols = CDR2;
CO2_mols(1) = 0;

Application_Basalt_mass = b_mass*1000*floor([t(1:end-1),t(end)-1e-6]+1);

if verbose
  subplot(3,2,5)
  plot(t,RCO2_sim,'linewidth',2)
  title('CDR');
  set(hL,'Units',newUnits,'FontSize',fsl,'ItemTokenSize',its);
  xlim([0 t(end)]); grid;
end

nmins = length(params.names);
weathered_mass = (b_mass*params.mf(1:nmins)' - B_mass_t(:,end));
mol_frac_K = molMass('K')*params.elements.K./params.mol_mass;
weathered_K = mol_frac_K*weathered_mass;
mol_frac_P = molMass('P')*params.elements.P./params.mol_mass;
weathered_P = mol_frac_P*weathered_mass;

c2b_ratio = RCO2_sim(end);

%fprintf('\n');
%fprintf('Mass fraction of CO2 to Basalt %0.3f\n',c2b_ratio);
%fprintf('Mass fraction of wethered Basalt %0.2f%%\n',m2b_ratio*100);
%fprintf('Mass fraction of wethered potasium %0.6f\n',weathered_K/b_mass);
%fprintf('Mass of weathered potasium %0.3f g/m^2\n',weathered_K*1000);
%fprintf('Mass fraction of wethered phospherous %0.6f\n',weathered_P/b_mass);
%fprintf('Mass of weathered phospherous %0.3f g/m^2\n',weathered_P*1000);

Ca_sim = Ca_mass_precip_t;
%alk_sim = outflowCa_t + Mg_O + Na_O + K_O;

delm = (B_t(:,1) - B_t(:,end))*depth;
%c2b_ratio = sum(delm.*params.co2_ratio')/b_mass;
m2b_ratio = sum(delm)/(b_mass*ceil(tf));
% Check the test if employed
if strcmp(fd_params.test,'yes')
  test_error_percent = abs(m2b_ratio*100 - 76.42361);
  if (test_error_percent>.01)
    disp(fprintf('Failed the test with an error of %.3f%%.',test_error_percent));  
  else
    disp('Congratulations!!! You have passed the test.');
  end
end

if verbose
fprintf('CDR = %.3f%%\n',c2b_ratio*100);
end

% Calc amounts of weathered K and P (kg/m^2)

B_mass_t = [];
nmins = length(params.names);
for i=1:nmins
  for j=1:size(B_t,3)
    B_mass_t(i,j) = trapz(z,squeeze(B_t(i,:,j)));
  end
end

%%
delm = ceil(t).*B_mass_t(:,1) - B_mass_t;
delm(:,1) = 0;

K_frac = molMass2('K')*params.elements.K./params.mol_mass;
P_frac = molMass2('P')*params.elements.P./params.mol_mass;

K_mass = K_frac*delm;
P_mass = P_frac*delm;

c2b_ratio = interp1(t,RCO2_sim,(0:1/12:t(end)),'linear');
CO2_mass = interp1(t,CO2_mols*44,(0:1/12:t(end)),'linear');
CO2_mass_precip  = interp1(t,Ca_mass_precip_t*44,(0:1/12:t(end)),'linear');
CO2_mass_outflow = CO2_mass - CO2_mass_precip;
Application_Basalt_mass = interp1(t,Application_Basalt_mass,(0:1/12:t(end)),'linear');
K_mass = interp1(t,K_mass,(0:1/12:t(end)),'linear');
P_mass = interp1(t,P_mass,(0:1/12:t(end)),'linear');

charge_outflow = Na_O+K_O+Mg_O+outflowCa_t*phi;

xx = linspace(t(1),t(end),t(end)*12+1);
totals.Outflow.Ca_monthly_mols = diff(interp1(t,totals.Outflow.Ca,xx));
totals.Outflow.Mg_monthly_mols = diff(interp1(t,totals.Outflow.Mg,xx));
totals.Outflow.K_monthly_mols  = diff(interp1(t,totals.Outflow.K,xx));
totals.Outflow.Na_monthly_mols = diff(interp1(t,totals.Outflow.Na,xx));
if isfield(params.elements,'Si')
  totals.Outflow.Si_monthly_mols = diff(interp1(t,totals.Outflow.Si,xx));
end
if isfield(params.elements,'Fe')
  totals.Outflow.Fe_monthly_mols = diff(interp1(t,totals.Outflow.Fe,xx));
end
if isfield(params.elements,'P')
  totals.Outflow.P_monthly_mols  = diff(interp1(t,totals.Outflow.P,xx));
end













