function [eqfin,eqerr] = eqstand(params)
  global alg
  
  if nargin<1
    putparams();
  else
    putparams(params);
  end

  alg.final = 0;
  options = optimset('Display','off','DiffMinChange',1e-8,'TolFun',1e-8,'UseParallel',false,'MaxFunEvals',200);
  [eqfin,fval,exitflag] = fsolve(@eqfunc,alg.lasteq, options);
  
  if exitflag<1 | min(abs(fval))> 1e-5
      [eqfin,fval,exitflag] = fsolve(@eqfunc,alg.lasteq.*exp(randn(length(alg.lasteq),1)*.05),options);
  end
 
  if exitflag<1 | min(abs(fval))> 1e-5
      [eqfin,fval,exitflag] = fsolve(@eqfunc,alg.lasteq.*exp(randn(length(alg.lasteq),1)*.25),options);
  end
  
  if (exitflag <= 0) | min(abs(fval))> 1e-5
    eqfin = ones(size(alg.lasteq));
    eqerr = 10000.0;
  else
    alg.final = 1;
    eqnd      = eqfunc(eqfin);
    eqerr     = sqrt(mean(eqnd.^2));
  end

end

