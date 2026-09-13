function [el,st2] = str_get_element(st1)
% get number

Alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
alpha = 'abcdefghijklmnopqrstuvwxyz';

%get number
if contains(Alpha,st1(1))
  j = 1;
  el(1) = st1(1);
  for i=2:length(st1)
    if contains(alpha,st1(i))
      j = j + 1;
      el(j) = st1(i);
    else
      break
    end
  end
  st2 = st1(j+1:end);
else
  el = [];
  st2 = [];
  disp(['''',st1,'''']);
  error('First letter of element is not capital.');
end
