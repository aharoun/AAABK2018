% Solves social planner problem
function socplan_opt(type)
  global opt alg
  fprintf(['Social planner problem ' type '...\n'])

  initpol();
  putparams();    % put parameters to structure 'p'
  
  opt         = {};
  par0        = load(alg.sprm_file)';  % the quantities that social planner chooses qmin(1:2) and x(1:2).
  opt.lastseq = load(alg.seqv_file);

  if strcmp(type, 'full') 
    opt.nparams = length(par0);
    opt.pscale  = par0;
  end 

  opt.plb = zeros(1,opt.nparams);
  opt.pub = Inf*ones(1,opt.nparams);
  opt.bestval = Inf;

  start = ones(1,opt.nparams);

  mopts = optimset('Display','off','MaxFunEvals',5000,'MaxIter',1000000);
  [parfin,scfin] = fminsearch(@socplan_obj,start,mopts);

  copyfile(['temp_files' filesep 'policy.txt'], ['temp_files' filesep 'socplan' type '-' alg.ptag '.txt']);
  fprintf(['Social planner problem ' type '... Done!\n'])
  fprintf('---\n')

  function score = socplan_obj(parin)
 
    params = parin.*opt.pscale;

    if (any(params < opt.plb) | any(params > opt.pub))
      seqfin = zeros(size(opt.lastseq));
      seqerr = 0.0;
      score = Inf;
    else
      [welf,cev,seqfin,seqerr] = socplan_solver(params,type);
      score = -cev;

      if (seqerr > 5000.0)
        score = Inf;
      end

      if (isnan(cev))
        score = Inf;
      end
      if (isinf(cev))
        score = Inf;
      end
      if (score < opt.bestval)
        opt.bestval = score;
        opt.lastseq = seqfin;
        copyfile(['temp_files' filesep 'policy.txt'], ['temp_files' filesep 'policy_bestSoc.txt']);
        fprintf(1,'  best score = %1.4f\n',opt.bestval);
      end
    end  
  end

end
