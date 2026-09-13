function  Ceq=Ceq_comp(params,tmp,flowrate,basalt,affinity,eq_phase)

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
  for j=1:length(tmp)
    xtmp = tmp(j);
    if tmp>Ceq_table.tmp(end); xtmp=Ceq_table.tmp(end); end
    if tmp<Ceq_table.tmp(1); xtmp=Ceq_table.tmp(1); end
    for i=1:size(Ceq_table.values,3)
      Ceq(j,i) = interp2(Ceq_table.flowrate,Ceq_table.tmp,Ceq_table.values(:,:,i),xflowrate,xtmp,METHOD);
    end
  end
else
  Ceq = 1e10*ones(1,length(params.names));
end
