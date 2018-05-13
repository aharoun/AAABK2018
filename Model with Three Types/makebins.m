% create discretized distribution of quality for firm simulation 
function makebins
  global alg eq b p

  indLast = find((eq.solFAll.y'>0.9999999),1,'first');  
  eq.qmax = eq.solFAll.x(indLast);
  
  b.binmins(alg.nbins+1,1) = 0;     % min values for the binds
  b.binmids(alg.nbins,1)   = 0;     % mid values for the binds 
  b.delqdyn(alg.nbins+1,1) = 0 ;    % width of the binds
 

  % non-uniform grid, more mass points around qmins for accuracy 
  delqmin = alg.qminfact*(eq.qmax-alg.qMinAll)/(alg.nbins+1);
  ddelq = (2.0/(alg.nbins-1))*((eq.qmax-alg.qMinAll)/alg.nbins - delqmin);
  
  b.delqdyn(1) = delqmin;
  b.binmins(1) = alg.qMinAll;
  
  for i=2:alg.nbins+1
      b.delqdyn(i) = b.delqdyn(i-1) + ddelq;
      b.binmins(i) = min(alg.qMaxAll,b.binmins(i-1) + b.delqdyn(i-1));
      b.binmids(i-1) = 0.5*(b.binmins(i)+b.binmins(i-1));
  end

  b.binmidsStep = b.binmids + (p.lam - 1)*(p.omega*eq.qbar + (1 - p.omega)*b.binmids);
    
  eq.step_dists = deval(eq.solFAll,b.binmins(2:end))';
  eq.step_dists = eq.step_dists./eq.step_dists(end);
  
end

