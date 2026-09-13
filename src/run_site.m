function out = run_site(drv, basalt, varargin)
% RUN_SITE  Run the Beerling weathering model at one driver cluster.
%
% NEW FILE -- this replaces upstream run_1_v5.m, which cannot be used as shipped:
% it hard-codes /home/sm1epk/ paths, opens a SLURM parpool, and fixes the
% feedstock to Minnesota with inps.yy = 5. Nothing here changes the model; it
% only assembles the `inps` struct that mod5.m expects, exactly as run_1_v5.m
% does (same fields, same units, same transposes).
%
%   out = run_site(drv, basalt, 'Name', value, ...)
%
%   drv     driver-cluster index, 1..437, into mylist in run_strc_6.mat
%   basalt  feedstock, e.g. 'Minnesota_1'. Upstream naming: _1 is the bytownite
%           (calcic plagioclase) cluster, _2 the labradorite one, in all 13
%           states. Confirmed against Data File S5 for all 26. See notes.md.
%
% Options
%   'experiment'  'E0' (default, and the only configuration). A label: stored in
%                 the result, and the prefix run_one.sh gives the file
%   'tf'          run length in years (default 51)
%   'start_year'  first year of basalt application (default 2020). The drivers
%                 are sliced from this year, which is what the published runs
%                 did -- see notes.md, "Runs are keyed by start year".
%   'save_to'     .mat path to write; '' (default) to skip
%
% Returns a struct with the model outputs plus the inputs used.

p = setup_paths();

opt = struct('experiment','E0', 'tf',51, 'start_year',2020, 'save_to','');
for k = 1:2:numel(varargin)
    f = varargin{k};
    if ~isfield(opt, f), error('run_site:opt','Unknown option ''%s''.', f); end
    opt.(f) = varargin{k+1};
end
if ~strcmp(opt.experiment, 'E0')
    error('run_site:experiment', ...
        'Only E0 is run here (got ''%s''); E1 and E2 are post-processes on it.', ...
        opt.experiment);
end

RECORD_START = 2020;   % first year of the CLM5 driver record in run_strc_6.mat
NMONTH       = 612;    % 51 years x 12

% ---- drivers -----------------------------------------------------------
S = load(p.run_strc, 'mylist');
if drv < 1 || drv > numel(S.mylist)
    error('run_site:drv','drv must be 1..%d (got %d).', numel(S.mylist), drv);
end
dat = S.mylist{drv};

% Slice the driver record so month 1 of the run is January of start_year.
off = (opt.start_year - RECORD_START) * 12;
if off < 0
    error('run_site:startYear','start_year must be >= %d.', RECORD_START);
end
navail = (NMONTH - off) / 12;
if opt.tf > navail
    error('run_site:tf', ...
        'tf = %g yr from %d exceeds the %g yr of drivers left in the record.', ...
        opt.tf, opt.start_year, navail);
end
sel = (off+1) : NMONTH;

% ---- assemble inps exactly as run_1_v5.m does --------------------------
inps = struct();
inps.scen   = 0;
inps.iprof  = basalt;
inps.ibas   = basalt;
inps.nam    = dat.Crop;
inps.nam_l  = dat.nam_l;
inps.nam_s  = dat.nam_s;
inps.ind    = dat.indz';
inps.lind   = dat.lind';
inps.ar     = dat.area';
inps.p80    = 100;                       % um; the published runs use 100
inps.yy     = opt.tf;
inps.spin   = min(inps.yy, 5);           % run_1_v5.m:70
inps.pH     = dat.pH;
inps.fc     = double(dat.fc);
inps.lamb   = 0.33;                      % fractal dimension; the published value
inps.lambi  = 1;

inps.st     = double(dat.st(:, sel)') - 273.15;   % months x 7 depths, degC
inps.npp    = double(dat.npp(sel)');
inps.co2    = double(dat.co2(sel)');
inps.sr     = double(dat.sr(sel)');
inps.wat    = double(dat.infil(sel)' / 1000);     % mm/month -> m/month
inps.alk    = double(dat.N(:, sel)');             % months x 31 nodes

% ---- run ---------------------------------------------------------------
global SHIM_OOR; SHIM_OOR = struct();
cwd0 = pwd;
cleaner = onCleanup(@() cd(cwd0));

fprintf('run_site: drv=%d  %s  %s  %s  %g yr from %d\n', ...
    drv, strtrim(char(dat.Crop)), basalt, opt.experiment, opt.tf, opt.start_year);
t0 = tic;
out = struct();
[out.c2b_ratio, out.CO2_mass, out.Application_Basalt_mass, out.pH, ...
 out.K_mass, out.P_mass, out.CO2_mass_outflow, out.CO2_mass_precip, ...
 out.Ca, out.Mg, out.Na, out.K, out.totals] = mod5(inps);
out.wall_seconds = toc(t0);

out.inps       = inps;
out.drv        = drv;
out.basalt     = basalt;
out.experiment = opt.experiment;
out.start_year = opt.start_year;
out.oor        = SHIM_OOR;   % lookup queries that fell outside the tabulated grid

fprintf('run_site: done in %.1f s | CDR/rock = %.4f tCO2/t | pH %.2f -> %.2f\n', ...
    out.wall_seconds, out.c2b_ratio(end), out.pH(1,1), out.pH(1,end));

if ~isempty(opt.save_to)
    % '-v7' matters. Octave's default save format is its own, which neither
    % MATLAB nor scipy.io.loadmat can read ("Unknown mat file type"). -v7 is
    % MATLAB level-5, readable by Octave, MATLAB and scipy alike, so the same
    % result file feeds tools/compare_to_published.py either way.
    if exist('OCTAVE_VERSION', 'builtin') > 0
        save('-v7', opt.save_to, '-struct', 'out');
    else
        save(opt.save_to, '-struct', 'out', '-v7');
    end
    fprintf('run_site: wrote %s\n', opt.save_to);
end
end
