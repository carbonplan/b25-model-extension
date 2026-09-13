function yy = smoother2(y)

if length(size(y)) > 2
  error('Smoother works on 1 or 2 dimensional matices.');
end

n = size(y,1);
m = size(y,2);

if n>=m
  flip = 0;
  dim = n;
else
  flip = 1;
  dim = m;
end

AA = 0.5*diag(ones(1,dim),0) + 0.25*diag(ones(1,dim-1),1) + 0.25*diag(ones(1,dim-1),-1);

AA(1,1)       = 0.75;     AA(1,2) = 0.25; 
AA(dim,dim-1) = 0.25; AA(dim,dim) = 0.75;
if flip
  yy = AA*y';
  yy(1,:) = 2*yy(2,:) - yy(3,:);
  yy(end,:) = 2*yy(end-1,:) - yy(end-2,:);
  yy = yy + ones(size(yy))*(sum(y',1) - sum(yy,1))'/size(yy,1);
%  yy = yy + ones(size(yy))*(sum(y',1)-(y(:,1)+y(:,end))'/2 - (sum(yy,1) - (yy(1,:)+y(end,:)/2)))'/size(yy,1);
  yy = yy';
else
  yy = AA*y;
  yy(1) = 2*yy(2) - yy(3);
  yy(end) = 2*yy(end-1) - yy(end-2);
  yy = yy + (sum(y) - sum(yy))/length(y);
end
