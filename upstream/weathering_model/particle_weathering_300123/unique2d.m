function y = unique2d(a)

if (length(size(a)) ~= 2)
    error('Input must be a 2 dimensional array.');
%elseif (size(a,2) ~= 2)
%    error('2nd dimension of input must equal 2.');
end

x = unique(a(:,1));

y=zeros(size(x,1),size(a,2));
for i=1:length(x)
   ii = find(a(:,1) == x(i));
   y(i,:) = [x(i), sum(a(ii,2:end),1)/length(ii)]; 
end

