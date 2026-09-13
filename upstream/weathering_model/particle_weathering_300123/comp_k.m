function r_all = comp_k(pH,t,params)

MOL_H = 10^(-pH);
MOL_OH = 10^-14/MOL_H;

TK = t + 273.15;

dif_temp = 1/TK - 1/298.15;

r_all = zeros(1,length(params.names));
for i=1:length(params.names)
  if (strcmp(params.names(i),'Glass_Pham'))
    r_all(i) = glass_decay_rate(pH,t);
  else
    if (params.acid.k(i) == 0)
      k_acid = 0;
    else
      k_acid = 10^params.acid.k(i);
    end
    if (params.neut.k(i) == 0)
      k_neut = 0;
    else
      k_neut = 10^params.neut.k(i);
    end
    if (params.base.k(i) == 0)
      k_base = 0;
    else
      k_base = 10^params.base.k(i);
    end
    eapp_acid = params.acid.e(i);
    eapp_neut = params.neut.e(i);
    eapp_base = params.base.e(i);
    n_acid = params.acid.n(i);
    n_neut = params.neut.n(i);
    n_base = params.base.n(i);
    hplus = MOL_H;
    ohminus = MOL_OH;
    r_acid = k_acid*exp((-eapp_acid/(8.314*1e-3))*dif_temp)*(hplus^n_acid);
    r_neut = k_neut*exp((-eapp_neut/(8.314*1e-3))*dif_temp);
    r_base = k_base*exp((-eapp_base/(8.314*1e-3))*dif_temp)*(hplus^n_base);
    r_all(i) = r_acid + r_neut + r_base;    
  end
end
