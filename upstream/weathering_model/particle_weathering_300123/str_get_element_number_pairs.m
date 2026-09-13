function [els,nums]=str_get_element_number_pairs(st2)

els = {}; nums = [];
while ~isempty(st2)>0
%  disp(st2)
  [el, st2] = str_get_element(st2);
  molMass2(el);
  [num,st2] = str_get_number(st2);
  els = [els,el];
  nums = [nums,num];
end
