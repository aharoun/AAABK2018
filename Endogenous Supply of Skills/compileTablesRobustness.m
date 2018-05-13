
% Compile output and create tables
function [] = compileTablesRobustness()
  global alg
  
  %--------------------
  % Targeted moments
  %--------------------
  system(['cp temp_files/moments_format.txt output/targeted_moments_' alg.ptag '.txt']);

  %--------------------
  % Policies
  %--------------------
  fileName = ['output/policies_' alg.ptag '.txt'];
  system(['rm ' fileName]);

  system(['echo Baseline: >>' fileName]);
  system(['cat temp_files/baseline.txt >>' fileName]);

  system(['echo Optimal education policy: >>' fileName]);
  system(['cat temp_files/optpolEduOnly-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Social planner, full: >>' fileName]);
  system(['cat temp_files/socplanfull-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Optimal incumbent and operating policy: >>' fileName]);
  system(['cat temp_files/optpol212-' alg.ptag '.txt >>' fileName]);

  % clean the temporary file folder
  % system('rm -rf temp_files/*'); 
  disp('Output is compiled. Results are under the folder "Output".');


end