function C = findiff(C,p,Delz,Delt,q,phi,Ceq,RR,alpha,beta,Diff)
% need to add code to cope with the case when q = 0

if isempty(Ceq)
  Ceq = 1e10*ones(p,1);
else
  Ceq = max(1e-6,Ceq);
end

if q>0
  % positive flow rate, finite difference model with diffusion
  AA = zeros(p,p); BB = zeros(p,p); D = zeros(p,1);
  for i=2:p-1
    if Ceq(i) < C(i)
      xCeq = C(i); 
    else
      xCeq = Ceq(i); 
    end
    AA(i,i-1) =-q*alpha/(2*Delz) - Diff*beta/Delz^2;
    AA(i,i)   = phi/Delt + 2*Diff*beta/Delz^2 + RR(i)/(2*xCeq);
    AA(i,i+1) = q*alpha/(2*Delz) - Diff*beta/Delz^2; 
    BB(i,i-1) = q*(1-alpha)/(2*Delz) + Diff*(1-beta)/Delz^2;
    BB(i,i)   = phi/Delt  - 2*Diff*(1-beta)/Delz^2 - RR(i)/(2*xCeq);
    BB(i,i+1) =-q*(1-alpha)/(2*Delz) + Diff*(1-beta)/Delz^2;
    D(i) = RR(i);
  end

  % zero value boundary condition
  AA(1,1) = 1;

  % constant gradient boundary condition
  AA(p,p-2) = 1; AA(p,p-1) =-2; AA(p,p) = 1; D(p) = 0;

  if abs(det(AA)) < 1e-3
    error('small det')
  end
  
  C = AA\(BB*C + D);
  C(1) = 0;

else
  % zero or negative flow, ignore diffusion, take flow rate to be zero
  % and solve analytically
  ii = find(C./Ceq < 1);
  C(ii) = (1 - exp(log(1 - min(1,C(ii)./Ceq(ii))) - Delt*RR(ii)/phi./Ceq(ii))).*Ceq(ii);
end
