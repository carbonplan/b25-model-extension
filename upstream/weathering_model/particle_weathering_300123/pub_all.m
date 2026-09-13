filenames = {'Blue_Ridge_2'}
filenames = {'Blue_Ridge_2_short'}
for i=1:length(filenames)
  fname = filenames{i}; load(['Ceqs\Ceq_table_',fname]);
  publish('pub_Ceqs','format','doc','showCode',false,'outputDir','Ceqs\docs'); close('all');
  str = ['movefile Ceqs\docs\pub_Ceqs.doc Ceqs\docs\',fname,'.doc']; eval(str);
end
