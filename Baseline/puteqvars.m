function puteqvars(eqvars)
  global alg p eq eqi

  % initial eqvars
  eqi.ws      = eqvars(1);
  eqi.cactiv  = eqvars(2:3)';
  eqi.eyq     = eqvars(4:5)';
  eqi.qbar    = eqvars(6);
  
  % start eq
  eq = eqi;

  % flow of free products
  eq.cactivtot = sum(eq.cactiv);
  eq.cinac     = 1.0 - eq.cactivtot;

end

