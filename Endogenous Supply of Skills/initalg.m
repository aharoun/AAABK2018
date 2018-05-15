function initalg(pid)
  % Setting global parameters
  global alg
  alg = {};
  
  % parameters to use
  alg.ptag = pid;

  % parameters for data storage size
  alg.nft             = 2;      % Number of types
  alg.nbins           = 2^12;   % number of grid points for quality dist.
  alg.qMinAll         = 0.000000001;
  alg.qMaxAll         = 10;

  [alg.chebBin,alg.w] = gaussCheb(4000,alg.qMinAll,alg.qMaxAll);  % Chebyshev nodes for integration
  alg.optDD           = ddeset('RelTol',1e-4','AbsTol',1e-6,'Stats','off');
  alg.optBVP          = bvpset('Vectorized','on','RelTol',1e-4,'AbsTol',1e-6,'Stats','off');
  alg.optSolver       = optimset('Display','off','DiffMinChange',1e-12,'TolFun',1e-12, ...
                       'TolX',1e-12,'UseParallel',false,'MaxFunEvals',200);
  
  % simulation parameters
  alg.qminfact     = 0.01;
  alg.qmaxfact     = 1.0;
  alg.weightedGr   = 0;
  alg.weightedRD   = 0;
  alg.winsorGrowth = 1;
  alg.winsorLevel  = 0.005;
  alg.nThreads     = 4;
  alg.parallel     = 0;   % use parallelization for firm simulation, 0 or 1
  alg.nCores       = 4;   % number of cores to parallelize  

  % Moment weights in the estimation
  alg.agg_growth_wgt                = 5.0;
  alg.empl_trans_wgt                = 1.0;
  alg.entrant_share_wgt             = 1.0;    
  alg.fixedtoRDLab_wgt              = 1.0;
  alg.exit_wgt_s1_a1                = 1.0;
  alg.exit_wgt_s1_a2                = 1.0;
  alg.exit_wgt_s2_a2                = 1.0;
  alg.rnd_impute_wgt_s1_a1          = 1.0;
  alg.rnd_impute_wgt_s1_a2          = 1.0;
  alg.rnd_impute_wgt_s2_a2          = 1.0;
  alg.ship_growth_deflate_wgt_s1_a1 = 1.0;
  alg.ship_growth_deflate_wgt_s1_a2 = 1.0;
  alg.ship_growth_deflate_wgt_s2_a2 = 1.0;
  alg.empl_growth_wgt_s1_a1         = 1.0;
  alg.empl_growth_wgt_s1_a2         = 1.0;
  alg.empl_growth_wgt_s2_a2         = 1.0;

  if strcmp(pid, 'employmentWeighted')
    alg.weightedGr   = 1;
    alg.weightedRD   = 1;
  end

  if strcmp(pid, 'manufacturingSample')
    alg.rnd_impute_wgt_s1_a1          = 0.0;
    alg.rnd_impute_wgt_s1_a2          = 0.0;
    alg.rnd_impute_wgt_s2_a2          = 0.0;
  end

  % file names
  alg.prm_file     = ['params' filesep 'params-' alg.ptag  '.txt'];
  alg.sprm_file    = ['temp_files' filesep 'sparams-' alg.ptag '.txt'];
  alg.eqv_file     = ['eqvars' filesep 'eqvars-' alg.ptag  '.txt'];
  alg.seqv_file    = ['temp_files' filesep 'seqvars-' alg.ptag '.txt'];
  alg.mmt_file     = ['moments' filesep alg.ptag 'Moments.csv'];
  alg.eqce_file    = ['temp_files' filesep 'ce_vars.txt'];
  
end

