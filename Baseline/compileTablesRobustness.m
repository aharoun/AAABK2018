
% Compile output and create tables
function [] = compileTablesRobustness()
  global alg
  
  %--------------------
  % Targeted moments
  %--------------------
  system(['cp temp_files' filesep 'moments_format.txt output' filesep 'targeted_moments-' alg.ptag '.txt']);

  %--------------------
  % Policies
  %--------------------
  fileName = ['output' filesep 'policies-' alg.ptag '.txt'];
  system(['rm ' fileName]);

  system(['echo Baseline: >>' fileName]);
  system(['cat temp_files' filesep 'baseline-' alg.ptag '.txt >>' fileName]);

  
  system(['echo Social planner, full: >>' fileName]);
  system(['cat temp_files' filesep 'socplanfull-' alg.ptag '.txt >>' fileName]);
  
  
  system(['echo Optimal incumbent and operating policy: >>' fileName]);
  system(['cat temp_files' filesep 'optpol212-' alg.ptag '.txt >>' fileName]);

  % clean the temporary file folder
  % system('rm -rf temp_files/*'); 
  disp('Output is compiled. Results are under the folder "Output".');


end