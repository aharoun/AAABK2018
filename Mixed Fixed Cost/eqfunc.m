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
  eqnd(1)   = eq.skilled_lab - p.Ls;                 % skilled labor market clearing
  eqnd(2:3) = eqi.cactiv     - eq.cactiv;            % product shares
  eqnd(4:5) = eqi.eyq        - eq.eyq;               % innovated product value
  eqnd(6)   = eq.qbarAct     - p.blam^(p.eps - 1);
  eqnd(7)   = eqi.Lp - eq.Lp;                        % production worker

 
  % final output
  if (alg.final == 1)
     % Create bins for simulation
    makebins();   
    output();  
  end

end

