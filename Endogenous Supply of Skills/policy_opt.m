% Solving optimal subsidy policies
function policy_opt(pol_type)
 global alg opt

 % Initialize optimal policy search
  if (pol_type == 212)
    disp('Optimal Incumbent and Operation Policy...') 
    pol0 = [0.05 -0.6]; % (incumbent, operating)
  elseif (pol_type == 11)
    disp('Optimal Incumbent Policy...')
    pol0 = 0.1;  % (incumbent)  
  elseif (pol_type == 12)
    disp('Optimal Operation Policy...')  
    pol0 = 0.1 ; % (operating)  
  elseif (pol_type == 13)
    disp('Optimal Entrant Policy...')  
    pol0 = 0.1 ; % (entrant)  
  elseif (pol_type == 0)
    disp('Education Policy')  
    pol0 = [];
  end
  
  pol0 = [pol0 0.85];     % combine with education subsidy  

  opt        = {};
  opt.npols  = length(pol0);
  opt.pscale = pol0;
  opt.plb    = -Inf*ones(1,opt.npols);
  opt.pub    = Inf*ones(1,opt.npols);
  alg.lasteq = load(alg.eqv_file);
  
  opt.bestval = Inf;

  start = ones(1,opt.npols);

  mopts = optimset('Display','off','MaxFunEvals',1000000,'MaxIter',1000000);
  [polfin,scfin] = fminsearch(@(x)policy_obj(x,pol_type),start,mopts);

  % reset policies
  initpol();
  
  if (pol_type == 212)
    copyfile(['temp_files' filesep 'policy_bestOpt.txt'],['temp_files' filesep 'optpol212-' alg.ptag '.txt']);

  elseif (pol_type == 11)
    copyfile(['temp_files' filesep 'policy_bestOpt.txt'],['temp_files' filesep 'optpol11-' alg.ptag '.txt']);

  elseif (pol_type == 12)
    copyfile(['temp_files' filesep 'policy_bestOpt.txt'],['temp_files' filesep 'optpol12-' alg.ptag '.txt']);

  elseif (pol_type == 13)
    copyfile(['temp_files' filesep 'policy_bestOpt.txt'],['temp_files' filesep 'optpol13-' alg.ptag '.txt']);

  elseif (pol_type == 0)
    copyfile(['temp_files' filesep 'policy_bestOpt.txt'],['temp_files' filesep 'optpolEduOnly-' alg.ptag '.txt']);

  end

  if (pol_type == 212)
    disp('Optimal Incumbent and Operation Policy... Done!') 
  elseif (pol_type == 11)
    disp('Optimal Incumbent Policy... Done!') 
  elseif (pol_type == 12)
    disp('Optimal Operation Policy... Done!') 
  elseif (pol_type == 13)
    disp('Optimal Entrant Policy... Done!') 
  elseif (pol_type == 0)
    disp('Education Policy... Done!') 
  end
  fprintf('---\n')
end

function score = policy_obj(polin,pol_type)
  global opt pol alg eq

  pols = polin.*opt.pscale;

  if (any(pols < opt.plb) | any(pols > opt.pub))
    mstr = '2';
    eqfin = zeros(size(alg.lasteq));
    eqerr = 0.0;
    score = 10^5;
  else
    initpol();
        if pol_type == 11
            pol.inc_subs = pols(1);           
        elseif pol_type == 12
            pol.fixed_subs = pols(1);
        elseif pol_type == 13
            pol.ent_subs = pols(1);
        elseif pol_type == 212
            pol.inc_subs = pols(1);
            pol.fixed_subs = pols(2);
        elseif  pol_type == 223
            pol.fixed_subs = pols(1);
            pol.ent_subs = pols(2);
        elseif  pol_type == 213
            pol.inc_subs = pols(1);
            pol.ent_subs = pols(2);
        elseif (pol_type == 0)
        else
            error('Wrong policy type')
        end

        pol.edu_subs = pols(end); % it is always at the end.
        

    [eqfin,eqerr] = eqstand();
    if (eqerr > 5000.0)
      score = 10^5;
      mstr = '1';
    else
      score = -eq.cev;
      mstr = '0';
    end

    if (isnan(score))
      score = 10^5;
    end
    if (isinf(score))
      score = 10^5;
    end

    if (score < opt.bestval)
      alg.lasteq = eqfin;
      opt.bestval = score;
      opt.bestpol = pols;
      copyfile(['temp_files' filesep 'policy.txt'],['temp_files' filesep 'policy_bestOpt.txt']);
      fmt = repmat('%1.4f ',1,length(pols));
      fprintf(1,['  best score = %1.4f (s = ' fmt ')\n'],opt.bestval,opt.bestpol);
    end
  end
  
end

