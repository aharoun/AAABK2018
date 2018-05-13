% calculate excess labor demand

function labordem
  global alg p eq

  % managerial fixed cost
  eq.lU        = (1 - p.beta)*p.phi_ns;           % these are true number of labors, without the effect of subsidy.
  eq.lS        = p.beta*p.phi_ns;
                      

  % production labor
  eq.wu = 1/p.blam;   % -h: unskilled wage over Q.

  % incumbent R&D labor
  eq.cx = (eq.x./(p.thetav_ns.^p.gamma)).^(1.0/(1.0-p.gamma));
  eq.cx(eq.x==0) = 0.0;
  eq.crnd = sum(eq.cactiv.*eq.cx);

  % entrant R&D labor
  eq.cout = (eq.xout./(p.theta_e_ns.^p.gammaEnt)).^(1.0/(1.0-p.gammaEnt));

  % total skilled labor
  eq.skilled_lab = eq.crnd + eq.lS*eq.cactivtot + eq.cout;         
  eq.Lp          = max(0,1.076267222213071 - eq.lU*eq.cactivtot);           % assume that unskill labor supply is 1+x so that worker have mass 1. 
  %eq.Lp          = 1;
  eq.cprod = (eq.Lp/eq.wu)*(1/p.lam);   % NEW    
end

