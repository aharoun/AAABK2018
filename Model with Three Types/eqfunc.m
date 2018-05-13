function eqnd = eqfunc(eqv)
  global alg p eq b eqi

  % reject out of bounds
  if (any(eqv<0.0))
    eqnd = -1000.0*ones(size(eqv));
    return
  end

  % load in guesses for solution
  puteqvars(eqv);

  % find updated eqvars
  innovation();
  qualityDist();
  qbarActive();
  calcey();
  labordem();
  

  % equilibrium differences
  eqnd(1)   = eq.skilled_lab - p.Ls;            % labor market clearing
  eqnd(2:4) = eqi.cactiv - eq.cactiv;           % product shares
  eqnd(5:7) = eqi.eyq - eq.eyq;                 % innovated product value
  eqnd(8)   = eq.qbarAct - p.blam^(p.eps - 1);
 
  % final output
  if (alg.final == 1)
     % Create bins for simulation
    makebins();   
    output();  
  end

end

