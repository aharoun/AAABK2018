function solver(save_params)
  global alg eq

  if (nargin < 1)
    save_params = 0;  % do not save parameter values
  end  

  putparams();    % put parameters to structure 'p'

  eqv = load(alg.eqv_file);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Solving the equilibrium
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  alg.final = 0;
  if (save_params == 1)
    fprintf('Solving model...')
  end
  [eqfin,~,exitflag] = fsolve(@eqfunc,eqv, alg.optSolver);
  
  if exitflag<1
       %disp('attemting second solver...')
       [eqfin,~,exitflag] = fsolve(@eqfunc,eqv.*exp(randn(length(eqv),1)*.2), alg.optSolver);
  end

  if exitflag<1
       %disp('attemting third solver...')
       [eqfin,~,exitflag] = fsolve(@eqfunc,eqv.*exp(randn(length(eqv),1)*.4), alg.optSolver);
  end 

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  alg.final = 1;
  eqfunc(eqfin);

  if (exitflag >= 0)
   
    if (save_params == 1)
      save(alg.eqv_file,'eqfin','-ascii','-double');

      % save for consumption equivalents
      act_ce = eq.cactivtot;
      g_ce   = eq.g;
      Lp_ce  = eq.Lp;
      save(alg.eqce_file,'act_ce','g_ce','Lp_ce','-ascii','-double');

      output();
      copyfile(['temp_files' filesep 'policy.txt'],['temp_files' filesep 'baseline-' alg.ptag '.txt']);

      % save for social planner
      sp_params = [eq.qmin eq.x]';
      sp_eqvars = [eq.qbar eq.cactiv eq.xout]';
      save(alg.sprm_file,'sp_params','-ascii','-double');
      save(alg.seqv_file,'sp_eqvars','-ascii','-double');

      fprintf('Done!\n')
      fprintf('---\n')
    end

    alg.lasteq = eqfin;
  end 
end