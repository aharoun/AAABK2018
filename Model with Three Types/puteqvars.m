function puteqvars(eqvars)
  global alg p eq eqi

  % initial eqvars
  eqi.ws      = eqvars(1);
  eqi.cactiv  = eqvars(2:4)';
  eqi.eyq     = eqvars(5:7)';
  eqi.qbar    = eqvars(8);

  
  % start eq
  eq = eqi;

  % flow of free products
  eq.cactivtot = sum(eq.cactiv);
  eq.cinac     = 1.0 - eq.cactivtot;

end

