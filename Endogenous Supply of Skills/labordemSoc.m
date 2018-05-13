% calculate excess labor demand for social planner

function labordemSoc
  global alg p eq

  % managerial fixed cost
  eq.cfix = eq.cactivtot*p.phi_ns;                    

  % production labor
  eq.wu = 1/p.blam;   %  unskilled wage over Q.
  eq.cprod = (eq.Lp/eq.wu)*(1/p.lam);   % NEW
  %eq.cprod = (1.0/eq.wu)*(1/p.lam);   % -h: from equation (17)

  % incumbent R&D labor
  eq.cx = (eq.x./(p.thetav_ns.^p.gamma)).^(1.0/(1.0-p.gamma));
  eq.cx(eq.x==0) = 0.0;
  eq.crnd = sum(eq.cactiv.*eq.cx);

  % entrant R&D labor
  eq.cout = (eq.xout./(p.theta_e_ns.^p.gammaEnt)).^(1.0/(1.0-p.gammaEnt));

  % total skilled labor demand
  eq.skilled_lab = eq.crnd + eq.cfix + eq.cout;         % this is demand for skilled labor in effective terms 


  kappaStar = eq.kappaStar;
  Aconst    = p.skillElas*(p.kappaH^p.skillElas - p.kappaL^p.skillElas)^-1 ;
      
  aux1 = p.labShift*(Aconst/p.skillElas*(p.kappaH^p.skillElas - kappaStar^p.skillElas));
  aux2 = p.labShift*(Aconst/p.skillElas*(p.kappaH^p.skillElas - kappaStar^p.skillElas))*(1 - exp(-p.die*p.aStar)); 
  aux3 = p.labShift*(1 - exp(-p.die*p.aStar))*(Aconst/(p.skillElas-1))*(p.kappaH^(p.skillElas-1) - kappaStar^(p.skillElas-1));
  Ls   = (aux1  - aux2 - aux3);

  eq.skilled_labNew = aux1 - aux2 - aux3;
  eq.Lp  = p.labShift*(Aconst/p.skillElas*(kappaStar^p.skillElas - p.kappaL^p.skillElas));
  eq.Ls  = Ls;
  eq.t2S = aux3/(Ls+aux3+eq.Lp);

end

