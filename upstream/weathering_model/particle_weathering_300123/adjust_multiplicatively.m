function yyyy = adjust_multiplicatively(inp,add)

ans1 = reshape(inp,12,length(inp)/12);

yyyy = zeros(size(inp));
for i=1:length(inp)/12
  y = ans1(:,i);
  miny = min(y);
  yyy = (y - miny)/sum(y - miny)*(sum(y) + add - 12*miny) + miny;
  yyyy((i-1)*12+1:i*12) = yyy;
end

