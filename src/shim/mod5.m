function [c2b_ratio,CO2_mass,Application_Basalt_mass,pH,K_mass,P_mass,CO2_mass_outflow,CO2_mass_precip,Ca,Mg,Na,K,...
    totals] = mod5(inps)

%% ---- OVERRIDE (beerling-2025-model-extension) --------------------------------
% Upstream hard-codes the authors' Sheffield cluster layout:
%   dirr{1} = '/home/sm1epk/USA/marks/';
%   dirr{2} = '/home/sm1epk/USA/marks/model/particle_weathering_300123/';
% We resolve them from this repo instead, and we cd into work/ rather than into
% the upstream model directory. That matters: the working directory outranks the
% search path, so cd'ing into particle_weathering_300123/ would let upstream's
% solution2pH.m and solution2CaSat.m silently shadow our overrides in src/shim/.
% work/ holds only the relative lookups the model needs (Ceqs/, ./PSD) and no .m
% files at all -- see build_work_dir_ in src/setup_paths.m.
        P = setup_paths();
        dirr{1} = pwd;
        dirr{2} = P.work;
        cd(dirr{2})
%% --------------------------------------------------------------------
        
        profiles = {
            'Cragmill'
            'Middleton'
            'Hillhouse'
            'Dummy_1'
            'Dummy_2'
            'Oregon'
            'Renforth'
            'Mike'
            'Energy_Farm_1'
            'Energy_Farm_2'
            'Cepuritis_1-25'
            'Cepuritis_20_60'
            'Nunes_1'
            'Nunes_2'
            'Nunes_3'
            'Nunes_4'
            'test'
            'Amy_1'
            'Amy_2'
            };
        basalts = {
            'Pioneer'
            'Blue_Ridge'
            'Tichum'
            'Blue_Ridge_2'
            'Blue_Ridge_2_short'
            'Pioneer'
            'Labradorite'
            'Labradorite2'
            'Virginia_1'
            'Oregon_1'
            'North_Carolina_1'
            'New_Jersey_1'
            'Massachusetts_1'
            'Pennsylvania_1'
            'Washington_1'
            'Washington_2'
            'Connecticut_1'
            'Connecticut_2'
            'Cragmill'
            'Middleton'
            'Hillhouse'
            'Dummy_1'
            'Dummy_2'
            'Oregon'
            'Alkali'
            'Tholeiite'
            'Lyla'
            'CRB_1'
            'CRB_2'
            'Ilmenite'
            'Tholeiite2'
            'Kfeldspar'
             };
        eq_phases = {
            ''
            'Kaolinite'
            'Montmorillonite-Ca'
            };

        %iprofile  = inps.iprof;
        %ibasalt   = inps.ibas;
        ilamb     = inps.lamb;
        ieq_phase = 1;

        %profile  = profiles{iprofile};
        %basalt   = basalts{ibasalt};
        %profile = inps.iprof;
        profile = "Oregon";
        basalt = inps.ibas;
        eq_phase = eq_phases{ieq_phase};

        % alpha is for advection beta is for Diffusion
        % 0 is fully forward, 1 is fully backward, 1/2 is Crank-Nicholson
        % min is kg/m^3, Ca is mol/litre

        fd_params=struct( ...
        'Delz',     0.005, ...     
        'min_tol',  0.03,       'Ca_tol',  0.005,    'H_tol', 0.001, ...
        'min_alpha',0.50,       'min_beta', 0.50,     'min_Diff',1e-4, ...
        'Ca_alpha', 0.50,       'Ca_beta',  0.50,     'Ca_Diff', 2e-3, ...
        'H_alpha',  0.50,       'H_beta',   0.50,     'H_Diff',  1e-4, ...
        'BC_iter',  1, ...
        'SA_VOL_bins',200,      'profile_bins', 200,  'test', 'no', ...
        'spinup_length',14/365, 'spinup_steps',50,    'spinup_power', 1.2, ...
        'min_Delt', 1/4/365,    'max_Delt', 1/12);

        run_params=struct( ...
        'cells',15,            'total_cells',15,    'basalt_cells',15, ...
        'affinity', 'yes',     'exchanger',         'yes', ...
        'acidifier','yes',     'buffer',            'yes', ...
        'N_alk',    'yes',     'apatite_inhibiter', 'yes', ...
        'tf',1,                'woody',0,           'nppnormscale', 1000, ...
        'tmp',20,              'flowrate',1,        'CO2', 410, ...
        'pH0',6.0,             'pH_rain',6.0,       'spinup', inps.spin, ...
        'b_mass',40e-1,      ...
        'depth',0.15,          'basalt_depth',0.15, 'rooting_depth',.9, ...
        'p80',10,               'fd', ilamb,            'lambda', 1, ...
        'yield',600,           'npp',1000,          'soy', 0, ...
        'wfp',.25,             'wfp_min',.1, ...
        'ocean_salinity',35,   'ocean_tmp',17, ...      
        'bucket_dampner', 0.5, 'Ceq_dampner', 0.0, ...
        'add_npp',0,           'add_flowrate',0, ...
        'add_tmp',0,           'add_pH',0, ...
        'average_drv','no',    'data_dir',P.data, ...
        'reps', 1,            'transport',         'no',  ...
        'model_P_or_C', 'C', 'minerals_filename', 'mineral_parameters4_USA');

        % Driving data
        % N (gN/s/M^3)
        % tmp (c)
        % flowrate (m/yr)
        % npp, yield, soilresp (gC/yr)

        mnths = 12;
        data.time = 2000 + (1:12)/12;

        run_params.p80 = inps.p80;
        run_params.pH0 = inps.pH;
        run_params.wfp = inps.fc;
        run_params.tf = inps.yy;

        %[data_Flux,data_tmp,data_year0,data_yearf,data_lat,data_lon] = Nitrogen_readData(run_params,fd_params,0);
        %save('Nitrogen.mat','data_Flux','data_tmp','data_year0','data_yearf','data_lat','data_lon')
        %load('Nitrogen.mat');
        %disp('read data');

        % A uniform N source of 2e-5 gN/s/M^3 should give rise to 
        % an alkalinity of 0.009 mol/l given q = 0.5 m/year phi =0.25.
        %xlat = 53.25;
        %xlon = -1;
        %[ilat,ilon]  = get_ilatlon(xlat,xlon,data_lat,data_lon);
        %data.N.year0 = data_year0;
        %data.N.yearf = data_yearf;
        %data.N.Flux  = data_Flux(:,:,ilat,ilon);

        Delz = fd_params.Delz;
        p = round(run_params.depth/Delz+1);
        z = (0:Delz:(p-1)*Delz)';
        NFlux = [];
        for i=1:size(inps.alk,1)
          NFlux(i,:) = interp1(0:.005:.15,inps.alk(i,:),z);
        end
        inps.alk = NFlux;

        data.N.Flux = inps.alk;

        % Interpolate from CLM grid.
        CLM_depths = [0, 5, 15, 30, 60, 100, 200]/100;
        Delz = fd_params.Delz;
        p = round(run_params.depth/Delz+1);
        z = (0:Delz:(p-1)*Delz)';
        stmp = [];
        for i=1:size(inps.st,1)
          stmp(i,:) = interp1(CLM_depths,inps.st(i,:),z);
        end
        data.tmp = stmp;
        run_params.pH0 = interp1(CLM_depths,run_params.pH0,z);

        %data.tmp      = data_tmp(:,ilat,ilon);
        %data.tmp = inps.st;
        %data.flowrate = data.tmp*0 + run_params.flowrate/12;
        data.flowrate = inps.wat;
        %data.npp      = data.tmp*0 + run_params.npp/12;
        data.npp = inps.npp;
        %data.yield    = data.tmp*0 + run_params.yield/12;
        data.yield = inps.npp;
        %data.soilresp = data.npp*1.5;
        data.soilresp = inps.sr;
        data.CO2 = inps.co2;
        %data.flowrate(5) = .0;
        %data.flowrate(6) = .0;
        clear inps;
        run_params.tmp      = sum(data.tmp(1:run_params.spinup*12))/run_params.spinup/12;
        run_params.flowrate = sum(data.flowrate(1:run_params.spinup*12))/run_params.spinup;
        run_params.npp      = sum(data.npp(1:run_params.spinup*12))/run_params.spinup;
        run_params.yield    = sum(data.yield(1:run_params.spinup*12))/run_params.spinup;
        run_params.soilresp = sum(data.soilresp(1:run_params.spinup*12))/run_params.spinup;
        run_params.CO2      = sum(data.CO2(1:run_params.spinup*12))/run_params.spinup/12;

%% ---- OVERRIDE (beerling-2025-model-extension) --------------------------------
% Upstream loads three serialized griddedInterpolant objects:
%   load('alk2pH_function.mat');            -> alk2pH
%   load('CaSatBuffered_function.mat');     -> CaSat
%   load('CaSatNotBuffered_function.mat');  -> CaSat
% Octave cannot deserialize MATLAB classdef objects. It does NOT error -- it
% returns a 6-element uint32 array, which would then be indexed as if it were
% a lookup and silently return nonsense.
%
% We rebuild the same interpolants from the companion *_data.mat files. Those
% were written FROM these very objects by the authors' own
% make_gridded_interpolant_data.m, so the grid vectors and values are
% identical; mk_interp2d matches griddedInterpolant's linear method and linear
% extrapolation. Note also the upstream typo on the line below:
% '@ph2alk_no_buffer' (lowercase p-h) vs the file pH2Alk_no_buffer.m -- it
% resolves only on a case-insensitive filesystem. We use the real name.
        global pH2Alk_theoretical alk2pH_theoretical
        pH2Alk_theoretical = @pH2Alk_no_buffer;

        d = load(fullfile(P.model,'alk2pH_data.mat'));
        alk2pH_theoretical = mk_interp2d(d.CO2, d.alk, d.values, 'alk2pH');

        if strcmp(run_params.buffer,'yes')
          alk2pH = @alk2pH_buffer;
          pH2Alk = @pH2Alk_buffer;
          d = load(fullfile(P.model,'CaSatBuffered_data.mat'));
          CaSat = mk_interp2d(d.CO2, d.delAlk, d.values, 'CaSatBuffered');
        else
          alk2pH = alk2pH_theoretical;
          pH2Alk = @pH2Alk_no_buffer;
          d = load(fullfile(P.model,'CaSatNotBuffered_data.mat'));
          CaSat = mk_interp2d(d.CO2, d.delAlk, d.values, 'CaSatNotBuffered');
        end
%% --------------------------------------------------------------------

        % Soil CO2 profile
        soil_CO2 = co2_profile(run_params.depth,fd_params.Delz,run_params.rooting_depth, ...
         run_params.CO2,run_params.soilresp,0)*1e6;
        %soil_CO2 = soil_CO2*0+1000;

        params = set_basalt(basalt,run_params);
        
        [rad0,mfd0] = set_profile(profile,run_params,fd_params.profile_bins,0);
        if run_params.p80>0
          pval = p_x(mfd0,rad0,80);
          rad0 = rad0/pval*run_params.p80;
          mfd0 = mfd0/trapz(rad0,mfd0);
        end
        rad0 = rad0'; mfd0 = mfd0';
        %[rad0,mfd0] = make_profile(p80/2,.05,1,fd_params.profile_bins);
        [SA_org, vol_org] = SA_vs_Vol_9(rad0,mfd0,run_params.fd,0);
        
        tic
        [~,~,~,~,c2b_ratio,CO2_mass,Application_Basalt_mass,pH,K_mass,P_mass, ...
         CO2_mass_outflow,CO2_mass_precip,outElements,totals] =  ...
         run_simple4(data,run_params,fd_params,params,basalt,eq_phase,SA_org, ...
         vol_org,rad0,mfd0,soil_CO2,alk2pH,pH2Alk,CaSat,0);
        toc

        disp(['c2b ratio               = ',num2str(c2b_ratio(end)*100,'%0.6f%%')]);

        Ca = outElements.Ca; Mg = outElements.Mg; Na = outElements.Na; K = outElements.K;

        cd(dirr{1})
end
