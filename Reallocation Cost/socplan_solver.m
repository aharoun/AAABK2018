function [welf,cev,seqfin,seqerr] = socplan_solver(pvars,type)
  global opt alg p eq

  % unpack choice vars
  if strcmp(type, 'full')
    eq.qmin = pvars(1:2);
    eq.x    = pvars(3:4);
  elseif strcmp(type, 'onlyQmin')  
    eq.x    = [0.259035577308632   0.381344826619713];       % fixing at baseline values
    eq.qmin = pvars(1:2);
  elseif strcmp(type, 'onlyX')    
    eq.qmin = [ 1.472617412516069   1.303344435379950];   % fixing at baseline values
    eq.x    = pvars(1:2);
  end  

  % load socplan eqvars
  if (isstruct(opt))
    seqv = opt.lastseq;
  else
    seqv = load(alg.seqv_file);
  end

  opt.plbeqFunc = zeros(1,length(seqv));
  opt.pubeqFunc = Inf*ones(1,length(seqv));

  % solve socplan eq
  alg.final = 0;
  options = optimset('Display','off','TolX',1e-12,'TolFun',1e-12,'UseParallel','never','TypicalX',seqv,'MaxFunEvals',100);
  [seqfin,seqdiff,exitflag] = fsolve(@socplan_eqfunc,seqv,options);
  if (exitflag <= 0)
    seqfin = zeros(size(opt.lastseq));  
    seqerr = 10000.0;
  else
    alg.final = 1;
    seqnd = socplan_eqfunc(seqfin);
    seqerr = sqrt(mean(seqnd.^2));

  end
  % calculate welfare and cev and output summary
  output();   
  welf = eq.welf;
  cev = eq.cev;

end

