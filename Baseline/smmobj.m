function score = smmobj(parin)
  global alg

  nan_score  = Inf;
  inf_score  = Inf;
  bnd_score  = Inf;
  fail_score = Inf;

  params           = alg.pscale;
  params(alg.spar) = parin.*alg.pscale(alg.spar);


  if (any(params < alg.plb) || any(params > alg.pub))
    fprintf(1,'BOUNDS ERROR\n');
    eqfin = zeros(size(alg.lasteq));
    eqerr = 0.0;
    score = bnd_score;
  else
    [eqfin,eqerr] = eqstand(params);
    
    if (eqerr > 5000.0)
      fprintf(1,'EQ SOLVE FAILED\n');
      score = fail_score;
    else
      score = compMoments();
    end

    if (isnan(score))
      fprintf(1,'SCORE IS NAN\n');
      score = nan_score;
    end
    if (isinf(score))
      fprintf(1,'SCORE IS INF\n');
      score = inf_score;
    end

    if (alg.simann == 0)
      if (~isinf(score))
        alg.lasteq = eqfin;
      end
    end

    if (score < alg.bestval)
      alg.lasteq = eqfin;
      alg.bestval = score;
      % reporting the best
      copyfile(['temp_files' filesep 'moments_format.txt'], ['temp_files' filesep 'moments_best.txt']);
      copyfile(['temp_files' filesep 'params_current.txt'], ['temp_files' filesep 'params_best.txt']);
      copyfile(['temp_files' filesep 'policy.txt'], ['temp_files' filesep 'policy_best.txt']);
    end
  end


  fprintf(1,'current score = %f\n',score);  
  fprintf(1,'best score    = %f\n',alg.bestval);
end

