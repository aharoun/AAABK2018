% calculate excess labor demand

function labordem
  global alg p eq

  % managerial fixed cost
  eq.cfix = eq.cactivtot*p.phi_ns;                     
  % production labor
  eq.wu = 1/p.blam;   % unskilled wage over Q.
  eq.cprod = (1.0/eq.wu)*(1/p.lam);   

  % incumbent R&D labor
  eq.cx = (eq.x./(p.thetav_ns.^p.gamma)).^(1.0/(1.0-p.gamma));
  eq.cx(eq.x==0) = 0.0;
  eq.crnd = sum(eq.cactiv.*eq.cx);

  % entrant R&D labor
  eq.cout = (eq.xout./(p.theta_e_ns.^p.gammaEnt)).^(1.0/(1.0-p.gammaEnt));

  % total skilled labor
  eq.skilled_lab = eq.crnd + eq.cfix + eq.cout;      
end

