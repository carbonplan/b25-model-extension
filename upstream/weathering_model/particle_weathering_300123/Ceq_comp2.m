function  Ceq=Ceq_comp2(params,tmp,flowrate,basalt,affinity,eq_phase)

if strcmp(affinity,'yes')
  if strcmp(eq_phase,'Kaolinite')
    load(['Ceqs/Ceq_table_',basalt,'_Kaolinite']);
  elseif strcmp(eq_phase,'Montmorillonite-Ca')
    load(['Ceqs/Ceq_table_',basalt,'_Montmorillonite-Ca']);
  else
    load(['Ceqs/Ceq_table_',basalt]); 
  end
  
  METHOD = 'linear';

  Ceq = zeros(length(tmp),size(Ceq_table.values,3));
  xflowrate = flowrate;
  if flowrate>Ceq_table.flowrate(end); xflowrate = Ceq_table.flowrate(end); end
  if flowrate<Ceq_table.flowrate(1); xflowrate = Ceq_table.flowrate(1); end
  
  tmp(tmp>Ceq_table.tmp(end)) = Ceq_table.tmp(end);
  tmp(tmp<Ceq_table.tmp(1)) = Ceq_table.tmp(1);

  for i=1:size(Ceq_table.values,3)
    Ceq(:,i) = interp2(Ceq_table.flowrate,Ceq_table.tmp,Ceq_table.values(:,:,i),xflowrate,tmp,METHOD);
  end
else
  Ceq = 1e10*ones(length(tmp),length(params.names));
end

ii = find(strcmp(params.names,'Kfeldspar') == 1);
if length(ii) == 1
  Ceq(:,ii) = 0.3;
end
