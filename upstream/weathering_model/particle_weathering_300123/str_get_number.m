function [num,st2] = str_get_number(st1)
% get number

numeric = '01234567890.';
alpha= 'ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

%get number
j = 0; num = '';
for i=1:length(st1)
  if contains(numeric,st1(i))
    j = j + 1;
    num(j) = st1(i);
  else
    break
  end
end
st2 = st1(j+1:end);

if isempty(num)
  num = 1;
else
  num = str2num(num);
end