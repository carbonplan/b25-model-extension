function output = read_csv(varargin)
% Args: filename [ no. of header lines [ line number of labels ]]
% Read a csv file that contains a line of labels witin the header,
% which are used as field names for the output structure: these 
% must be unique, and blank fields are allowed and ignored.
% Default: no. of header lines = 1: line number of labels = 1

% Parse optinal input arguments.
nargs = length(varargin);
if nargs < 1 || nargs > 3
  error('Between 1 and 3 arguemnts needed: filename, headerlines, line number of field names.');
end
fname = varargin{1};
headerlines = 1;
ifieldnames = 1;
if nargs == 2
  headerlines = varargin{2};    
elseif nargs == 3
  headerlines = varargin{2};    
  ifieldnames = varargin{3};    
end

% Check file exists.
fid = fopen(fname);
if (fid <= 0)
  error('Filename does not exist ''%s''',fname);
end

% Read in and process the file.
for i=1:headerlines
  if i == ifieldnames
% Get fieldnames
    fieldnames = textscan(fgetl(fid),'%s','Delimiter',',');
    fieldnames = fieldnames{1};
    fieldnames = strrep(fieldnames,' ','_');
    ii = strcmp(fieldnames,'');
    nfields = length(fieldnames);
  else
    fgetl(fid);
  end
end
a = textscan(fid,repmat('%s',1,nfields),'Delimiter',',');
fclose(fid);

% Set the output structure and data.
output = [];
for i=1:nfields
  if ~isempty(fieldnames{i})
    output.(fieldnames{i}) = a{i}(:);
  end
end

% Recast the cell strings to double where possible.
for j=1:length(fieldnames)
  if ~isempty(fieldnames{j})
    n = length(output.(fieldnames{j}));
    check = 1;  fieldi = zeros(n,1);
    for i=1:n
      ans1 = str2double(output.(fieldnames{j}){i});
      if isnan(ans1)
        check = 0; break
      end
      fieldi(i,1) = ans1;
    end
    if check
      output.(fieldnames{j}) = fieldi;
    end
  end
end

% Check the structure of the csv file.
a = read_file(fname);
for i=headerlines:length(a)
  if ~isempty(a{i})
    mfields = sum(a{i} == ',') + 1;
    if mfields ~= nfields
      fprintf(2,'Warning: line %d has %d fields, %d were expected.\n',i,mfields,nfields);
    end
  end
end



 