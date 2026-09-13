function params = set_basalt(basalt_type,run_params)
% Set composition of basalt through minerals and fractions

switch basalt_type
  case 'New_Jersey_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [3.968976113	19.82982838	0	19.54456376	3.491361437	1.985781676	0.476318908	4.703166221	0.308056324	0	0	0	0	45.69194718	0];

  case 'New_Jersey_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.545766516	17.60147402	0.002220684	13.07036551	5.448878917	2.803801346	2.668164872	5.869616455	0.465756563	0	0	10.38140907	39.14254605	0	0];

  case 'Virginia_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.874408493	18.61746764	0	19.64794906	2.826168823	1.482109326	2.304652729	4.712297019	0.23655636	0	0	0	0	47.29839055	0];

  case 'Virginia_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [6.214677577	17.55350851	0.399063199	14.74152936	4.283666887	2.402112703	0.648917111	5.759952382	0.359376052	0	0	2.29984037	41.71303144	0	3.624324407];

  case 'Oregon_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.408533046	14.85127819	0	13.85656333	3.256656024	2.689118745	4.070859532	5.761546391	0.568456957	0	0	0	0	52.68059022	0.856397565];

  case 'Oregon_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.343580909	13.31740814	0	12.6270096	5.212308357	3.388353459	1.947816563	5.952872058	0.815849215	0	0	0	54.3948017	0	0];

  case 'North_Carolina_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [0.520361073	15.11450033	0	14.75790113	1.756152468	1.153799677	9.8753464	4.111056577	0.173045979	0	0	0	0	52.53783637	0];

  case 'North_Carolina_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.823126328	18.63978191	0	13.3936803	6.188785757	4.416558146	2.042928827	7.500376576	1.066978468	0	0	1.653949803	42.27383388	0	0];

  case 'Washington_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [3.127643092	17.22972454	0	15.12994727	2.652325017	2.828086289	1.009732136	5.975589389	0.533303938	0	0	0	0	51.51364832	0];

  case 'Washington_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [5.321389488	16.07321017	0	11.14185444	5.818631317	3.803949482	1.382159498	6.40015184	0.969844272	0	0	0.129648864	48.95916063	0	0];

  case 'Connecticut_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [4.264785034	19.69752991	0	17.62946409	3.872875945	2.211126927	0.793133916	4.887667916	0.238869326	0	0	0	0	46.40454694	0];

  case 'Connecticut_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.859516825	19.61410472	0	14.6751018	4.554571967	2.157077106	3.413590212	4.279787685	0.17393716	0	0	8.612118399	40.35127197	0	0.308922154];

  case 'California_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [0.796524237	14.06592829	0	12.15477229	3.041672544	1.839321489	6.509390638	4.653182416	0.379304216	0	0	0	0	56.55990388	0];

  case 'California_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.030699896	13.74720173	0.000121242	8.898513652	8.610285813	2.751154008	5.820428981	4.72063286	1.043462315	0	0	1.10025521	51.66363672	0	0.61360758];

  case 'Massachusetts_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.29280568	13.54972404	0	16.29513258	4.506132563	3.106218538	4.887339439	6.70350822	0.590275726	0	0	12.12586597	0	35.94299724	0];

  case 'Massachusetts_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [0.794567178	11.55319813	0	8.129963618	5.482549719	4.167056351	9.162787789	6.823189579	0.643871695	0	0	0	53.24281594	0	0];

  case 'Pennsylvania_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [3.294792846	21.73617294	0.050906376	21.09984346	3.290729051	1.810194484	0.611352339	3.499920005	0.266024715	0	0.189901831	0	0	44.15016195	0];

  case 'Pennsylvania_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.951605894	17.57873707	0	15.25562242	8.049371006	2.559697469	1.551730119	4.293613484	0.395289123	0	0	0	47.36433342	0	0];

  case 'Idaho_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.392279029	14.37694787	0	13.7590229	3.874064946	4.30559941	5.051650815	6.388032593	0.993158895	0	0	0	0	49.85924354	0];

  case 'Idaho_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.507233582	13.9877837	0.010140694	10.27829392	6.401894801	4.915913582	4.675121292	6.88209587	1.623853402	0.034588042	0	0.061205747	49.46676974	0	0.155105633];

  case 'Wisconsin_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.299757065	11.19163747	0	10.57283416	2.459575281	2.136231093	6.91745779	2.874767243	0.24789093	0	0	0	0	62.29984897	0];

  case 'Wisconsin_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [7.116516	5.025981	0	19.107317	6.078986	1.953646	0	6.114976	0.728041	0	0	0	53.874537	0	0];

  case 'Minnesota_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [0.67910551	6.349351139	0	13.51026476	2.887052785	2.806221591	8.479226321	7.880023513	0.383455114	0	0	0	0	57.02529927	0];

  case 'Minnesota_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.127246606	16.68299899	0	15.16505399	5.425646469	4.639593574	3.465471815	6.824194153	0.641039809	0	0	0	44.11602441	0	1.912730182];

  case 'Michigan_1'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [1.143113734	14.44586211	0	12.12134213	2.911459571	2.900089763	8.44285965	6.320822655	0.318454039	0	0	0	0	51.39599635	0];

  case 'Michigan_2'
   params.minerals = {'Quartz', 'Diopside', 'Wollastonite', 'Enstatite', 'Kfeldspar', 'Ilmenite', 'Olivine', 'Magnetite', 'Apatite', 'Albite', 'Oligoclase', 'Andesine', 'Labradorite', 'Bytownite', 'Anorthite'};
    params.mf = [2.614236972	12.82778065	0.728052524	15.33418774	4.003685791	3.486090136	3.689006873	6.98711538	0.548267609	0	0	11.34318267	35.29033958	0	3.14805407];

  case 'basalt1'
    params.minerals = {'Augite','Pigeonite','Plagioclase','Glass','Magnetite'};
    params.mf = [ .16 .03 .35 .45 .01 ];
  case 'Augite'
    params.minerals = {'Augite'};
    params.mf = [1];
  case 'Glass'
    params.minerals = {'Glass'};
    params.mf = [1];
  case 'Lyla_old'
    params.minerals = {'Augite','Fayalite','Forsterite','Kfeldspar','Labradorite','Ilmenite'};
    params.mf = [ 0.208 0.050 0.115 0.061 0.430 0.050 ];
  case 'Lyla'
    params.minerals = {'Augite','Fayalite','Forsterite','Kfeldspar','Labradorite','Ilmenite'};
    params.mf = [ 0.208 0.050 0.115 0.061 0.430 0.050 ];
  case 'CRB_1'
    params.minerals = {'Augite_Pham','Pigeonite_Pham','Glass_Pham','Plagioclase_Pham','Magnetite_Pham'};
    params.mf = [0.16 0.03 0.35 0.45 0.01];
  case 'CRB_2'
    params.minerals = {'Olivine_Wells','Pyroxene_Wells','Plagioclase_Wells','Matrix_Wells','Ilmenite_Wells'};
    params.mf = [0.10 0.26 0.29 0.30 0.05];
  case 'Oregon'
    params.minerals = {'Plagioclase','Kfeldspar','Diopside-Mn','Diopside','Apatite','Montmorillonite','Olivine_ORG','Ilmenite_ORG'};
    params.mf =           [35.1,        23.0,      6.2,             4.4,       2.8,            1.2,           1.0,         0.6]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Oregon_Ceq'
    params.minerals = {'Plagioclase','Kfeldspar','Diopside-Mn','Diopside','Montmorillonite','Olivine_ORG','Ilmenite_ORG'};
    params.mf =           [35.1,        23.0,      6.2,             4.4,       1.2,           1.0,         0.6]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Kfeldspar'
    params.minerals = {'Plagioclase','Kfeldspar'};
    params.mf =           [50 50]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Cragmill'
    params.minerals = {'Quartz','Apatite','Labradorite','Sanidine','Clinochlore','Ilmenite','Kaolinite','Augite','Phlogopite','Cordierite'};
    params.mf = [8.4, .8, 50.9, 9.1, 3.4, 1.6, 1.7, 20.1, .8, 3.3]/100;
  case 'Cragmill5'
    params.minerals = {'Apatite','Labradorite'};
    params.mf = [50 50]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Cragmill6'
    params.minerals = {'Labradorite','Apatite'};
    params.mf = [50 50]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Middleton'
    params.minerals = {'Quartz','Apatite','Labradorite','Sanidine','Clinochlore','Ilmenite','Augite','Phlogopite','Cordierite'};
    params.mf = [6.5, 1.1, 53.6, 5.5, 8.7, 2.4, 17.2, 3.8, 1.3]/100;
  case 'Hillhouse'
    params.minerals = {'Analcime','Labradorite','Augite','Biotite','Clinochlore','Forsterite','Spinel','Ilmenite','Apatite','Calcite'};
    params.mf = [7.1, 34.6, 32.7, .4, 5.2, 14.7, 4.5, .6, .1, .2]/100;
  case 'Cragmill_Ceq'
    params.minerals = {'Quartz','Labradorite','Sanidine','Clinochlore','Ilmenite','Kaolinite','Augite','Phlogopite','Cordierite'};
    params.mf = [8.4, 50.9, 9.1, 3.4, 1.6, 1.7, 20.1, .8, 3.3]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Middleton_Ceq'
    params.minerals = {'Quartz','Labradorite','Sanidine','Clinochlore','Ilmenite','Augite','Phlogopite','Cordierite'};
    params.mf = [6.5, 53.6, 5.5, 8.7, 2.4, 17.2, 3.8, 1.3]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Hillhouse_Ceq'
    params.minerals = {'Analcime','Labradorite','Augite','Biotite','Clinochlore','Forsterite','Spinel','Ilmenite','Calcite'};
    params.mf = [7.1, 34.6, 32.7, .4, 5.2, 14.7, 4.5, .6, .2];
    params.mf = params.mf/sum(params.mf);
  case 'Alkali'
    params.minerals = {'Labradorite','Augite','Kfeldspar','Ilmenite','Forsterite'};    
    params.mf = [0.43 0.208  0.061 0.050 0.115];
  case 'Alkali2'
    params.minerals = {'Labradorite','Augite','Kfeldspar','Ilmenite','Apatite','Forsterite'};    
    params.mf = [0.43 0.208  0.061 0.050 0.01 0.115];
  case 'Tholeiite'
    params.minerals = {'Labradorite','Augite','Kfeldspar','Ilmenite','Enstatite'};    
    params.mf = [0.448 0.3385 0.05 0.038 0.0345];
%    params.mf = params.mf/sum(params.mf);
  case 'Tholeiite2'
    params.minerals = {'Labradorite','Augite','Kfeldspar','Ilmenite','Apatite','Enstatite'};    
    params.mf = [0.448 0.3385 0.05 0.038 0.01 0.0345];
  case 'Labradorite'
    params.minerals = {'Labradorite'};    
    params.mf = [0.500];
  case 'Labradorite2'
    params.minerals = {'Labradorite','Ilmenite'};    
    params.mf = [0.25 0.75];
  case 'Ilmenite'
    params.minerals = {'Ilmenite'};    
    params.mf = [1.000];
  case 'Blue_Ridge'
    params.minerals = {'Albite','Ferroactinolite','Chlorite','Epidote','Quartz'};
    params.mf = [19.6, 11.6, 36.3, 25.6, 6.9]/100;
  case 'Blue_Ridge_2'
    params.minerals = {'Albite','Clinochlore','Epidote','Tremolite','Quartz'};
    params.mf = [20.0879, 30.5596, 26.2995, 14.7293, 8.3238]/100;
  case 'Blue_Ridge_2_short'
    params.minerals = {'Albite','Clinochlore','Epidote','Tremolite','Quartz'};
    params.mf = [20.0879, 30.5596, 26.2995, 14.7293, 8.3238]/100;
  case 'Pioneer'
    params.minerals = {'Oligoclase','Quartz','Clinochlore','Diopside','Montmorillonite','Glass'};
    params.mf = [27, 9.9, 12.6, 32.6, 0.1, 17.7]/100;
    params.mf = params.mf/sum(params.mf);
  case 'Tichum'
    params.minerals = {'Olivine','Andesine','Hydroxyapatite','Leucite','Augite','Orthoclase','Ilmenite','Glass'};
    params.mf = [19.4, 10.9, 2, 13.4, 42.3, 2.4, 1.9, 2.6]/100;
    params.mf = params.mf/sum(params.mf);
  otherwise
    error(['Basalt type ',basalt_type,' not defined.']);
end

params = simplify_mineralogy(params);

params.mf = params.mf/sum(params.mf);

params = read_min_params(params,run_params);
params.name = basalt_type;
params = params_reorder(params);

% add dummy mineral to account for residual mass
% with the assumption that the overall density of the basalt is
% 3 g/cm^3.
if (sum(params.mf) < .999999)
%  disp('Warning mass fractions < 1, adding additional mineral.');
  m_star = 1 - sum(params.mf);
  rho_star = m_star/(1/3000 - sum(params.mf./params.rho));

  params.mf = [params.mf,m_star];
  params.rho = [params.rho,rho_star];
elseif (sum(params.mf) > 1)
%  disp('Warning mass fractions > 1, normalising.');
  params.mf = params.mf/sum(params.mf);
end

params.roughness = 28;
params.reactive = 1.0;

% Normalise mass fractions
%params.mf = params.mf/sum(params.mf);
params.vf0 = params.mf./params.rho;
params.vf0 = params.vf0/sum(params.vf0)*sum(params.mf);
params.SAf0 = params.vf0.^(2/3);
params.SAf0 = params.SAf0/sum(params.SAf0);

