function yyy=interp1_MRL2(xx,yy,xxx)

a = unique2d([xx,yy]);
xx = a(:,1);
yy = a(:,2);

yyy = zeros(size(xxx));
for i=1:length(xxx)
  if check_for_lines(xx,yy,xxx(i))
      yyy(i) = interp1(xx,yy,xxx(i),'linear');
  else
    yyy(i) = interp1(xx,yy,xxx(i),'pchip');
  end
end