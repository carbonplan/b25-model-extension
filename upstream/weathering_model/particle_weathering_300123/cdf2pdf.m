function [rad0,mass0]=cdf2pdf(cdf,x,n,verbose)

% Set radius bins which will be used throughout. 
max_r = max(x); delr = max_r/n;

% Set the edges of the radius bins
radius_bin_edges = linspace(0,max_r,n+1)';
radius_bins = linspace(delr/2,max_r-delr/2,n)';

cdfs = interp1_MRL2(x,cdf,radius_bin_edges);
mass0 = cdfs(2:end)-cdfs(1:end-1);
rad0 = radius_bins;

mass0 = mass0/trapz(rad0,mass0);
%bar(rad0,mass0)

if verbose
  % Bin the input basalt profile.
  subplot(2,2,3);
  bar(radius_bins*1e6,mass0);
  xlim([0 radius_bin_edges(end)*1.1e6]);
  title('PDF');
    
  subplot(2,2,4);
  plot(radius_bins*1e6,mass0,'linewidth',2);
  xlim([0 radius_bin_edges(end)*1.1e6]);
  title('PDF');
    
  subplot(2,2,2);
  hold on;
  newCdf = tril(ones(n,n))*mass0;
  plot(radius_bin_edges*1e6,[0;newCdf],'ro-');
  hold off;
end
