% calculate the Ys and the expected value of a new innovation
function calcey

global alg eq p
eq.r = p.disc + p.sigma*eq.g;


eq.eyqAll = alg.w'*eyfunc(alg.chebBin);
eq.eyq(1)   = eq.eyqAll(1);
eq.eyq(2)   = eq.eyqAll(2);
eq.eyq(3)   = eq.eyqAll(3);

end

% Franchise value
function eyout = eyfunc(q)
  global p eq
  [~,out]  = deval(eq.solFAll,q);
  qq = q + (p.lam-1)*(p.omega*eq.qbar + (1 - p.omega)*q);

  eyout = [zfunc(qq,0.0   ,1).*out' ...                                           % LOW TYPE
          (zfunc(qq,p.nuML,2) + zfunc(qq,0.0,1) - zfunc(qq,p.nuML,1)).*out'...    % MEDIUM TYPE
          (zfunc(qq,p.nuHL,3) + zfunc(qq,0.0,1) - zfunc(qq,p.nuHL,1)).*out'...    % HIGH TYPE 
          ];
                           

end


% basis function Z
function zout = zfunc(q,x,s)
  global p eq

  % coefficients
  psit = eq.r + eq.tau + p.psi + x;

  kappa1 = psit + (p.eps-1.0)*eq.g;
  kappa2 = psit;

  coeff1 = p.picf;
  coeff2 = eq.optval(s) - eq.ws*p.phi;

  % this min means that when q <= qmin, qrat = 1.0, so the value contribution is zero
  qrat = min(1.0,eq.qmin(s)./q);  

  zout = coeff1/kappa1*q.^(p.eps-1.0).*(1.0-qrat.^(kappa1/eq.g)) + coeff2/kappa2*(1.0-qrat.^(kappa2/eq.g));

end
