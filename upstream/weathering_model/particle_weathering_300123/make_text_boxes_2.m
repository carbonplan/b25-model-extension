margin = [.04 .04 0.03 .02];
border = [.3  0.0 0 .4];

% add animate button
%h = setPlotGrid(fid,900,900,3,12,margin,border);
h = setPlotGrid(fid,900,900,4,16,margin,border);

%btn = uicontrol('Parent',gcf);
%btn.Callback = 'animation_2'

btn = uicontrol('parent',gcf,'String','Animate','Units','normalized','Style','pushbutton','Callback','animate_2');
btn.BackgroundColor = [1 .2 .2];
btn.Position = [.05 .02 .2 .05];
btn.FontSize = 12;
btn.FontWeight = 'bold';

mineral_selection = uicontrol('parent',gcf,'Units','normalized','Style','popupmenu');
mineral_selection.Position = [.28 .01 .2 .05];
mineral_selection.String = params.names;
mineral_selection.FontSize = 12;

col = [0 .8 0; .8 0 0; 1 0 1; 0 0 1; .9 .9 0;];
fs  = 9;
fsl = 6;
fsm = 9;
fse = 9;
lw  = 2;
its = [4 1];

bcol = [.5 .3 .2];
scol = [.1 .1 .8];
ocol = [.4 .4 .4];
cacol = [0 .8 0];
syscol = [1 0 0];
tcol = [0 0 0];

newUnits = 'normalized';

x=[1:10];
y=rand(3,10);

colMins = [
 2 0 0
 0 2 0
 0 0 2
 2 2 0
 2 0 2
 0 2 2
 0 0 0
 1 0 0
 0 1 0
 0 0 1
 2 1 0
 1 2 1
 1 1 1
 ]/2;

colEls = [
  128 0 0
  128 128 0
  0 128 0
  0 0 128
  0 128 128
  128 0 128
]/128;


set(h(1),'visible','off');
set(h(2),'visible','off');
axes(h(1));
t1 = text(0,.4,0,{'time = 0';'mass = 1.5kg'});

axes(h(3));
l_CO2 = line(soil_CO2,z,'linewidth',2);
grid;
title('Soil CO_2')
set(gca,'fontsize',fs,'box','on','Ydir','reverse');
ytickformat('%0.2f');
xlim([0 5000]);

%% Draw pH vs alk functions
axes(h(4));
alk = -.1:.001:.1;
if strcmp(run_params.buffer,'yes')
  pH0 = alk2pH(0*alk+min(soil_CO2),alk);
  pHf = alk2pH(0*alk+max(soil_CO2),alk);
  plot(pH0,alk,'-g',pHf,alk,'-r','linewidth',2); grid;
  load('alk2pH_function.mat');
  pH0 = alk2pH(0*alk+min(soil_CO2),alk);
  pHf = alk2pH(0*alk+max(soil_CO2),alk);
  hold on
  plot(pH0,alk,':g',pHf,alk,':r','linewidth',2);
  hold off
  alk2pH = @alk2pH_buffer;
  set(gca,'fontsize',fs,'box','on')
  title('Alk2pH (buff)');
  leg_4 = legend({'buff_0','buff_f',num2str(min(soil_CO2),'%0.0f'), ...
 num2str(max(soil_CO2),'%0.0f')},'location','northeastoutside');
else
  pH0 = alk2pH(0*alk+min(soil_CO2),alk);
  pHf = alk2pH(0*alk+max(soil_CO2),alk);
  plot(pH0,alk,'-g',pHf,alk,'-r','linewidth',2);
  title('Alk2pH (buff)');
  leg_4 = legend({num2str(min(soil_CO2),'%0.0f'), ...
 num2str(max(soil_CO2),'%0.0f')},'location','northeastoutside');
end
set(leg_4,'itemtokensize',its,'fontsize',fsl)
ylabel('alk mol/l');
xlabel('pH');
xlim([0 14]);
ytickformat('%0.2f');

%axes(h(8));
%plot(H_t(:,end),z,'linewidth',2);
%title('H+ final');
%set(gca,'fontsize',fs,'box','on','YDir','reverse');
%ytickformat('%0.2f');

%% Draw specific mineral in solution
axes(h(5));
axcx = max(max(max(C)));
axcx = 10;
axis([-axcx axcx 0 depth]); 
set(gca,'YDir','reverse','fontsize',fs,'box','on');
xlabel('Concentration');
ylabel('Depth'); title('Solution');
ytickformat('%0.2f');

p1 = patch([0; z*0; 0],[0; z; 2],scol);
l1 = line(z*0,z);
l1.LineWidth = 2;
l1.Color = [1 1 0];
l1.LineStyle = ':';


%% Draw specific mineral in basalt
axes(h(6));
axcx = B_t(imin,1,1); 
axcx = 25;
axis([0 axcx 0 depth]); set(gca,'YDir','reverse','fontsize',fs,'box','on');
xlabel('Concentration'); 
ylabel('Depth'); 
mineral_title = title(params.names{imin});
p2 = patch([0; z*0; 0],[0; z; 2],bcol);
ytickformat('%0.2f');

% Draw pH
for i=pH0_ax+1:pHf_ax-1
  line((i-pH0_ax)*axcx/(pHf_ax - pH0_ax)*[1 1],[0 1],'Color',[0 0 0],'LineStyle',':','Linewidth',1);
end
lpH = line(axcx*(pH_t(:,1)-pH0_ax)/(pHf_ax - pH0_ax),z);
lpH.LineWidth = 1.5;
lpH.Color = [1 0 0];
lpH.LineStyle = '-';

%% Draw alk/charge
axes(h(7));
axcx = max(max(max(max(alk_t(1:8,:,:)))),abs(min(min(min(alk_t(1:8,:,:))))));
axis([-axcx axcx 0 depth]);
set(gca,'YDir','reverse','fontsize',fs,'box','on');
xlabel('+ mol/l');
title('Charge');

l_Ca = line(z*0,z); l_Ca.LineWidth = 2; l_Ca.Color = colEls(1,:); l_Ca.LineStyle = ':';
l_Mg = line(z*0,z); l_Mg.LineWidth = 2; l_Mg.Color = colEls(4,:); l_Mg.LineStyle = ':';
l_K  = line(z*0,z); l_K.LineWidth  = 2; l_K.Color  = colEls(3,:); l_K.LineStyle  = ':';
l_Na = line(z*0,z); l_Na.LineWidth = 2; l_Na.Color = colEls(2,:); l_Na.LineStyle = ':';

l_alk0  = line(z*0,z); l_alk0.LineWidth  = 2; l_alk0.Color  = [0 0 0]; l_alk0.LineStyle   = '-';
l_yield = line(z*0,z); l_yield.LineWidth = 2; l_yield.Color = [0 1 0]; l_yield.LineStyle  = '-';
l_N     = line(z*0,z); l_N.LineWidth     = 2; l_N.Color     = [0 0 1]; l_N.LineStyle      = '-';
l_alk   = line(z*0,z); l_alk.LineWidth   = 2; l_alk.Color   = [1 0 0]; l_alk.LineStyle    = '-';

leg = legend([l_alk,l_alk0,l_N,l_yield],'alk','alk0','H+','acidi','location','northeastoutside');
set(leg,'ItemTokenSize',[4 1],'fontsize',fsl);
ytickformat('%0.2f');
xlim([-1 1]*10e-2);

%% Draw Ca in solution
axes(h(9));
axca = max(max(Ca_sol_t)); 
axca = 100e-4; 
if axca == 0; axca = 1; end
axis([-axca axca 0 depth]); 
set(gca,'YDir','reverse','fontsize',fs,'box','on');
%xlabel('Concentration'); 
ylabel('Depth'); title('Ca Solution');
ytickformat('%0.2f');

p3 = patch([0; z*0; 0],[0; z; 2],scol);
l3 = line(z*0,z);
l3.LineWidth = 2;
l3.Color = [1 1 0];
l3.LineStyle = ':';

axca = max(max(Ca_precip_t));
axca = .5;
if axca == 0; axca = 1; end

%% Draw Ca precipitate
axes(h(10));
axis([-axca axca 0 depth]); 
set(gca,'YDir','reverse','fontsize',fs,'box','on');
xlabel('Concentration'); ylabel('Depth'); title('Ca Precip');
p4 = patch([0; z*0; 0],[0; z; 2],bcol);
ytickformat('%0.2f');

%% Draw minerals
axes(h(11));
%figure(35)
if 1
  for i=1:size(B_mass_t,1)
    line(t,B_mass_t(i,:),'color',colMins(i,:),'linewidth',lw);
  end
  xlim([0 t(end)]);
  ylabel('Areal Density (kg/m^2)'); title('Minerals');
%  ylim([0 max(max(B_mass_t))]);
  set(gca,'fontsize',fs,'box','on');
else
  plot(t,B_mass_t/depth/phi./params.mol_mass','linewidth',2); xlim([0 t(end)]);
  ylabel('moles minmeral/L porewater'); title('Minerals');
  set(gca,'fontsize',12);
end
%legend(params.names,'location','northeastoutside'); ylim([0 inf])
ytickformat('%0.1f');
ylim([0 inf]);
grid


%% Plot mineral mass balance
axes(h(12));
linesMins = gobjects;
for i=1:size(totals.tot,1)
  linesMins(i)=line(t,totals.tot(i,:),'color',colMins(i,:),'linewidth',lw);
end
title('Min Balance')
set(gca,'fontsize',fs,'box','on')
ytickformat('%1.1f');
ylim([0 inf]);
grid

%% Draw Na in solution
axes(h(13))
axna = max(max(Na)); 
axna = run_params.wfp*2;
if axna == 0; axna = 1; end
axis([0 axna 0 depth]); 
set(gca,'YDir','reverse','fontsize',fs,'box','on');
%xlabel('Concentration'); 
ylabel('Depth'); title('Sol Vol Frac');
p5 = patch([0; z*0; 0],[0; z; 2],scol);
hold on
  plot(run_params.wfp*[1 1],[0 depth],'r-','linewidth',2)
hold off

ytickformat('%0.2f');

%% Draw RCO2
axes(h(14))
plot(t,RCO2_t*100,'linewidth',2)
title('RCO_2 (%)');
set(gca,'fontsize',fs,'box','on');
grid

%% Draw Drivers
axes(h(15))
tf = t(end);
x = (1:tf*12)/12-1/24;
if tf>1/12
  NFlux = sum(data.N.Flux(1:length(x),:),2)/size(data.N.Flux,2);
  NFluxMax = max(max(NFlux),-min(NFlux));

  plot(x,data.tmp(1:length(x))/max(data.tmp(1:length(x))), ...
    x,data.npp(1:length(x))/max(data.npp(1:length(x))), ...
    x,data.yield(1:length(x))/max(data.yield(1:length(x))), ...
    x,data.soilresp(1:length(x))/max(data.soilresp(1:length(x))), ...
    x,data.flowrate(1:length(x))/max(data.flowrate(1:length(x))), ...
    x,NFlux/NFluxMax, ... 
'linewidth',2);
  set(gca,'fontsize',fs,'box','on')

  ylim([-1 1]);
  leg = legend({ ...
    ['t: ',num2str(max(data.tmp(1:length(x))),'%0.0f')], ...
    ['n: ',num2str(max(data.npp(1:length(x))),'%0.0f')], ...
    ['y: ',num2str(max(data.yield(1:length(x))),'%0.0f')], ...
    ['r: ',num2str(max(data.soilresp(1:length(x))),'%0.0f')], ...
    ['f: ',num2str(max(data.flowrate(1:length(x))),'%0.1f')], ...
    ['N: ',num2str(NFluxMax*1e6,'%0.1f')]},'location','northeastoutside');
  set(leg,'ItemTokenSize',its,'fontsize',fsl);
  ytickformat('%0.1f');
end
title('Montlhy Drivers');
grid;


%% Draw element mass balance
axes(h(16));
linesEls = gobjects;
linesEls(1) = line(t,totals.Ca,'color',colEls(1,:),'linewidth',lw,'linestyle',':');
linesEls(2) = line(t,totals.Na,'color',colEls(2,:),'linewidth',lw,'linestyle',':');
linesEls(3) = line(t,totals.K, 'color',colEls(3,:),'linewidth',lw,'linestyle',':');
linesEls(4) = line(t,totals.Mg,'color',colEls(4,:),'linewidth',lw,'linestyle',':');
title('El Balance')
set(gca,'fontsize',fs,'box','on')
ytickformat('%1.1f')

% Draw legends
legMins = legend(linesMins,params.names);
axx = [.35 .80 .05 .15];
set(legMins,'Position',axx,'Units',newUnits,'FontSize',fsm,'ItemTokenSize',its,'box','off');
legEls = legend(linesEls,{'Ca','Na','K','Mg'});
axx = [.45 .80 .05 .15];
set(legEls,'Position',axx,'Units',newUnits,'FontSize',fse,'ItemTokenSize',its,'box','off');
grid




