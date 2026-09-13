function P = make_particles(radii, counts)
% MAKE_PARTICLES  Stub for a missing upstream function. See PSD_get.m.
%
% Reached only when fd_params.test = 'yes' (fd15.m:24), a self-test path the
% paper does not use (mod5.m:92 sets 'no'). Refuses rather than fabricating a
% particle distribution that would make the self-test meaningless.
error('make_particles:missing', ...
    ['fd_params.test = ''yes'' requires make_particles, which is NOT in the ' ...
     'Zenodo deposit. The built-in self-test cannot be run with the released code.']);
end
