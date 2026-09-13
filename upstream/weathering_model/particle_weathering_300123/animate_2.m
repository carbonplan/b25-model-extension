function animate_2
%(t1,p1,p2,p3,p4,p5,l1,lpH,l3,l_H,l_Mg, ...
%    l_K,l_Na,l_Ca,params,imin,mass,axcx,phi,depth,pH_t,outflow_t, ...
%    B_t,C_t,R_t,Cf_t,Ca_sol_t,Ca_precip_t,Ca_sat_t,H_t,z,t)

global GM Gt1 Gp1 Gp2 Gp3 Gp4 Gp5 Gl1 GlpH Gl3 Gl_Mg Gl_K Gl_Na Gl_Ca Gl_alk ...
 Gl_alk0 Gl_yield Gl_N Gl_CO2 ...
 Gparams Gimin Gmass Gphi Gdepth GpH_t Goutflow_t ...
 Galk_t GB_t GC_t GR_t GCf_t GCa_sol_t GCa_precip_t GCa_sat_t GH_t Gz Gt ...
 Gmineral_selection Gmineral_title Gswvf_t;

t1 = Gt1;
p1 = Gp1;
p2 = Gp2;
p3 = Gp3;
p4 = Gp4;
p5 = Gp5;
l1 = Gl1;
lpH = GlpH;
l3 = Gl3;

l_Mg = Gl_Mg;
l_K  = Gl_K;
l_Na = Gl_Na;
l_Ca = Gl_Ca;

l_alk   = Gl_alk;
l_alk0  = Gl_alk0;
l_yield = Gl_yield;
l_N     = Gl_N;
l_CO2   = Gl_CO2;

params = Gparams;
imin = Gimin;
mass = Gmass;
phi = Gphi;
depth = Gdepth;
pH_t = GpH_t;
outflow_t = Goutflow_t;
alk_t = Galk_t;
B_t = GB_t;
C_t = GC_t;
R_t = GR_t;
Cf_t = GCf_t;
Ca_sol_t = GCa_sol_t;
Ca_precip_t = GCa_precip_t;
Ca_sat_t = GCa_sat_t;
H_t = GH_t;
swvf_t = Gswvf_t;
z = Gz;
t = Gt;

mineral_selection = Gmineral_selection;
mineral_title = Gmineral_title;

imin = mineral_selection.Value;

aniLength = 50;
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

axcx = 25;
mineral_title.String = params.names(imin);

GM = getframe;

mnth = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

for i=1:1:length(t)
  Ca0 = 1000*trapz(z,B_t(1,:,1  ))/params.mol_mass(1)/phi*params.elements.Ca;
  Caf = 1000*trapz(z,B_t(1,:,i))/params.mol_mass(1)/phi*params.elements.Ca;
%  ca_per_error = ((Ca0 - Caf) - (1000*trapz(z,Ca_sol_t(:,i))*phi + outflowCa_t(i) + 1000*trapz(z,Ca_precip_t(:,i))*phi)) ...
%    /(Ca0 - Caf)*100;
  sol_mass = trapz(z,C(:,i))*phi;
  Bas_mass = trapz(z,B(:,i));
  p1.Vertices = [[0; C(:,i); 0],[0; z; depth]];
  p2.Vertices = [[0; B(:,i); 0],[0; z; depth]];
  p3.Vertices = [[0; Ca_sol_t(:,i); 0],[0;z;depth]];
  p4.Vertices = [[0; Ca_precip_t(:,i); 0],[0;z;depth]];
  p5.Vertices = [[0; Na(:,i)*0+swvf_t(i)/depth; 0],[0;z;depth]];
  l1.XData = Cf(:,i);
  lpH.XData = (pH(:,i) - pH0_ax)/(pHf_ax - pH0_ax)*axcx;
  l3.XData = Ca_sat_t(:,i);
    
  l_alk0.XData  = alk_t(2,:,i);
  l_yield.XData = alk_t(3,:,i);
  l_N.XData     = alk_t(4,:,i);
  
  l_Ca.XData = alk_t(5,:,i);
  l_Mg.XData = alk_t(6,:,i);
  l_K.XData  = alk_t(7,:,i);
  l_Na.XData = alk_t(8,:,i);
  
  l_alk.XData   = alk_t(1,:,i);

  l_CO2.XData = alk_t(9,:,i);

  imnth = mod(floor(t(i)*12-1e-6),12) + 1;
  idate = mod(floor(t(i)*360-1e-6),30) + 1;
  t1.String = {sprintf(...
    '%s %3d\nYear: %0.2f\nmin: %0.2f\nSol min: %0.2f\nOutflow min: %0.2f\n', ...
    mnth{imnth},idate,t(i),Bas_mass,sol_mass,outflow(i))};
  
  textp11.String = {'Solution Min',sprintf('%0.3f kg',sol_mass)};
  textp12.String = {'Outflow Min',sprintf('%0.3f kg',outflow(i))};
%  textp13.String = {'System Ca Error',sprintf('%0.1f %s',ca_per_error,'%')};
  textp21.String = {'Time',sprintf('%0.2f yrs',t(i))};
  textp22.String = {'Min',sprintf('%0.3f kg',Bas_mass)};
  textp23.String = {'System Min Error',sprintf('%0.1f %s',((sol_mass+outflow(i)+Bas_mass)/(mass_imin*ceil(t(i)))-1)*100,'%')};
  drawnow;
%  pause(.1);
%  pause(aniLength/length(t)/2*0);

  GM(i) = getframe(gcf);
end

