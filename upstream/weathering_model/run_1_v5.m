function run_1_v5(point)

     % Call with this
     % srun --cpus-per-task=2 --mem="14"G --pty bash -i
     
     % Change number of pools depending on what you want
     pc = parcluster('local');
     pc.JobStorageLocation = strcat('/home/sm1epk/eras/', num2str(point)); 
     parpool(pc, 2)
     
     % Suppress warnings parallel
     %pctRunOnAll warning off
     
     load('/home/sm1epk/USA/datasets/CLM_data/drive_data/run_strc_6.mat','mylist')
     
     dat = mylist{point}; clear mylist;
     % The basalt. Here we will know which rocks each grid cell runs on
     bas = {'Minnesota_1','Minnesota_2'};
     % The scenario
     sce = {0};
     % The lambda
     lam = {0.33};
     % The p80
     p80 = {100};

    vals = []; vals_i = [];
    % For each scenario
    for s = 1:size(sce,2)
        % For each basalt
        for b = 1:size(bas,2)
        % For each unc lambda
            for l = 1:size(lam,2)
                % For each p80
                for p = 1:size(p80,2)
                    vals = [vals;[sce(s),bas(b),lam(l),p80(p)]];
                    vals_i = [vals_i;[s,b,l,p]];  
                end
            end
        end
    end
    
    % Where the model is
    cd /home/sm1epk/USA/marks/
        
    parfor idx = 1:size(vals_i,1)
        
        disp(['Starting scenario ', num2str(vals{idx,1}),...
         ' for basalt ', vals{idx,2},...    
          ' with lambda=',num2str(vals{idx,3}),...
          ' with p80=',num2str(vals{idx,4}),...
          ' at point ', num2str(point)])
      
         % inps is what I save, inpz is what goes 
         % in the model, slight differences
          inps = [];outs = [];
          
          inps.scen   = vals{idx,1};
          inps.iprof  = vals{idx,2};
          inps.iprofi = vals_i(idx,2);
          inps.ibas   = vals{idx,2};
          inps.ibasi  = vals_i(idx,2);
          inps.nam    = dat.Crop;
          inps.nam_l  = dat.nam_l;
          inps.nam_s   = dat.nam_s;
          inps.ind    = dat.indz';
          inps.lind   = dat.lind';
          inps.ar     = dat.area';
          inps.p80    = vals{idx,4};
          inps.yy     = 5;
          inps.spin     = min(inps.yy,5);
          inps.pH     = dat.pH;
          inps.fc     = double(dat.fc);
          inps.lamb   = vals{idx,3};
          inps.lambi  = vals_i(idx,3);
          
          inps.st     = double(dat.st') - 273.15;
          inps.npp    = double(dat.npp');
          inps.co2    = double(dat.co2');
          inps.sr     = double(dat.sr');
          inps.wat    = double(dat.infil'/1000);
          inps.alk    = double(dat.N');
  
          
          %Model goes here
          [outs.c2b_ratio,outs.CO2_mass,outs.Application_Basalt_mass,outs.pH,outs.K_mass,outs.P_mass,outs.CO2_mass_outflow,outs.CO2_mass_precip,...
            outs.Ca,outs.Mg,outs.Na,outs.K,totals] = mod5(inps);
          
          disp(['Finished scenario ', num2str(vals{idx,1}),...
         ' for basalt= ',vals{idx,2},...    
          ' with lambda=',num2str(vals{idx,3}),...
          ' with p80=',num2str(vals{idx,4}),...
          ' at point ', num2str(point)])
      
          % Save inputz
          inputz(idx) = inps;
          %Save outz
          outz(idx) = outs;
        
    end
     
    for idx = 1:size(vals_i,1)
        inputzo(vals_i(idx,1),vals_i(idx,2),vals_i(idx,3),vals_i(idx,4)) = inputz(idx);
        outzo(vals_i(idx,1),vals_i(idx,2),vals_i(idx,3),vals_i(idx,4)) = outz(idx);
    end
     
    cd /home/sm1epk/USA/run_files/resultz/dump_res/
    fnam = ['res_',num2str(point),'_v6or.mat'];
    save(fnam, 'inputzo','outzo')
     
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end

