function [score,moments] = compMoments()
  global alg p eq b m_vec m_desc m_pos m_wgts ntm

  % compile mex/cpp simulation file if needed
  if (exist('firmsim') == 0)
    cd('mex');
    mex('firmsim.cpp');
    cd('..');
    system(['cp mex/firmsim.' mexext ' .']);
  end

  % Reject if thetas are flipped
  if (p.thetav(2) < p.thetav(1))
    fprintf(1,'FLIPPED THETAS\n');
    score   = Inf;
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
  R_PER_T   = 50;  % number of periods, within a year (discretization)
  N_PERIODS = 5;
  LAST_IDX  = N_PERIODS+1;
  nBpow     = ceil(log2(alg.nbins));

  % scalars for simulation
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

  % quality distribution for the simulation
  qbins  = [b.binmidsStep b.binmidsStep];
  qdists = repmat(eq.step_dists,1,6);
  
  for tid=1:alg.nThreads
    qbins_v{tid}  = qbins;
    qdists_v{tid} = qdists;
  end

  % run mex file for simulation
  fprintf('Firm simulation...')
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
  % DERIVED STATISTICS                                                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  fquality      = logical(dftype);
  fexited       = lfexited;
  fnot_exited   = not(lfexited);  
  n_exited      = sum(fexited);
  n_not_exited  = nF-n_exited;
  type_lo       = (dftype == 0);
  type_hi       = (dftype == 1);
  
 
  % firm age
  PER_LEN       = 1.0/R_PER_T;
  dfage_yr      = dfage*PER_LEN;
  
  % firm selections
  fnever_exited = fnot_exited(:,LAST_IDX);
  fever_exited  = not(fnever_exited);
  n_ever_exited = sum(fever_exited);

  % total shipments
  ship_cf       = ((p.eps-1.0)/p.eps)^(p.eps-1.0);
  dfship        = ship_cf*dfqeps1*eq.Lp;  

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
    lWgtGr          = dflabor_tot(:,1); % will be used for weighting.
  else
    lWgtGr        = ones(length(dflabor_tot),1);   % equal weights
  end
  
  if alg.weightedRD == 1
    lWgtRD          = dflabor_tot(:,1); % will be used for weighting.
  else
    lWgtRD        = ones(length(dflabor_tot),1);   % equal weights
  end
    
  % R&D to shipments ratio
  frnd_to_ship        = dfwage_rnd(:,1)./dfship(:,1);
  frnd_to_ship_Winsor = quantile(frnd_to_ship,[1 - alg.winsorLevel]);
  frnd_to_ship(frnd_to_ship>frnd_to_ship_Winsor) = frnd_to_ship_Winsor; % winsorization 
  
  % geometric means for growth rates
  growth_ship  = (dfship(:,LAST_IDX)       - dfship(:,1))       ./dfship(:,1);
  growth_empl  = (dfwage_tot(:,LAST_IDX)   - dfwage_tot(:,1))   ./dfwage_tot(:,1);
  
  % winsorization
  if alg.winsorGrowth == 1
    growthShip_Winsor = quantile(growth_ship(fnever_exited),[alg.winsorLevel 1 - alg.winsorLevel]);
    growthEmpl_Winsor = quantile(growth_empl(fnever_exited),[alg.winsorLevel 1 - alg.winsorLevel]);
  
    growth_ship(growth_ship<growthShip_Winsor(1)) = growthShip_Winsor(1);
    growth_ship(growth_ship>growthShip_Winsor(2)) = growthShip_Winsor(2);

    growth_empl(growth_empl<growthEmpl_Winsor(1))  = growthEmpl_Winsor(1);
    growth_empl(growth_empl>growthEmpl_Winsor(2))  = growthEmpl_Winsor(2);
  end

  % yearly growth rates
  growth_shipYGross  = (1 + growth_ship) .^0.2;   
  growth_emplYGross  = (1 + growth_empl) .^0.2;
  
  growth_shipYNet  = growth_shipYGross  - 1;
  growth_emplYNet  = growth_emplYGross  - 1;
   
  nquarts = 2;
  % size divison
  empl_cutoff = median(dfwage_tot(:,1));
  sel_empl_1  = (dfwage_tot(:,1) < empl_cutoff);   
  sel_empl_2  = (dfwage_tot(:,1) >= empl_cutoff);

  % age division
  age_cutoff = 10;   
  sel_age_1   = (dfage_yr(:,1) < age_cutoff);
  sel_age_2   = (dfage_yr(:,1) >= age_cutoff);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % TARGETED MOMENTS                                                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % moment storage
  m_vec     = [];
  m_desc    = {};
  m_wgts    = [];
  m_pos     = 1;

  % size transitions
  q_empl_trans           = get_transitions(dfwage_tot,fever_exited,nquarts,LAST_IDX);
  empl_trans_large2small = q_empl_trans(2,1)/N_PERIODS;
  empl_trans_small2large = q_empl_trans(1,2)/N_PERIODS;
  probSmall              = q_empl_trans(3,1);
  
  add_moment(empl_trans_large2small,'empl_trans_large2small',alg.empl_trans_wgt);                   % 1
  add_moment(empl_trans_small2large,'empl_trans_small2large',alg.empl_trans_wgt);                   % 2
  add_moment(probSmall,'probSmall',alg.empl_trans_wgt);                                             % 3

  % fraction of firms less than 5 years old
  sel_5yr   = (dfage_yr(:,1) <= 5.0);
  share_5yr = mean(sel_5yr);         
  add_moment(share_5yr,'share_5yr',alg.entrant_share_wgt);                                          % 4

  % aggregate growth
  add_moment(eq.g,'aggregate growth',alg.agg_growth_wgt); % baseline weight is 5                    % 5


   % firm exit rate
  firm_exit_rate_s1_a1 = mean(fever_exited(sel_empl_1&sel_age_1))/N_PERIODS;
  firm_exit_rate_s1_a2 = mean(fever_exited(sel_empl_1&sel_age_2))/N_PERIODS;
  firm_exit_rate_s2_a2 = mean(fever_exited(sel_empl_2&sel_age_2))/N_PERIODS;
  
  add_moment(firm_exit_rate_s1_a1,'firm_exit_rate_s1_a1',alg.exit_wgt_s1_a1);                                   % 6
  add_moment(firm_exit_rate_s1_a2,'firm_exit_rate_s1_a2',alg.exit_wgt_s1_a2);                                   % 7
  add_moment(firm_exit_rate_s2_a2,'firm_exit_rate_s2_a2',alg.exit_wgt_s2_a2);                                   % 8
  
  % R&D to shipments
  mean_rnd_to_ship_s1_a1 = meanWeighted(frnd_to_ship(sel_empl_1&sel_age_1),lWgtRD(sel_empl_1&sel_age_1));
  mean_rnd_to_ship_s1_a2 = meanWeighted(frnd_to_ship(sel_empl_1&sel_age_2),lWgtRD(sel_empl_1&sel_age_2));
  mean_rnd_to_ship_s2_a2 = meanWeighted(frnd_to_ship(sel_empl_2&sel_age_2),lWgtRD(sel_empl_2&sel_age_2));
  
  add_moment(mean_rnd_to_ship_s1_a1,'mean_rnd_to_ship_s1_a1_imp',alg.rnd_impute_wgt_s1_a1);                     % 9
  add_moment(mean_rnd_to_ship_s1_a2,'mean_rnd_to_ship_s1_a2_imp',alg.rnd_impute_wgt_s1_a2);                     % 10
  add_moment(mean_rnd_to_ship_s2_a2,'mean_rnd_to_ship_s2_a2_imp',alg.rnd_impute_wgt_s2_a2);                     % 11
  
  % shipments growth
  mean_ship_growth_s1_a1 = geoMeanWeighted(growth_shipYGross(sel_empl_1&sel_age_1&fnever_exited),lWgtGr(sel_empl_1&sel_age_1&fnever_exited))-1;    
  mean_ship_growth_s1_a2 = geoMeanWeighted(growth_shipYGross(sel_empl_1&sel_age_2&fnever_exited),lWgtGr(sel_empl_1&sel_age_2&fnever_exited))-1;    
  mean_ship_growth_s2_a2 = geoMeanWeighted(growth_shipYGross(sel_empl_2&sel_age_2&fnever_exited),lWgtGr(sel_empl_2&sel_age_2&fnever_exited))-1;
  
  add_moment(mean_ship_growth_s1_a1,'mean_ship_growth_s1_a1_def',alg.ship_growth_deflate_wgt_s1_a1);            % 12   
  add_moment(mean_ship_growth_s1_a2,'mean_ship_growth_s1_a2_def',alg.ship_growth_deflate_wgt_s1_a2);            % 13
  add_moment(mean_ship_growth_s2_a2,'mean_ship_growth_s2_a2_def',alg.ship_growth_deflate_wgt_s2_a2);            % 14   

  % employment growth
  mean_empl_growth_s1_a1 = geoMeanWeighted(growth_emplYGross(sel_empl_1&sel_age_1&fnever_exited),lWgtGr(sel_empl_1&sel_age_1&fnever_exited))-1;   
  mean_empl_growth_s1_a2 = geoMeanWeighted(growth_emplYGross(sel_empl_1&sel_age_2&fnever_exited),lWgtGr(sel_empl_1&sel_age_2&fnever_exited))-1;   
  mean_empl_growth_s2_a2 = geoMeanWeighted(growth_emplYGross(sel_empl_2&sel_age_2&fnever_exited),lWgtGr(sel_empl_2&sel_age_2&fnever_exited))-1;
  
  add_moment(mean_empl_growth_s1_a1,'mean_empl_growth_s1_a1',alg.empl_growth_wgt_s1_a1);                        % 15
  add_moment(mean_empl_growth_s1_a2,'mean_empl_growth_s1_a2',alg.empl_growth_wgt_s1_a2);                        % 16
  add_moment(mean_empl_growth_s2_a2,'mean_empl_growth_s2_a2',alg.empl_growth_wgt_s2_a2);                        % 17

  % Fixed Cost-R&D Labor Ratio
  fixedtoRDLab = eq.cfix/eq.crnd;
  add_moment(fixedtoRDLab,'Fixed Cost-R&D Labor Ratio',alg.fixedtoRDLab_wgt);                                   % 18

                                                    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SCORE AND STORE MOMENTS                                                   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  nm = length(m_vec);

  % load in data moments
  dat_full = csvread(alg.mmt_file);
  datm = dat_full(:,1);

  % moment error
  m_err = m_vec'-datm;

  % used moments
  wlist = m_wgts > 0.0;
  n_used = sum(wlist);
  moments = m_vec(wlist);

  % mask
  m_err_used = wlist.*m_err';

  % SCORE
  score = sum(m_wgts'.*(abs(m_err_used')./(0.5*abs(m_vec')+0.5*abs(datm))))/n_used; 

  % save moments
  % construct cell array
  bigcell = cell(nm,6);
  bigcell(:,1) = num2cell(m_vec);
  bigcell(:,2) = num2cell(datm);
  bigcell(:,3) = num2cell(1:nm);
  bigcell(:,4) = m_desc;
  bigcell(:,5) = num2cell(m_wgts);

  fmfid = fopen('temp_files/moments_format.txt','w');

  fprintf(fmfid,'%10s %10s %5s %30s %10s\n','model','data','#','description','weight');
  for i=1:nm
    if (wlist(i))
    fprintf(fmfid,'%10.6f %10.6f %5i %30s %10.6f\n',bigcell{i,1},bigcell{i,2},bigcell{i,3},bigcell{i,4},bigcell{i,5});
    end
  end
  fprintf(fmfid,'\nscore = %10.6f\n\n',score);
  fclose(fmfid);

  % save parameters used in simulation
  writeParams('temp_files/params_current.txt',alg.pvec);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % NON-TARGETED MOMENTS                                                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % -----------------------------------------------------
  % r&d and innovation at establishment level (panel B)
  % -----------------------------------------------------

  qualLow                 = dqualityDistSim(~fquality(:,1),:);
  qualLow                 = qualLow(:);
  qualLow(qualLow == 0)   = [];
  qualLowEps1             = qualLow.^(p.eps - 1);
  
  dfwage_rndEstabLow      = eq.ws*eq.cx(1)*ones(length(qualLow),1);     
  labor_cf                = ((p.eps-1.0)/p.eps)^(p.eps-1.0);
  dflabor_totEstabLow     = eq.cx(1) + p.phi_ns + labor_cf*qualLowEps1;
  ntm.rdExpPerEmpEstabLow = mean(dfwage_rndEstabLow./dflabor_totEstabLow);

  qualHigh              = dqualityDistSim(fquality(:,1),:);
  qualHigh              = qualHigh(:);
  qualHigh(qualHigh==0) = [];
  qualHighEps1          = qualHigh.^(p.eps - 1);
  
  dfwage_rndEstabHigh      = eq.ws*eq.cx(2)*ones(length(qualHigh),1);     
  dflabor_totEstabHigh     = eq.cx(2) + p.phi_ns + labor_cf*qualHighEps1;
  ntm.rdExpPerEmpEstabHigh = mean(dfwage_rndEstabHigh./dflabor_totEstabHigh);
  
  ntm.patPerEmpEstabLow  = mean(dfngain_rnd((~fquality(:,1))&fnot_exited(:,2),2)...
                              ./dfwage_tot((~fquality(:,1))&fnot_exited(:,2),1));
  ntm.patPerEmpEstabHigh = mean(dfngain_rnd( fquality(:,1) &fnot_exited(:,2),2)...
                              ./dfwage_tot(  fquality(:,1) &fnot_exited(:,2),1));
  % -----------------------------------------------------
  % TFP by age-size (panel C)
  % -----------------------------------------------------
  prodMatrix      = logical(dqualityDistSim);
  labor_cf        = ((p.eps-1.0)/p.eps)^(p.eps-1.0);
  dflabor_managPP = p.phi_ns*prodMatrix;
  dflabor_prodPP  = labor_cf*dqualityDistSim.^(p.eps-1); 
  dflabor_rndPP   = repmat(eq.cx(dftype(:,1)+1)',1,size(prodMatrix,2)).*prodMatrix;
  dflabor_totPP   = dflabor_managPP + dflabor_prodPP + dflabor_rndPP;

  outputProd = (((p.eps-1.0)/p.eps)^p.eps)*dqualityDistSim.^(p.eps); % output at the product level at t=0
  tfpProd    = outputProd./ dflabor_totPP;

  tfpFirmAvg = mean(tfpProd,2,'omitnan');
  tfpFirmAvg = tfpFirmAvg./mean(tfpFirmAvg);

  for i=1:2
    for j=1:2
      eval(['tfpAux = tfpFirmAvg(sel_empl_' num2str(i) '&sel_age_' num2str(j) ');']);
      ntm.tfpSM.(['quan' num2str(i) num2str(j)]) = quantile(tfpAux,[ .25  .75]);
    end
  end
  % -----------------------------------------------------
  % Statistics based on product line dist (panel D)
  % -----------------------------------------------------
  nprod    = dfnprod(:,1);
  prodDist = [];

  for i = 1:max(nprod)
    prodDist  = [prodDist;sum(nprod==i)];
  end
  ntm.prodDist = prodDist./sum(prodDist);

  ntm.product.neither  = mean((dfngain_rnd(fnever_exited,end)==0)&(dfnlose(fnever_exited,end)==0));
  ntm.product.soleAdd  = mean((dfngain_rnd(fnever_exited,end)>0) &(dfnlose(fnever_exited,end)==0));
  ntm.product.soleDrop = mean((dfngain_rnd(fnever_exited,end)==0)&(dfnlose(fnever_exited,end)>0));
  ntm.product.either   = 1 - ntm.product.soleAdd - ntm.product.soleDrop - ntm.product.neither;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UTILITY FUNCTIONS                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function qrout = get_quarts(nq,nel)
  qdivs = floor((1:nq)/nq*nel);
  qrout = zeros(nq,2);
  qrout(1,1) = 1;
  for q = 1:(nq-1)
    qrout(q,2)   = qdivs(q);
    qrout(q+1,1) = qrout(q,2)+1;
  end
  qrout(nq,2) = nel;
end

function qsets = get_quart_sets(rank_vec,qrange,nquarts)
  rv_size = size(rank_vec);
  if (rv_size(2) == 1)
    qsets = logical(zeros(rv_size(1),nquarts));
    for q = 1:nquarts
      qsets(rank_vec(qrange(q,1):qrange(q,2)),q) = 1;
    end
  else
    qsets = logical(zeros(rv_size(1),rv_size(2),nquarts));
    for q = 1:nquarts
      for t = 1:rv_size(2)
        qsets(rank_vec(qrange(q,1):qrange(q,2),t),t,q) = 1;
      end
    end
  end
end

function q_trans = get_transitions(fdata,fever_exited,nquarts,LAST_IDX)
  nF = length(fdata);
  fnever_exited = not(fever_exited);
  n_ever_exited = sum(fever_exited);

  [fdata_sort_0,fdata_rank_0] = sort(fdata(:,1),1);
  [fdata_sort_1,fdata_rank_1] = sort(fdata(:,LAST_IDX),1);

  ibase_0 = find(fdata_sort_0,1)-1;
  ibase_1 = find(fdata_sort_1,1)-1;

  if (isempty(ibase_0))
    ibase_0 = 0;
  end
  if (isempty(ibase_1))
    ibase_1 = 0;
  end

  npos_0 = nF-ibase_0;
  npos_1 = nF-ibase_1;

  qrange_0 = ibase_0+get_quarts(nquarts,npos_0);
  qrange_1 = ibase_1+get_quarts(nquarts,npos_1);

  quart_sets_0 = get_quart_sets(fdata_rank_0,qrange_0,nquarts);
  quart_sets_1 = get_quart_sets(fdata_rank_1,qrange_1,nquarts);

  q_trans = zeros(nquarts+1,nquarts+1);
  for q0 = 1:nquarts
    quart_size = sum(quart_sets_0(:,q0));
    for q1 = 1:nquarts
      q_trans(q0,q1) = sum(quart_sets_0(:,q0).*quart_sets_1(:,q1).*fnever_exited)/quart_size;
    end
    q_trans(q0,nquarts+1) = sum(quart_sets_0(:,q0).*fever_exited)/quart_size;
    q_trans(nquarts+1,q0) = sum(quart_sets_1(:,q0).*fever_exited)/n_ever_exited;
  end
end


function add_moment(m_val,m_str,m_wgt)
  global m_vec m_desc m_pos m_wgts

  m_vec(m_pos)  = m_val;
  m_desc{m_pos} = m_str;
  m_wgts(m_pos) = m_wgt;
  m_pos         = m_pos + 1;
end

