% Estimation routine
% run initalg('baseline') before running this

function smm
  global alg
  disp('ESTIMATION')

  initpol;

  [par0,pnames] = parse_params(alg.prm_file);
  alg.lasteq = load(alg.eqv_file);

  alg.nparams = length(par0);
  alg.pscale = par0;
                     
  alg.fpar = [9:15];                          % fixed parameters
  alg.spar = setdiff(1:alg.nparams,alg.fpar); % estimated parameters
  alg.nfpar = length(alg.fpar);
  alg.nspar = length(alg.spar);

  alg.plb = zeros(1,alg.nparams);     % lower bound for parameters
  alg.pub = Inf*ones(1,alg.nparams);  % upper bound
  alg.pub([4 11 12]) = 1.0;       
  
  alg.bestval = Inf;
  init_scale  = 0.075;
  start       = ones(1,alg.nspar);
  
  alg.simann = 0;                     % algorithm for estimation

  fprintf('Estimated parameters ==> %s\n',strjoin(pnames(alg.spar),',\0'))
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ESTIMATION STARTS HERE  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (alg.simann == 1)
    [parfin,scfin] = anneal0(@smmobj,start,init_scale); % simulated annealing
  else
    mopts = optimset('Display','iter','MaxFunEvals',100000,'MaxIter',1000000);
    [parfin,scfin] = fminsearch(@smmobj,start,mopts);
  end
  disp('Estimation done!')
  %%%%%%%%%%%%%%%%%%%%%%%%%%

  params = alg.pscale;
  params(alg.spar) = parfin.*alg.pscale(alg.spar); 

end
