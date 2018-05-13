% innovation

function innovation
  global alg p eq

  % innovation rates
  eq.x    = p.thetav.* (((1.0-p.gamma)/eq.ws)*eq.eyq).^((1.0-p.gamma)/p.gamma);   
  eq.xout = p.theta_e.*(((1.0-p.gammaEnt)/eq.ws)*sum(p.alphav.*eq.eyq)).^((1.0-p.gammaEnt)/p.gammaEnt); % -h: entrants have a different curvature parameter
  
  % option value of R&D
  eq.optval = p.gamma*p.thetav.*((1.0-p.gamma)/eq.ws).^((1.0-p.gamma)/p.gamma).*eq.eyq.^(1.0/p.gamma); % Correct
  
  % aggregate creative destruction rates
  eq.taus = eq.cactiv.*eq.x + p.alphav*eq.xout;  
  eq.tau  = sum(eq.taus);						 % -h: tau is already per product line
  
  % minimum qhat
  eq.wu        = 1/p.blam;   % -h: unskilled wage over Q.
  eq.fixedCost = p.phi*(p.beta*eq.ws + (1 - p.beta)*eq.wu);
  eq.qmin      = (max(0,eq.fixedCost - eq.optval)/(eq.Lp*p.picf)).^(1.0/(p.eps-1.0));


end

