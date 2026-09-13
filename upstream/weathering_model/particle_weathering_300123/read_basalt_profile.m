function basalt = read_basalt_profile(fname,headerlines,headerlabels)
% Arguments: fname = string, headerlines = integer, headerlabels = integer.
% The read basalt file must contain one header record with entries
% 'Diameter', 'q' and 'CDF' and this record is given by 'headerlabels'.

fid = fopen(fname);
if fid <= 0
  error('''read_basalt'' input file does not exist: %s',fname); 
end

a = read_csv(fname,headerlines,headerlabels);

fclose(fid);

if a.Diameter > 0
    a.Diameter = [0; a.Diameter];
    a.CDF = [0; a.CDF];
    a.q = [0; a.q];
end

basalt.q = a.q/sum(a.q);
basalt.cdf = a.CDF/a.CDF(end)*100;
basalt.radius_max = a.Diameter/2*1e-6;

basalt.radius_avg = (basalt.radius_max + [0; basalt.radius_max(1:end-1)])/2;

