% One percent policies 
function run_pols()
  global pol alg

  cost_targ = 0.01;   
  fprintf('Subsidy Policies in %2.1f%% of GDP\n',cost_targ*100)

  % baseline
  initpol();
  solver();
  copyfile(['temp_files' filesep 'policy.txt'],['temp_files' filesep 'baseline.txt']);



  fprintf('   Incumbent subsidy...')
  bin_search('inc_subs',0.14,cost_targ);
  copyfile(['temp_files' filesep 'policy.txt'],['temp_files' filesep 'incumbent_subs-' alg.ptag '.txt']);
  fprintf('Done!\n')
  
  fprintf('   Operation subsidy...')
  bin_search('fixed_subs',0.04,cost_targ);
  copyfile(['temp_files' filesep 'policy.txt'],['temp_files' filesep 'fixed_subs-' alg.ptag '.txt']);
  fprintf('Done!\n')

  fprintf('   Entry subsidy...')
  bin_search('ent_subs',0.65,cost_targ);
  copyfile(['temp_files' filesep 'policy.txt'], ['temp_files' filesep 'entry_subs-' alg.ptag '.txt']);
  fprintf('Done!\n')
  fprintf('---\n')

  % reset policy
  initpol();
end

function bin_search(pol_type,max_init,cost_targ)
  % Bisection for finding subsidy rate
  global pol

  function cost_out = cost_obj(pol_val)
    initpol();
    pol = setfield(pol,pol_type,pol_val);
    solver();
    cost_out = getfield(pol.cost,pol_type);
  end

  x0 = 0.0;
  y0 = 0.0;

  x1 = max_init;
  y1 = cost_obj(x1);

  x2 = x0+(cost_targ-y0)*(x1-x0)/(y1-y0);
  y2 = cost_obj(x2);

  while (abs(y2-cost_targ) > 0.0001)
    if (y2 < cost_targ)
      x0 = x2;
      y0 = y2;
    else
      x1 = x2;
      y1 = y2;
    end

    x2 = x0+(cost_targ-y0)*(x1-x0)/(y1-y0);
    y2 = cost_obj(x2);
  
  end

end
