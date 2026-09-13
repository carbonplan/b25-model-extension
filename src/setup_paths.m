function P = setup_paths()
% SETUP_PATHS  Put our overrides ahead of the untouched upstream code.
%
% Path precedence rules the whole design of this repo:
%   src/shim/        wins over  upstream/...  (same-named file = an override)
%   src/shim/octave/ is added ONLY under Octave, so MATLAB never sees those
%   upstream/        is byte-identical to the Zenodo deposit and is never edited
%
% So "what did we change?" is always answerable with:
%   diff upstream/weathering_model/particle_weathering_300123/<f>.m src/shim/<f>.m
%
% Returns a struct of absolute paths used by the drivers.

here   = fileparts(mfilename('fullpath'));
root   = fileparts(here);

P.root     = root;
P.upstream = fullfile(root, 'upstream', 'weathering_model');
P.model    = fullfile(P.upstream, 'particle_weathering_300123');
P.data     = fullfile(P.upstream, 'particle_weathering_data');
P.shim     = fullfile(root, 'src', 'shim');
P.src      = fullfile(root, 'src');
P.results  = fullfile(root, 'results');
P.work     = fullfile(root, 'work');

% Driver file: the 437-cluster copy at the TOP of weathering_model/.
% NOT particle_weathering_data/driving_data_structure/run_strc_6.mat, which is a
% different 525-cluster file that does not reproduce the published outputs.
% See notes.md, "Two files named run_strc_6.mat".
P.run_strc = fullfile(P.upstream, 'run_strc_6.mat');

% Build the path lowest-precedence first; addpath prepends, so the last
% addpath call ends up first and therefore wins.
addpath(P.model);
addpath(P.src);
addpath(P.shim);
if is_octave_()
    addpath(fullfile(P.shim, 'octave'));
end

if ~exist(P.run_strc, 'file')
    error('setup_paths:missingDrivers', ...
        ['Driver file not found: %s\n' ...
         'It is excluded from git (83 MB). See how-to-run.md for where to get it.'], P.run_strc);
end

build_work_dir_(P);
end

% -------------------------------------------------------------------------
function build_work_dir_(P)
% WHY THERE IS A work/ DIRECTORY AT ALL
%
% In both MATLAB and Octave the CURRENT DIRECTORY takes precedence over the
% search path. Upstream mod5.m does cd() into particle_weathering_300123/, so
% running from there would make upstream's own solution2pH.m and solution2CaSat.m
% shadow our overrides in src/shim/ -- silently, and the overrides would never
% run. (This is not hypothetical; it is what happened on the first smoke test.)
%
% But the cd() cannot simply be dropped, because two things resolve against the
% working directory:
%   Ceq_comp.m / Ceq_comp2.m   load(['Ceqs/Ceq_table_', basalt])
%   fd15.m:11-12               path('./PSD', path);  path('./PSD/PSD_data', path)
%
% So we cd into a staging directory that satisfies those relative lookups and
% contains no .m files at all. Everything else is reached by absolute path or
% by the search path, where src/shim/ correctly wins.

% RACE-SAFE: several Octave processes run in parallel (tools/run_batch.sh -j N)
% and all of them call setup_paths at start-up. Each step below is therefore
% attempt-then-verify rather than test-then-create: two processes can both pass
% an existence test and then collide on mkdir/ln. Sharing one work/ between
% processes is safe because nothing ever writes into it -- it holds a symlink and
% two empty directories, and cd() is per-process.
%
% The output arguments on mkdir are what make that true, and they are not
% cosmetic: called bare, Octave's mkdir RAISES on a directory that already
% exists, so the loser of a race dies before reaching the verify below. Asking
% for [ok,msg,id] turns the failure into a return value instead -- which is the
% documented behaviour in both Octave and MATLAB. This only bites on a fresh
% tree, where work/ does not exist yet and every process tries to create it at
% once; that is exactly what a Coiled VM is.
if ~exist(P.work, 'dir')
    [~, ~, ~] = mkdir(P.work);          % may lose the race; verified below
end
if ~exist(P.work, 'dir')
    error('setup_paths:work', 'Could not create %s', P.work);
end

% Ceqs/ -> the upstream tables, by symlink so nothing is duplicated or edited.
lnk = fullfile(P.work, 'Ceqs');
if ~exist(lnk, 'dir')
    tgt = fullfile(P.model, 'Ceqs');
    system(sprintf('ln -s "%s" "%s" 2>/dev/null', tgt, lnk));
end
if ~exist(lnk, 'dir')
    error('setup_paths:ceqs', 'Could not link Ceqs into %s', P.work);
end

% fd15.m unconditionally does path('./PSD', path). A missing directory is only a
% warning, but creating them keeps the run output clean. They stay empty: the PSD
% stubs live in src/shim/ and are found on the path.
for d = {fullfile(P.work,'PSD'), fullfile(P.work,'PSD','PSD_data')}
    if ~exist(d{1}, 'dir'), [~, ~, ~] = mkdir(d{1}); end
    if ~exist(d{1}, 'dir')
        error('setup_paths:psd', 'Could not create %s', d{1});
    end
end

% Guard rail: if a .m file ever appears in work/ it would shadow our overrides
% the same way upstream did.
m = dir(fullfile(P.work, '*.m'));
if ~isempty(m)
    error('setup_paths:workPolluted', ...
        ['work/ contains %d .m file(s) (e.g. %s). The working directory outranks ' ...
         'the search path, so these would shadow src/shim/. Remove them.'], ...
        numel(m), m(1).name);
end
end

function tf = is_octave_()
tf = exist('OCTAVE_VERSION', 'builtin') > 0;
end
