% innovation

function innovation
  global alg p eq

  eq.Delta    = p.kappa*((1/p.blam)^p.eps)*eq.Lp*eq.qPlusEps + p.kappa*p.phi_ns*eq.ws;    % this is the constant in the value function due to hiring (reallocation) cost.
  eq.DeltaOut = p.kappa*((1/p.blam)^p.eps)*eq.Lp*sum(p.alphav.*eq.qPlusEps) + p.kappa*p.phi_ns*eq.ws;

  % innovation rates
  eq.x    = p.thetav.* (((1.0-p.gamma)/eq.ws)*(eq.eyq - eq.Delta)).^((1.0-p.gamma)/p.gamma);   
  eq.xout = p.theta_e.*(((1.0-p.gammaEnt)/eq.ws)*(sum(p.alphav.*eq.eyq) - eq.DeltaOut)).^((1.0-p.gammaEnt)/p.gammaEnt); 
  
  % option value of R&D
  eq.optval = p.gamma*p.thetav.*((1.0-p.gamma)/eq.ws).^((1.0-p.gamma)/p.gamma).*(eq.eyq - eq.Delta).^(1.0/p.gamma); 
  
  % aggregate creative destruction rates
  eq.taus = eq.cactiv.*eq.x + p.alphav*eq.xout;  
  eq.tau  = sum(eq.taus);            
  
  % minimum qhat
  eq.qmin = (max(0,eq.ws*p.phi-eq.optval)/(eq.Lp*p.picf)).^(1.0/(p.eps-1.0));

end

