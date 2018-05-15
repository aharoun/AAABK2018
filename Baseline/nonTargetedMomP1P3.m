% simulation for 10-year period for calculating some nontargeted moments
function [] = nonTargetedMomP1P3()
  global alg p eq b m_vec m_desc m_pos m_wgts ntmP

  % compile mex/cpp simulation file if needed
  if (exist('firmsim') == 0)
    cd('mex');
    mex('firmsim.cpp');
    cd('..');
    copyfile(['mex' filesep 'firmsim.' mexext],['firmsim.' mexext]);
  end

  % Reject if thetas are flipped
  if (p.thetav(2) < p.thetav(1))
    fprintf(1,'FLIPPED THETAS\n');
    score = Inf;
    moments = 2*ones(20);
    return
  end

  % parallelize firm simulation
  if alg.parallel == 1
    if exist('gcp')
      pool = gcp('nocreate');
      if isempty(pool)
        parpool('local',alg.nCores);
      end
    else
      try matlabpool local alg.nCores, catch ME, end
    end
  end

  % fixing seed for reproducibility
  seed_v = {191871,7045891,13432,756756};


  % constants
  R_PER_T   = 50;  
  N_PERIODS = 10;
  MID_IDX   = 6;
  LAST_IDX  = N_PERIODS+1;

  nBpow = ceil(log2(alg.nbins));
  nB = 2^nBpow;

  % scalars
  nu    = p.nu;
  psi   = p.psi;
  pqual = p.alpha;  
  epst  = p.eps;
  g     = eq.g;
  xt    = eq.x;
  qmint = eq.qmin;
  taut  = eq.tau;
  rhot  = 0;          
  xoutt = eq.xout;


  qbins  = [b.binmidsStep b.binmidsStep];
  qdists = repmat(eq.step_dists,1,6);
  
  for tid=1:alg.nThreads
    qbins_v{tid} = qbins;
    qdists_v{tid} = qdists;
  end

  % firm simulation
  fprintf('Additional nontargeted moments...')
  parfor (tid = 1:alg.nThreads,alg.parallel*alg.nCores)
    [fage_v{tid},ftype_v{tid},fnprod_v{tid},fqeps1_v{tid},fexited_v{tid},fnorig_v{tid},fqeps1_orig_v{tid},flast_state_v{tid},fngain_rnd_v{tid},fngain_res_v{tid},fnlose_v{tid},qualDist{tid},fqeps_v{tid}] = firmsim(nBpow,qbins_v{tid},qdists_v{tid},xt,qmint,taut,rhot,xoutt,epst,g,nu,psi,pqual,int32(R_PER_T),seed_v{tid},int32(N_PERIODS),alg.nThreads);
  end
  fprintf('Done!\n')
  fprintf('---\n')

  % merge threads
  fage           = vertcat(fage_v{:});
  ftype          = vertcat(ftype_v{:});
  fnprod         = vertcat(fnprod_v{:});
  fqeps1         = vertcat(fqeps1_v{:});
  fexited        = vertcat(fexited_v{:});
  fnorig         = vertcat(fnorig_v{:});
  fqeps1_orig    = vertcat(fqeps1_orig_v{:});
  flast_state    = vertcat(flast_state_v{:});
  fngain_rnd     = vertcat(fngain_rnd_v{:});
  fngain_res     = vertcat(fngain_res_v{:});
  fnlose         = vertcat(fnlose_v{:});
  qualityDistSim = vertcat(qualDist{:});
  fqeps          = vertcat(fqeps_v{:});
  

  % cast types
  dfage           = double(fage);
  dftype          = double(ftype);
  dfnprod         = double(fnprod);
  dfqeps1         = double(fqeps1);
  lfexited        = logical(fexited);
  dfnorig         = double(fnorig);
  dfqeps1_orig    = double(fqeps1_orig);
  dflast_state    = double(flast_state);
  dfngain_rnd     = double(fngain_rnd);
  dfngain_res     = double(fngain_res);
  dfnlose         = double(fnlose);
  dqualityDistSim = double(qualityDistSim);
  dfqeps          = double(fqeps);
  nF              = length(dfage);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% DERIVED STATISTICS                                                      %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  fquality      = logical(dftype);
  fexited       = lfexited;
  fnot_exited   = not(lfexited);  
  n_exited      = sum(fexited);
  n_not_exited  = nF-n_exited;
  type_lo       = (dftype == 0);
  type_hi       = (dftype == 1);
  
 
  % firm and sector ages
  PER_LEN       = 1.0/R_PER_T;
  dfage_yr      = dfage*PER_LEN;
  
  % firm selections
  fnever_exitedP1P3 = fnot_exited(:,LAST_IDX);
  fnever_exitedP1P2 = fnot_exited(:,MID_IDX);
  fever_exitedP1P3  = not(fnever_exitedP1P3);
  fever_exitedP1P2  = not(fnever_exitedP1P2);


  % total shipments
  ship_cf       = ((p.eps-1.0)/p.eps)^(p.eps-1.0);
  dfship        = ship_cf*dfqeps1;  

  % wage bills
  dfrnd_rate    = eq.x(dftype+1).*dfnprod;
  wage_bill_cf  = ((p.eps-1.0)/p.eps)^(p.eps);
  dfwage_manag  = eq.ws*p.phi_ns*dfnprod;
  dfwage_prod   = wage_bill_cf*dfqeps1;
  dfwage_rnd    = eq.ws*eq.cx(dftype+1).*dfnprod;     
  dfwage_tot    = dfwage_manag + dfwage_prod + dfwage_rnd;
  
  % worker counts
  labor_cf      = ((p.eps-1.0)/p.eps)^(p.eps-1.0);
  dflabor_manag = p.phi_ns*dfnprod;
  dflabor_prod  = labor_cf*dfqeps1; 
  dflabor_rnd   = eq.cx(dftype+1).*dfnprod;
  dflabor_tot   = dflabor_manag + dflabor_prod + dflabor_rnd;

  if alg.weightedGr == 1
    lWgtGr          = dfwage_tot(:,1); % will be used for weighting.
  else
    lWgtGr        = ones(length(dfwage_tot),1);   % equal weights
  end
  
  if alg.weightedRD == 1
    lWgtRD          = dfwage_tot(:,1); % will be used for weighting.
  else
    lWgtRD        = ones(length(dfwage_tot),1);   % equal weights
  end
    
  
  % R&D to shipment ratio
  frnd_to_shipP2        = dfwage_rnd(:,MID_IDX)./dfship(:,MID_IDX);
  frnd_to_shipP2_Winsor = quantile(frnd_to_shipP2(fnever_exitedP1P3),[1 - alg.winsorLevel]);
  frnd_to_shipP2(frnd_to_shipP2>frnd_to_shipP2_Winsor) = frnd_to_shipP2_Winsor; % winsorization 
  

  % Employment growth rates
  growth_emplP1P2 = (dfwage_tot(:, MID_IDX)  - dfwage_tot(:,1))      ./dfwage_tot(:,1);
  growth_emplP2P3 = (dfwage_tot(:,LAST_IDX)  - dfwage_tot(:,MID_IDX))./dfwage_tot(:,MID_IDX);

  empl_cutoff = quantile(growth_emplP1P2(fnever_exitedP1P3),.90);
  sel_empl_1  = (growth_emplP1P2 <  empl_cutoff);   
  sel_empl_2  = (growth_emplP1P2 >= empl_cutoff);

  
  % growth winsorization
  if alg.winsorGrowth == 1
    growthEmpl_Winsor = quantile(growth_emplP1P2(fnever_exitedP1P3),[alg.winsorLevel 1 - alg.winsorLevel]);
    growth_emplP1P2(growth_emplP1P2<growthEmpl_Winsor(1))  = growthEmpl_Winsor(1);
    growth_emplP1P2(growth_emplP1P2>growthEmpl_Winsor(2))  = growthEmpl_Winsor(2);
    
    growthEmpl_Winsor = quantile(growth_emplP2P3(fnever_exitedP1P3),[alg.winsorLevel 1 - alg.winsorLevel]);
    growth_emplP2P3(growth_emplP2P3<growthEmpl_Winsor(1))  = growthEmpl_Winsor(1);
    growth_emplP2P3(growth_emplP2P3>growthEmpl_Winsor(2))  = growthEmpl_Winsor(2); 
  end
 
  growth_emplYGrossP2P3  = (1 + growth_emplP2P3).^0.2;

  % ------------------------------------------------------
  % Persistency of growth (panel A)
  % ------------------------------------------------------
  ntmP.mean_rnd_to_shipP2_empl_1 = meanWeighted(frnd_to_shipP2(sel_empl_1&fnever_exitedP1P3),lWgtRD(sel_empl_1&fnever_exitedP1P3));
  ntmP.mean_rnd_to_shipP2_empl_2 = meanWeighted(frnd_to_shipP2(sel_empl_2&fnever_exitedP1P3),lWgtRD(sel_empl_2&fnever_exitedP1P3)); 
  
  ntmP.mean_empl_growthP23_empl_1 = geoMeanWeighted(growth_emplYGrossP2P3(sel_empl_1&fnever_exitedP1P3),lWgtGr(sel_empl_1&fnever_exitedP1P3)) - 1;   
  ntmP.mean_empl_growthP23_empl_2 = geoMeanWeighted(growth_emplYGrossP2P3(sel_empl_2&fnever_exitedP1P3),lWgtGr(sel_empl_2&fnever_exitedP1P3)) - 1; 


  % -----------------------------------------------------
  % Growth decomposition
  % -----------------------------------------------------
  year = 10;
  delt = 1/R_PER_T;
  gCum = (1+delt*eq.g)^(year/delt);

  VA2Labor   = dfqeps./dflabor_tot;  % per labor 
  VA2LaborT1 = VA2Labor(:,1);
  VA2LaborT2 = VA2Labor(:,LAST_IDX)*gCum;          % value added grows at rate g with the Q.
  sT1        = dflabor_tot(:,1)    ./sum(dflabor_tot(:,1));
  sT2        = dflabor_tot(:,LAST_IDX)./sum(dflabor_tot(:,LAST_IDX));
  DeltaTheta =  sT2'*VA2LaborT2 - sT1'*VA2LaborT1;       % this is direct calculation 

  % now the decomposition
  cFirms   = fnever_exitedP1P3; % continuing firm
  xFirms   = fever_exitedP1P3;  % exiters
  eFirms   = fever_exitedP1P3;  % new entrants, same with exiters because for each exiting firms, a new firm enters in the stationary equilibrium.  

  between = (VA2LaborT1(cFirms)' - sT1'*VA2LaborT1)*(sT2(cFirms) - sT1(cFirms));
  cross   = (sT2(cFirms) - sT1(cFirms))'*(VA2LaborT2(cFirms) - VA2LaborT1(cFirms));
  within  = sT1(cFirms)'*(VA2LaborT2(cFirms) - VA2LaborT1(cFirms));
  entry   = sT2(eFirms)'*(VA2LaborT2(eFirms) - sT1'*VA2LaborT1);
  exit    = sT1(xFirms)'*(VA2LaborT1(xFirms) - sT1'*VA2LaborT1);

  DeltaThetaCheck = within + between + cross + entry - exit;

  % shares
  ntmP.growthDecomp.withinShare  = within  /DeltaTheta;
  ntmP.growthDecomp.betweenShare = between /DeltaTheta;
  ntmP.growthDecomp.crossShare   = cross   /DeltaTheta;
  ntmP.growthDecomp.entryShare   = entry   /DeltaTheta;
  ntmP.growthDecomp.exitShare    = -exit   /DeltaTheta;
  ntmP.growthDecomp.growthCum    = gCum;


  % Reporting

  fileName = ['temp_files' filesep 'non_targetedPanelA-' alg.ptag '.txt'];
  fid = fopen(fileName,'w');
  fprintf(fid,'Panel A\n');
  fprintf(fid,'%-40s %1.3f\n', 'Employment growth of bottom 90 perc.',ntmP.mean_empl_growthP23_empl_1);
  fprintf(fid,'%-40s %1.3f\n', 'Employment growth of top 10 perc.'   ,ntmP.mean_empl_growthP23_empl_2);
  fprintf(fid,'%-40s %1.3f\n', 'R&D to sales of bottom 90 perc.'     ,ntmP.mean_rnd_to_shipP2_empl_1);
  fprintf(fid,'%-40s %1.3f\n', 'R&D to sales of top 10 perc.'        ,ntmP.mean_rnd_to_shipP2_empl_2);
  fprintf(fid,'\n');
  fclose(fid);

  fileName = ['temp_files' filesep 'growthDecomp-' alg.ptag '.txt'];
  fid = fopen(fileName,'w');
  fprintf(fid,'GROWTH DECOMPOSITION\n');
  fprintf(fid,'-------------------------------\n');
  fprintf(fid,'%-40s %1.3f\n', 'Within share'             ,ntmP.growthDecomp.withinShare);
  fprintf(fid,'%-40s %1.3f\n', 'Between share'            ,ntmP.growthDecomp.betweenShare);
  fprintf(fid,'%-40s %1.3f\n', 'Cross share'              ,ntmP.growthDecomp.crossShare);
  fprintf(fid,'%-40s %1.3f\n', 'Entry share'              ,ntmP.growthDecomp.entryShare);
  fprintf(fid,'%-40s %1.3f\n', 'Exit share'               ,ntmP.growthDecomp.exitShare);
  fprintf(fid,'%-40s %1.3f\n', 'Net entry share'          ,ntmP.growthDecomp.entryShare + ntmP.growthDecomp.exitShare);
  fprintf(fid,'%-40s %1.3f\n', '10-year Cumulative Growth',ntmP.growthDecomp.growthCum - 1);  
  fclose(fid);

 end
