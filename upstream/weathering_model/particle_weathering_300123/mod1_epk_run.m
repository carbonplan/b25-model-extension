clear
iSite = 238; % Illinoise
iprofile = 1;
ibasalt = 9;

load('../particle_weathering_data/driving_data_structure/run_strc_6');
CLM_depths = [0, 5, 15, 30, 60, 100, 200]/100;
markz = mylist{iSite};

inps.iprof = iprofile;
inps.ibas = ibasalt;
inps.pH = markz.pH;
inps.fc = markz.fc;
inps.st = markz.st' - 273.15;
inps.wat = double(markz.infil'/1000);
inps.npp = double(markz.npp');
inps.sr = double(markz.sr');
inps.co2 = markz.co2';
inps.alk = markz.N';

inps.lamb = 0.33;
inps.p80 = 50;
inps.yy = 2;

mod1_epk(inps);
