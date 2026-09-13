function PB_new = PSD_transport_basalt(PB, Delt, zmax)
% PSD_TRANSPORT_BASALT  Stub for a missing upstream function. See PSD_get.m.
%
% Reached only when run_params.transport = 'yes' (fd15.m:282). The paper sets
% 'no' (mod5.m:114), so this is never called in any configuration we run. If it
% ever is, the stub would silently disable downward particle transport, so it
% refuses instead.
error('PSD_transport_basalt:missing', ...
    ['run_params.transport = ''yes'' requires PSD_transport_basalt, which is ' ...
     'NOT in the Zenodo deposit. The paper runs transport = ''no''. ' ...
     'There is no way to reproduce particle transport with the released code.']);
end
