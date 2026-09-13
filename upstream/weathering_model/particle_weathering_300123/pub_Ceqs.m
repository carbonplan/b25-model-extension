%clear
%load('Ceq_table_Blue_Ridge_2')

lfs = 8;

for imin =1:size(Ceq_table.values,3)
%for imin=4:4
  xxx = Ceq_table.values(:,:,imin);
  xxx(xxx > 999) = NaN;

  if sum(sum(~isnan(xxx))) > 0
  
  figure('position',[0 0 600 300]);

  subplot(1,2,1)
  h =  plot(Ceq_table.tmp,xxx,'-o','linewidth',2);
  for i=1:length(h); h(i).MarkerFaceColor = h(i).Color; end
  lfr = {};
  for i=1:length(Ceq_table.flowrate)
    lfr{i} = sprintf('fr = %.2f',Ceq_table.flowrate(i));
  end
  l1 = legend(lfr);
  l1.ItemTokenSize = [10 10]; l1.FontSize = lfs;
  title(strrep(fname,'_',' '));
  ylabel('Ceq');
  xlabel('temperature'); xlim([Ceq_table.tmp(1),Ceq_table.tmp(end)]);
  set(gca,'fontsize',12,'fontweight','bold')

  subplot(1,2,2)
  h = plot(Ceq_table.flowrate,xxx','-o','linewidth',2);
  for i=1:length(h); h(i).MarkerFaceColor = h(i).Color; end
  ltmp = {};
  for i=1:length(Ceq_table.tmp)
    ltmp{i} = sprintf('tmp = %.0f',Ceq_table.tmp(i));
  end
  l2 = legend(ltmp);
  l2.ItemTokenSize = [10 10]; l2.FontSize = lfs;
  title(params.names{imin});
  ylabel('Ceq');
  xlabel('flowrate'); xlim([Ceq_table.flowrate(1),Ceq_table.flowrate(end)]);
  set(gca,'fontsize',12,'fontweight','bold')
  end
end


for itmp=1:size(B_rtm_all,3)
  for iflowrate=1:size(B_rtm_all,4)
%for itmp=1:2
%  for iflowrate=1:2

B_rtm = B_rtm_all(:,:,itmp,iflowrate);
B_sim = B_sim_all(:,:,itmp,iflowrate);
B_sim2 = B_sim2_all(:,:,itmp,iflowrate);

figure('position',[0 0 600 450]);
subplot(2,2,3)
plot(t_all,B_rtm,'linewidth',2); title('RTM'); grid
set(gca,'fontsize',10,'fontweight','bold')
ylim([0 inf])
subplot(2,2,4)
plot(t_all,B_sim2,'linewidth',2); title('SIM (+Ceq)'); grid
set(gca,'fontsize',10,'fontweight','bold')
ylim([0 inf])
subplot(2,2,2)
plot(t_all,B_sim,'linewidth',2); title('SIM'); grid
set(gca,'fontsize',10,'fontweight','bold')
ylim([0 inf])
subplot(2,2,1)
set(gca,'fontsize',10,'fontweight','bold')
plot(t_all,B_sim*nan,'linewidth',2); title('SIM (-Ceq)'); grid
set(gca,'visible','off','fontsize',10,'fontweight','bold')
l = legend(params.names,'location','southeast');
l.ItemTokenSize = [10 5]; l.FontSize = lfs;
text(0,1,strrep(params.name,'_',' '),'fontsize',10,'fontweight','bold')
text(0,.9,['tmp = ',num2str(Ceq_table.tmp(itmp))],'fontsize',10,'fontweight','bold')
text(0,.8,['fr  = ',num2str(Ceq_table.flowrate(iflowrate))],'fontsize',10,'fontweight','bold')

  end
end




