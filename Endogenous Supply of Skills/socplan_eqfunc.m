function eqnd = socplan_eqfunc(seq)
  global alg p eq opt

  if (any(seq < opt.plbeqFunc') | any(seq > opt.pubeqFunc'))
    %fprintf('BOUNDS\n');
    eqnd = ones(size(opt.lastseq))*100;
  else
    % unpack seq vars
    % these are the variables that we will find given qmin and x 
      eqi = {};
      eqi.qbar   = seq(1);
      eqi.cactiv = seq(2:3)';    % these are the variables that we will find given qmin and x 
      eq.x(2)    = seq(4);
      eqi.Lp     = seq(5);

      eq.qbar   = eqi.qbar;
      eq.cactiv = eqi.cactiv;
      eq.Lp     = eqi.Lp;

    % derived vars
      eq.cactivtot = sum(eq.cactiv);
      eq.cinac     = 1.0-eq.cactivtot;
      eq.ws        = 0.0; % just to make things work

    % aggregate creative destruction rates
      eq.taus = eq.cactiv.*eq.x + p.alphav*eq.xout;   
      eq.tau = sum(eq.taus);
    
    % given guesses, calculate new values 
      labordemSoc();
      qualityDist();
      qbarActive();

    % equation differences
      eqnd(1)   = eq.qbarAct - p.blam^(p.eps - 1);
      eqnd(2:3) = eqi.cactiv - eq.cactiv;
      eqnd(4)   = eq.skilled_lab - eq.skilled_labNew;  % skill labor market clearing
      eqnd(5)   = eqi.Lp - eq.Lp;                      % unskill labor supply clearing
    end

end

