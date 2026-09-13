function PB = PSD_make_basalt(b_mass, P, reps, z, vf, rho, minerals)
% PSD_MAKE_BASALT  Stub for a missing upstream function. See PSD_get.m.
%
% fd15.m:31 builds PB here; fd15.m:34-38 then sets PB.lambda.*, and PB is only
% ever passed back into PSD_weather_discrete_basalt / PSD_transport_basalt.
% In 'C' mode nothing reads any field of PB, so an inert carrier is enough.
PB = struct('is_stub', true, 'b_mass', b_mass, 'nz', numel(z), ...
            'nmin', numel(minerals), 'vf', vf, 'rho', rho, ...
            'r', [], 'n', [], 'depth', [], 'lambda', struct());
end
