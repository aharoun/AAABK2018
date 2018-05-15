function output
  global pol alg p eq

  % subsidy costs
  ent_subs_cost   = p.ent_subs*eq.ws*eq.cout;     
  fixed_subs_cost = p.fixed_subs*eq.ws*eq.cfix;
  inc_subs_cost   = p.inc_subs*eq.ws*eq.crnd;

  % welfare
  eq.welf  = (1.0/(1.0-p.sigma))*((eq.cactivtot^((1.0-p.sigma)/(p.eps-1.0))/(p.disc-(1.0-p.sigma)*eq.g))-(1.0/p.disc));

  % consumption equivalent terms 
  if (exist(alg.eqce_file) == 2)
    ce_vars = load(alg.eqce_file);
    ce_act  = ce_vars(1);
    ce_g    = ce_vars(2);
    eq.cev  = ((p.disc-(1.0-p.sigma)*ce_g)/(p.disc-(1.0-p.sigma)*eq.g))^(1/(1.0-p.sigma))*...
              ((eq.cactivtot/ce_act)^(1/(p.eps-1)));
  else
      eq.cev = nan;
  end
      
  pol_fid = fopen(['temp_files' filesep 'policy.txt'],'w');
  fprintf(pol_fid,'%10s %10s %10s \n','entry','R&D','fixed');
  fprintf(pol_fid,'%10.4f %10.4f %10.4f  rate\n',p.ent_subs,p.inc_subs,p.fixed_subs);
  fprintf(pol_fid,'%10.4f %10.4f %10.4f  cost\n',ent_subs_cost,inc_subs_cost,fixed_subs_cost);
  fprintf(pol_fid,'\n');
  fprintf(pol_fid,'%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n','xEntry','xlow','xmed','xhigh','philow','phimed','phihigh','qminlow','qminmed','qminhigh','Lrd2Ls','tau','growth','welfare');
  fprintf(pol_fid,'%10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n',eq.xout,eq.x(1),eq.x(2),eq.x(3),eq.cactiv(1),eq.cactiv(2),eq.cactiv(3),eq.qmin(1),eq.qmin(2),eq.qmin(3),(eq.crnd+eq.cout)/eq.skilled_lab,eq.tau,eq.g,eq.cev);
  fprintf(pol_fid,'\n\n');
  fclose(pol_fid);

  % store cost
  if isstruct(pol)
    pol.cost = {};
    pol.cost.ent_subs   = ent_subs_cost;
    pol.cost.inc_subs   = inc_subs_cost;
    pol.cost.fixed_subs = fixed_subs_cost;
  end

end
