function PSD_get(name)
% PSD_GET  Stub for a function that is MISSING from the Zenodo deposit.
%
% fd15.m:15 calls PSD_get('Cragmill') to populate the global PSD_data, then
% reads PSD_data.P_opt at fd15.m:22. Neither the PSD/ directory nor PSD_data/
% ships with weathering_model (Zenodo 10940280) -- five functions are absent:
%   PSD_get, PSD_make_basalt, PSD_weather_discrete_basalt,
%   PSD_transport_basalt, make_particles
%
% WHY A STUB IS SOUND HERE
%   The paper runs run_params.model_P_or_C = 'C' (mod5.m:115), the continuum
%   branch. In that branch the PSD return values are computed and then thrown
%   away before they can affect anything -- see PSD_weather_discrete_basalt.m
%   in this directory for the line-by-line argument. Particle-size evolution in
%   'C' mode comes from the `profiles` struct via SA_VOL_2 / get_pdf_donkey /
%   add_pdfs, all of which DO ship.
%
% If model_P_or_C is ever set to 'P', these stubs are invalid and the run must
% be blocked. That check lives in PSD_weather_discrete_basalt.m.
global PSD_data
PSD_data = struct('P_opt', [], 'name', name, 'is_stub', true);
end
