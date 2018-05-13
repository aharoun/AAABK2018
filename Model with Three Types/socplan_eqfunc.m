function eqnd = socplan_eqfunc(seq)
  global alg p eq opt

    % unpack seq vars
    % these are the variables that we will find given qmin and x 
    eqi = {};
    eqi.qbar   = seq(1);
    eqi.cactiv = seq(2:4)';    % these are the variables that we will find given qmin and x 
    eqi.xout   = seq(5);


    eq.qbar   = eqi.qbar;
    eq.cactiv = eqi.cactiv;
    eq.xout   = eqi.xout;

    % derived vars
    eq.cactivtot = sum(eq.cactiv);
    eq.cinac     = 1.0-eq.cactivtot;
    eq.ws        = 0.0; % just to make things work

    % aggregate creative destruction rates
    eq.taus = eq.cactiv.*eq.x + p.alphav*eq.xout;   
    eq.tau = sum(eq.taus);

    % given guesses, calculate new values 
    labordem();
    qualityDist();
    qbarActive();

    % equation differences
    eqnd(1)   = eq.qbarAct - p.blam^(p.eps - 1);
    eqnd(2:4) = eqi.cactiv - eq.cactiv;
    eqnd(5)   = eq.skilled_lab - p.Ls;


end

