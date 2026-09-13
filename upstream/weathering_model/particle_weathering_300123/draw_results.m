function draw_results( ...
    fid,params,run_params,data,Delz,soil_CO2,RCO2_t,totals,alk_t,B_t,C_t,H_t,outflow_t,R_t,Cf_t,mass,z,t, ...
    Ca_sol_t,Ca_precip_t,phi,pH_t,depth,outflowCa_t,outflowH_t,swvf_t,Ca_sat_t,alk2pH)

imin = 1;
tf = t(end);

C_molperl = C_t./params.mol_mass';
Mg = C_molperl.*params.elements.Mg'; Mg = squeeze(sum(Mg,1));
K  = C_molperl.*params.elements.K';  K  = squeeze(sum(K ,1));
Na = C_molperl.*params.elements.Na'; Na = squeeze(sum(Na,1));

mass_imin = mass*params.mf(imin);

B_mass_t = []; C_mass_t = []; Ca_mass_t = []; Ca_mass_sol_t = []; Ca_mass_precip_t = [];
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
end

pH0_ax = 4; pHf_ax = 10;

C = squeeze(C_t(imin,:,:));
B = squeeze(B_t(imin,:,:));
R = squeeze(R_t(imin,:,:));
Cf = squeeze(Cf_t(imin,:,:));
B_mass = squeeze(B_mass_t(imin,:,:));
outflow = squeeze(outflow_t(imin,:));
pH = pH_t;

make_text_boxes_2;

Ca0 = 0; Caf = 0; 
for i=1:length(params.names)
  Ca0 = Ca0 + 1000*trapz(z,B_t(i,:,1  ))/params.mol_mass(1)/phi*params.elements.Ca;
  Caf = Caf + 1000*trapz(z,B_t(i,:,end))/params.mol_mass(1)/phi*params.elements.Ca;
end

%ca_per_error = ((Ca0 - Caf) - (1000*trapz(z,Ca_sol_t(:,end))*phi + outflowCa_t(end))) ...
%    /(Ca0 - Caf)*100;
%disp([sprintf('Ca Mass Balance error = %.2f',ca_per_error),'%']);
%ca_per_error = ((Ca0 - Caf) - (1000*trapz(z,Ca_sol_t(:,end))*phi + outflowCa_t(end) + 1000*trapz(z,Ca_precip_t(:,end))*phi)) ...
%    /(Ca0 - Caf)*100;
%disp([sprintf('Ca Mass Balance error = %.2f',ca_per_error),'%']);
%1000*trapz(z,Ca_sol_t(:,end))*phi + outflowCa_t(end) + 1000*trapz(z,Ca_precip_t(:,end))*phi

%animate_2(t1,p1,p2,p3,p4,p5,l1,lpH,l3,l_H,l_Mg,l_K,l_Na,l_Ca, ...
%  params,imin,mass,axcx,phi,depth,pH_t,outflow_t,B_t,C_t,R_t,Cf_t,Ca_sol_t,Ca_precip_t,Ca_sat_t,H_t,z,t);

global Gt1 Gp1 Gp2 Gp3 Gp4 Gp5 Gl1 GlpH Gl3 Gl_H Gl_Mg Gl_K Gl_Na Gl_Ca  ... 
 Gl_alk Gl_alk0 Gl_yield Gl_N Gl_CO2 ...
 Gparams Gimin Gmass Gaxcx Gphi Gdepth GpH_t Goutflow_t ...
 Galk_t GB_t GC_t GR_t GCf_t GCa_sol_t GCa_precip_t GCa_sat_t GH_t Gz Gt ...
 Gmineral_selection Gmineral_title Gswvf_t;

Gt1 = t1;
Gp1 = p1;
Gp2 = p2;
Gp3 = p3;
Gp4 = p4;
Gp5 = p5;
Gl1 = l1;
GlpH = lpH;
Gl3 = l3;
Gl_Mg = l_Mg;
Gl_K = l_K;
Gl_Na = l_Na;
Gl_Ca = l_Ca;

Gl_alk   = l_alk;
Gl_alk0  = l_alk0;
Gl_yield = l_yield;
Gl_N     = l_N;
Gl_CO2   = l_CO2;

Gparams = params;
Gimin = imin;
Gmass = mass;
Gaxcx = axcx;
Gphi = phi;
Gdepth = depth;
GpH_t = pH_t;
Goutflow_t = outflow_t;

Galk_t = alk_t;
GB_t = B_t;
GC_t = C_t;
GR_t = R_t;
GCf_t = Cf_t;
GCa_sol_t = Ca_sol_t;
GCa_precip_t = Ca_precip_t;
GCa_sat_t = Ca_sat_t;
GH_t = H_t;
Gz = z;
Gt = t;

Gmineral_selection = mineral_selection;
Gmineral_title = mineral_title;

Gswvf_t = swvf_t;


