
n = length(mylist);

n = 2;

maxcount = 0;
for n=1:length(mylist)
st = mylist{n}.nam_s
count = 0;
for j=1:size(st,1)
  strcmp(st(j,:),'IL')
  if strcmp(st(j,:),'IL')
    count = count + 1;
  end
end
if count>maxcount
  maxcount = count;
  maxj = n;
end
end