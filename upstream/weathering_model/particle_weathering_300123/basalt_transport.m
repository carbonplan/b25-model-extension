profiles = {
    'Cragmill'
    'Middleton'
    'Hillhouse'
    'Renforth'
    'Mike'
    'Energy_Farm_1'
    'Energy_Farm_2'
    'Cepuritis_1-25'
    'Cepuritis_20_60'
    'Nunes_1'
    'Nunes_2'
    'Nunes_3'
    'Nunes_4'
    'test'
    'Amy_1'
    'Amy_2'
    };
basalts = {
    'Cragmill'
    'Middleton'
    'Hillhouse'
    'Alkali'
    'Tholeiite'
    'Lyla'
    'CRB_1'
    'CRB_2'
    'Labradorite'
    'Labradorite2'
    'Ilmenite'
    'Tholeiite2'
     };

iprofile  = 1;
ibasalt   = 1;

basalt   = basalts{ibasalt};
profile  = profiles{iprofile};

params = set_basalt(basalt);

[rad0,mfd0,bp] = set_profile(profile,20,1);
rad0 = rad0'; mfd0 = mfd0';
  figure(2);
  stem(rad0,mfd0);
% mass loss percentage for 1 year = 76.42361% = 1 - .5*(1/8) - .3*(8/27) - .2*(27/64)
  w = 50e-6*params.rho;
  enhancement = 1;
  
  
  
  
  
  
  %%
  
x = bp.radius_max;
y = bp.cdf;

plot(x,y,'-*','linewidth',2);
hold on  
xx = linspace(min(x),max(x),10000);

yy = interp1(x,y,xx,'spline')
  
  
plot(xx,yy,'-','linewidth',2)
  
hold off
  

plot(rad0,mfd0)

  
  
%%
addpath PSD


%%

trapz(rad0,mfd0)

figure(3)
plot(bp.radius_max,bp.cdf,'*-')

n=1000;
delcdr = 1;
p = zeros(n,1);
%for i=1:n
%  p(i) = interp1_MRL2(bp.cdf,bp.radius_max,rand*100);
%end
xx = delcdr/2:delcdr:100-delcdr/2;
p = interp1_MRL2(bp.cdf,bp.radius_max,xx);

figure(4)
histogram(p,100)
xlim([0 0.002])

figure(5)
plot(p,xx)











%%
mass = 4;
rho = 3000;
fd = .33;
rho = 1;
k = .01;

depth = .15;

Bp.r = p'*ones(1,length(params.names));
Bp.n = delcdr/100./(rho*4/3*pi*Bp.r.^3)*mass;
Bp.depth = rand(length(Bp.r),1)*depth;
Bp.m = rho*4/3*pi*Bp.r.^3.*Bp.n;


total_mass = sum(sum(Bp.m))

delt = 1;
[Bp,weathered_mass] = weather_particles(Bp,delt,k,fd,rho);
Bp.r;
weathered_mass;



%%


w_r = @(r0,delt) (r0.^(1 - fd) - k/rho*(1 - fd)*delt).^(1/(1 - fd));
%m_r = 

n = 100000;
r = (1:n)';

delt = 0.001;

tic
for day=1:365
  r = weather_particle(r,delt,k,fd,rho);
end
toc

%r(1)








  
