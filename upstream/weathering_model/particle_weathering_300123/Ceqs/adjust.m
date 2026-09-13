load('Ceq_table_Oregon_Ceq')
size(Ceq_table.values)
Ceq_table.values(:,:,8:9) = 1e10;
save('Ceq_table_Oregon')