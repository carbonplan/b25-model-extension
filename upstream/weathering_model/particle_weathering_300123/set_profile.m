function [rad0, mass0, basalt_profile, delr] = set_profile(profile_name,run_params,nbins,verbose)

basalt_profile = [];
switch profile_name
  case 'Normal'
    rad0 = 1e-6*[1:100]';
    rad0 = [.1:5:100]'*1e-6;
    mass0 = rad0*0+.08; % Total of all particles (kg).

    mass0 = normpdf(rad0,50e-6,25/1000000); % 1 = particle; 100 = pretty flat.
    mass0 = mass0/sum(mass0)*100;
  case 'Tichum'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Tichum.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Pioneer'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Pioneer.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Blue_Ridge'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Blue_Ridge.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Cragmill'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Cragmill.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Hillhouse'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Hillhouse.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Middleton'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Middleton.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Oregon'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Oregon.csv'];
    basalt_profile = read_basalt_profile(fname,34,33);

  case 'Mike'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Mike.csv'];
    basalt_profile = read_basalt_profile(fname,34,33);

  case 'Mike-Fine'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Mike_Fine.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Mike-Mid'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Mike_Mid.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Mike-Course'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Mike_Course.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  case 'Renforth'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Renforth.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Amy_1'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Amy_1.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Amy_2'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Amy_2.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Energy_Farm_1'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Blue_Ridge_ga_djb_analysis_1.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Energy_Farm_2'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Blue_Ridge_ga_djb_analysis_2.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Cepuritis_1-25'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Cepuritis_1_25.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Cepuritis_20-60'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Cepuritis_20_60.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Nunes_1'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Nunes_1.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Nunes_2'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Nunes_2.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Nunes_3'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Nunes_3.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'Nunes_4'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_Nunes_4.csv'];
    basalt_profile = read_basalt_profile(fname,3,2);

  case 'test'
    fname=[run_params.data_dir,'/basalt_profiles/basalt_pdf_test.csv'];
    basalt_profile = read_basalt_profile(fname,2,1);

  otherwise
    error('Case entry for profile doesn''t exist in ''set_profile.m''');
end

if verbose
figure;
subplot(2,2,1);
bar(basalt_profile.radius_avg*1e6,basalt_profile.q);
ylabel('q');
xlim([0 inf]);
%    set(gca,'XScale','log');
%    xlim([0 basalt_profile.radius_avg(end)*1.1e6]);
subplot(2,2,2);
plot(basalt_profile.radius_max*1e6,basalt_profile.cdf,'b+','linewidth',2);
ylabel('%');
end    

% Set radius bins which will be used throughout. 
%max_r = max(basalt_profile.radius_max); delr = max_r/nbins;

% Set the edges of the radius bins
%radius_bin_edges = linspace(0,max_r,nbins+1)';
%radius_bins = linspace(delr/2,max_r-delr/2,nbins)';

%method = 'linear';
%method = 'pchip';
%cdfs = interp1_MRL2(basalt_profile.radius_max,basalt_profile.cdf,radius_bin_edges);
%mass0 = cdfs(2:end)-cdfs(1:end-1);
%rad0 = radius_bins;

[rad0,mass0] = cdf2pdf(basalt_profile.cdf,basalt_profile.radius_max,nbins,0);
