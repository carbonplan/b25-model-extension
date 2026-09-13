function [allEls,allNums,MM] = parse_formula(f)

% parse brackets
iter = 0;
indOpen = strfind(f,'(');
%for i=1:1
allEls = {}; allNums = [];
for i=1:length(indOpen)
  iter = iter + 1;
  indClose = strfind(f,')');
  st1 = f(indClose(1)+1:end);
  [num,st2]=str_get_number(st1);
  enps = f(indOpen(1)+1:indClose(1)-1);
  f = [f(1:indOpen(1)-1),st2];
  indOpen = strfind(f,'(');
  [els,nums]=str_get_element_number_pairs(enps);
  allEls = [allEls,els];
  allNums = [allNums,nums*num];
end
[els,nums]=str_get_element_number_pairs(f);
allEls = [allEls,els];
allNums = [allNums,nums];

MM = 0;
for i=1:length(allEls)
  MM = MM + molMass2(allEls{i})*allNums(i);
end

