function check_linear = check_for_lines(xx,yy,x)
pts=[xx'/max(xx);yy'/max(yy)];

ii = find(xx >= x); 
i = ii(1);

if xx(i) == x
  check_linear = 1;
%  'same x'
  return
end

if length(xx) <=3
  check_linear = 1;
  return
end

check_linear = 0;

if yy(i-1) == yy(i)
%  'same'
  check_linear = 1;
end

if i<=length(xx) & i-2>=1
pts2 = pts(:,i-2:i);
v1 = pts2(:,1)-pts2(:,2);
v2 = pts2(:,2)-pts2(:,3);
theta = acosd(v1'*v2/norm(v1)/norm(v2));
if (abs(theta) < 1e-3) | (abs(180 - theta) < 1e-4)
%  'backwards line'
  check_linear = 1;
end
end

if i+1<=length(xx) & i>=1
pts2 = pts(:,i-1:i+1);
v1 = pts2(:,1)-pts2(:,2);
v2 = pts2(:,2)-pts2(:,3);
theta = acosd(v1'*v2/norm(v1)/norm(v2));
if (abs(theta) < 1e-3) | (abs(180 - theta) < 1e-4)
%  'forwards line'
  check_linear = 1;
end
end
