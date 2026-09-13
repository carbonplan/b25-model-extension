save('movies/Cragmill_constClim','M1','M2')


%%

figure(1)
x = 0:.01:1;
for t=1:10
  y = (x*t/10);
  plot(x,y,'-k','linewidth',2); axis([0 1 0 10]);
  pause(.1);
  M(t) = getframe(gcf);
end

%%

figure(2)
movie(M)

for i=1:10
  subplot(1,2,1)
  imshow(M(i).cdata)
  subplot(1,2,2)
  imshow(M(i).cdata)
  pause
end

%%

figure(4)
%%
imshow(M(1).cdata)


%%

M = getframe(gcf)

%%
figure(5)
imshow(M.cdata)



%%
%load('movies/Cragmill')
%load('movies/Cragmill_constClim')
load('movies/Cragmill_0p02','M1','M2')
%load('movies/Cragmill_0p02_0p04','M1','M2')


h = setPlotGrid2(3,200,200,2,2,[0 0 0 0],[0 0 0 0]);

w = warning;
warning('off','all')
for i=1:3:length(M1)
  axes(h(1))
  imshow(M1(i).cdata)
  axes(h(2))
  imshow(M2(i).cdata)
  pause
end
warning(w);
