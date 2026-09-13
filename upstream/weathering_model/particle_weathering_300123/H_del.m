function H = H_del(data,t,run_params)

% Net H+ flux gN/m^2/s
%H = (data.N.N2O_DENIT + data.N.NOx_DENIT - data.N.N2O_NIT - data.N.NOx_NIT)/14;

H = calc_drivers_vr(data,t);

H = H/14;
% mol/litre/year
H = H/1000*3600*24*365;
