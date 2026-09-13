function h = read_file(fname)

fid = fopen(fname);
if fid <= 0
  error('Filename does not exist ''%s''',fname); 
end
g = textscan(fid,'%s','delimiter','\n');
fclose(fid);

h = {};
for i=1:length(g{1})
  h{i,1} = g{1}{i};
end
