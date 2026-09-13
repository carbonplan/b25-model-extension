function [PB_new, MW, SA, MB] = PSD_weather_discrete_basalt(PB, Delt, wP, z)
% PSD_WEATHER_DISCRETE_BASALT  Stub for a missing upstream function.
%
% THE ARGUMENT THAT THIS IS SAFE IN 'C' MODE, line by line in fd15.m:
%   281  [PB_new,MW,SA,MB] = PSD_weather_discrete_basalt(PB,Delt,wP,z);
%   285  SAP = SA.*params.mf/delZ;      <- SA used only to build SAP
%   289  Mp  = MB(:,imin)/delZ;         <- MB used only to build Mp
%   290  Mp  = [3*Mp(1)-Mp(2); (Mp(2:end)+Mp(1:end-1)); 3*Mp(end)-Mp(end-1)]/2;
%   291  SAp = SAP(:,imin);
%   292  SAp = [3*SAp(1)-SAp(2); ... ]/2;
%   312  if strcmp(run_params.model_P_or_C,'C')
%   318-324    SA recomputed from profiles(imin,iz) -- NOT from SAp
%   325        RRt = w(imin,:)'.*SA;    <- uses the recomputed SA
%   326        Mp  = Bt;                <- Mp OVERWRITTEN, discarding MB
%   334  Bt = Mp;                       <- therefore a no-op (Mp == Bt)
%   else
%   328        RRt = w(imin,:)'.*SAp;   <- 'P' mode only: SAp WOULD matter
%   MW is never referenced anywhere in fd15.m.
%
% So in 'C' mode the returns need only be shape-correct so lines 285-292 do not
% error. They are: MB and SA are (p-1) x nmin, because line 290 turns a length-n
% vector into a length-(n+1) one and the result must have p nodes.
%
% NOT SAFE in 'P' mode -- SAp feeds RRt directly at line 328 -- so we refuse.

if isfield(PB, 'is_stub') && PB.is_stub
    % nothing to do; values below are placeholders, not physics
end

nz   = numel(z);
nmin = PB.nmin;

MW = 0;
SA = zeros(nz-1, nmin);
MB = zeros(nz-1, nmin);
PB_new = PB;
end
