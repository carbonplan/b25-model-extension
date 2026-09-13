function F = mk_interp2d(g1, g2, V, name)
% MK_INTERP2D  Rebuild a MATLAB griddedInterpolant as a plain function handle.
%
% WHY THIS EXISTS
%   The upstream model ships three lookup tables as serialized griddedInterpolant
%   objects: alk2pH_function.mat, CaSatBuffered_function.mat,
%   CaSatNotBuffered_function.mat. Octave cannot deserialize MATLAB classdef
%   objects, and -- this is the dangerous part -- it does not error. It returns
%   a 6-element uint32 array. Calling it would index that array and silently
%   produce nonsense instead of a pH or a calcite ceiling.
%
% WHY IT IS EXACT, NOT AN APPROXIMATION
%   The authors' own make_gridded_interpolant_data.m wrote the three companion
%   files alk2pH_data.mat / CaSatBuffered_data.mat / CaSatNotBuffered_data.mat
%   directly FROM those interpolants:
%       CO2 = alk2pH.GridVectors{1};  alk = alk2pH.GridVectors{2};
%       values = alk2pH.Values;       save('alk2pH_data', ...)
%   So the grid vectors and values here are the same numbers the interpolant
%   held. Only the interpolation rule has to be matched, and griddedInterpolant
%   defaults to Method='linear' with ExtrapolationMethod='linear'.
%
% HOW EXTRAPOLATION IS MATCHED
%   interp2 returns NaN outside the grid; griddedInterpolant extends the edge
%   gradient. We reproduce that by padding each grid vector with one extra node
%   two full ranges beyond each end, carrying the edge slope. Linear
%   interpolation between two points on a straight line is exact, so queries
%   outside the original grid get griddedInterpolant's answer, and the corners
%   get the same bilinear extension.
%
% USAGE
%   F = mk_interp2d(CO2, alk, values, 'alk2pH');
%   pH = F(co2_query, alk_query);          % elementwise, arrays of equal size
%
% Out-of-grid queries are tallied in the global SHIM_OOR so a run can report
% whether it ever left the tabulated range. See shim_oor_report().

if nargin < 4, name = 'unnamed'; end

g1 = double(g1(:));
g2 = double(g2(:));
V  = double(V);

if ~isequal(size(V), [numel(g1) numel(g2)])
    error('mk_interp2d:size', ...
        '%s: values must be [numel(g1) x numel(g2)] = [%d x %d], got [%d x %d].', ...
        name, numel(g1), numel(g2), size(V,1), size(V,2));
end

lim = [g1(1) g1(end) g2(1) g2(end)];

[g1p, V] = pad_(g1, V, 1);
[g2p, V] = pad_(g2, V, 2);

F = @(x1, x2) eval_(g1p, g2p, V, x1, x2, lim, name);
end

% -------------------------------------------------------------------------
function [gp, Vp] = pad_(g, V, dim)
% Extend grid vector g (and V along dim) by one node at each end, carrying the
% edge slope, at a distance of two full grid ranges.
rng = g(end) - g(1);
d   = 2 * rng;

if dim == 1
    slo = (V(2,:)   - V(1,:))   / (g(2)   - g(1));
    shi = (V(end,:) - V(end-1,:)) / (g(end) - g(end-1));
    Vp  = [V(1,:) - d*slo; V; V(end,:) + d*shi];
else
    slo = (V(:,2)   - V(:,1))   / (g(2)   - g(1));
    shi = (V(:,end) - V(:,end-1)) / (g(end) - g(end-1));
    Vp  = [V(:,1) - d*slo, V, V(:,end) + d*shi];
end
gp = [g(1) - d; g; g(end) + d];
end

% -------------------------------------------------------------------------
function y = eval_(g1p, g2p, V, x1, x2, lim, name)
% interp2(X, Y, V, Xq, Yq) treats X as the column coordinate (dim 2) and Y as
% the row coordinate (dim 1), so g2 is X and g1 is Y.
global SHIM_OOR

n = sum(x1(:) < lim(1) | x1(:) > lim(2)) + sum(x2(:) < lim(3) | x2(:) > lim(4));
if n > 0
    f = makeValidName_(name);
    if ~isstruct(SHIM_OOR), SHIM_OOR = struct(); end
    if ~isfield(SHIM_OOR, f), SHIM_OOR.(f) = 0; end
    SHIM_OOR.(f) = SHIM_OOR.(f) + n;
end

y = interp2(g2p, g1p, V, x2, x1, 'linear');
end

% -------------------------------------------------------------------------
function s = makeValidName_(s)
s = regexprep(s, '\W', '_');
if isempty(s) || ~isletter(s(1)), s = ['x' s]; end
end
