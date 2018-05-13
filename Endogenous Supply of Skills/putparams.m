function putparams(params)
% put parameter values into structure 'p'
  global pol alg p
  p = {};

  % read parameters from parameter file
  if (nargin < 1)
    [p,pNames] = readParamFile(alg.prm_file);  
  else
    [~,pNames] = parse_params(alg.prm_file);   % this part is used for estimation
    p = putStructure(params,pNames);  
  end
  
  alg.pvec = cell2mat(struct2cell(p));    % save main parameters in a vector
  
  % derived parameters
  p.lam   = p.lam + 1;  
  p.blam  = p.eps/(p.eps-1.0); 
  p.picf  = (p.blam-1.0)/p.blam^p.eps;
  p.omega = 1.0;

  % transforms of params into vecs over firm type
  p.nuv    = [0.0 p.nu];
  p.alphav = [(1.0-p.alpha) p.alpha];
  p.thetav = [p.theta_l p.theta_h];


  % subsidies
  if isstruct(pol)
    p.ent_subs   = pol.ent_subs;
    p.inc_subs   = pol.inc_subs;
    p.fixed_subs = pol.fixed_subs;
    p.edu_subs   = pol.edu_subs;
  else
    p.ent_subs   = 0.0;
    p.inc_subs   = 0.0;
    p.fixed_subs = 0.0;
    p.edu_subs   = 0.0;
  end
  
  % no subsidies
  p.theta_e_ns = p.theta_e;
  p.phi_ns     = p.phi;
  p.thetav_ns  = p.thetav;

  % R&D subsidy
  inc_mod  = (1.0/(1.0-p.inc_subs))^((1.0-p.gamma)/p.gamma);
  p.thetav = inc_mod*p.thetav;

  % fixed cost subsidy (exit tax)
  fixed_mod = 1.0-p.fixed_subs;
  p.phi     = fixed_mod*p.phi;

  % entry subsidy
  theta_e_mod = (1.0/(1.0-p.ent_subs))^((1.0-p.gammaEnt)/p.gammaEnt);
  p.theta_e    = theta_e_mod*p.theta_e;

end

