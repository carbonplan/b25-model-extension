function [rho,eqSol] = exp_dist(total,rooting_depth,z)

ai = 3/rooting_depth;
Ai = total*ai;
rho = Ai*exp(-ai*z);

eqSol = Ai*(1 - exp(-ai*z))/ai;
