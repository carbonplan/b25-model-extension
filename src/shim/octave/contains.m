function tf = contains(str, pat)
% CONTAINS  Minimal Octave stand-in for MATLAB's contains().
%
% WHY THIS EXISTS
%   Octave 11.3 does not implement contains() ("not yet implemented", see
%   octave.org/missing.html). The upstream model calls it in exactly two places,
%   both in the mineral-formula parser reached from set_basalt -> read_min_params:
%       str_get_element.m:8   contains(Alpha, st1(1))
%       str_get_element.m:12  contains(alpha, st1(i))
%       str_get_number.m:10   contains(numeric, st1(i))
%   Every call is the same shape: "does this char array contain this one char?"
%
% SCOPE
%   Handles char-in-char and cellstr patterns. It is NOT a full reimplementation
%   (no 'IgnoreCase', no string arrays, no pattern objects) because the upstream
%   code never uses those. It will error rather than guess if given something else.
%
% This file lives in src/shim/octave/ and is added to the path ONLY under Octave
% (see setup_paths.m), so it can never shadow MATLAB's built-in contains().

if nargin ~= 2
    error('contains:nargin', 'contains(str, pat) takes exactly two arguments.');
end

if iscellstr(pat)
    tf = false;
    for k = 1:numel(pat)
        if contains(str, pat{k}), tf = true; return; end
    end
    return;
end

if iscellstr(str)
    tf = false(size(str));
    for k = 1:numel(str)
        tf(k) = contains(str{k}, pat);
    end
    return;
end

if ~(ischar(str) && ischar(pat))
    error('contains:unsupported', ...
        ['This shim only supports char/cellstr arguments (got %s and %s). ' ...
         'Upstream never needs more; extend it here if that changes.'], ...
        class(str), class(pat));
end

if isempty(pat)
    tf = true;
else
    tf = ~isempty(strfind(str, pat));  %#ok<STREMP> strfind is the Octave-safe form
end
end
