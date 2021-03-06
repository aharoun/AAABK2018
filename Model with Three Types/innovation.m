% innovation

function innovation
  global alg p eq

  % innovation rates
  eq.x    = p.thetav.* (((1.0-p.gamma)/eq.ws)*eq.eyq).^((1.0-p.gamma)/p.gamma);   
  eq.xout = p.theta_e.*(((1.0-p.gammaEnt)/eq.ws)*sum(p.alphav.*eq.eyq)).^((1.0-p.gammaEnt)/p.gammaEnt); 
  
  % option value of R&D
  eq.optval = p.gamma*p.thetav.*((1.0-p.gamma)/eq.ws).^((1.0-p.gamma)/p.gamma).*eq.eyq.^(1.0/p.gamma); 
  
  % aggregate creative destruction rates
  eq.taus = eq.cactiv.*eq.x + p.alphav*eq.xout;  
  eq.tau  = sum(eq.taus);						 
  
  % minimum qhat
  eq.qmin = (max(0,eq.ws*p.phi-eq.optval)/p.picf).^(1.0/(p.eps-1.0));

end

