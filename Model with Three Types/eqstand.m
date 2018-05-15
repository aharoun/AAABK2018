function [eqfin,eqerr] = eqstand(params)
  global alg
  
  if nargin<1
    putparams();
  else
    putparams(params);
  end

  alg.final = 0;
  options = optimset('Display','off','DiffMinChange',1e-12,'TolFun',1e-12,'UseParallel',false,'MaxFunEvals',100);
  [eqfin,fval,exitflag] = fsolve(@eqfunc,alg.lasteq, options);
  
  if exitflag<1
      [eqfin,eqdiff,exitflag] = fsolve(@eqfunc,eqfin.*exp(randn(length(alg.lasteq),1)*.2),options);
  end
 
  if (exitflag <= 0)
    eqfin = zeros(size(alg.lasteq));
    eqerr = 10000.0;
  else
    alg.final = 1;
    eqnd      = eqfunc(eqfin);
    eqerr     = sqrt(mean(eqnd.^2));
  end

end

