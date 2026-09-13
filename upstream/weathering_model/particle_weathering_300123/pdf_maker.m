function [rad_new,pdf_new]=pdf_maker(rad0,mfd0,bin_width)

%figure(33)
%subplot(2,1,1)
%bar(rad0,mfd0)
%xlim([0 .0002])

radius_max = [(rad0(1:end-1) + rad0(2:end))/2,(3*rad0(end) - rad0(end-1))/2];
radius_bin = [radius_max(1),diff(radius_max)];

mfd1 = radius_bin.*mfd0;
cdf = tril(ones(length(mfd1),length(mfd1)))*mfd1';
cdf = [0;cdf/cdf(end)];
radius_max = [0;radius_max'];

%new bins
rad_new = bin_width/2:bin_width:1e-3-bin_width/2;
rad_new_bin_edges = rad_new + bin_width;

cdfs = interp1(radius_max,cdf,rad_new_bin_edges,'linear',1);
pdf_new = [cdfs(1), cdfs(2:end)-cdfs(1:end-1)];

area = sum(pdf_new)*bin_width;
pdf_new = pdf_new/area;

%subplot(2,1,2)
%bar(rad_new,pdf_new)
%xlim([0 .0002])

%sum(pdf_new)/1000*1e-3


