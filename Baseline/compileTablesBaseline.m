
% Compile output and create tables
function [] = compileTablesBaseline()
  global alg
  
  %--------------------
  % Targeted moments
  %--------------------
  copyfile(['temp_files' filesep 'moments_format.txt'],['output' filesep 'targeted_moments-' alg.ptag '.txt']);

  %--------------------
  % Nontargeted moments
  %--------------------

  fileName = ['output' filesep 'nontargeted_moments-' alg.ptag '.txt'];
  system(['echo NONTARGETED MOMENTS: >>' fileName]);
  system(['cat temp_files' filesep 'non_targetedPanelA-' alg.ptag '.txt >>' fileName]);
  system(['cat temp_files' filesep 'non_targetedPanelB-' alg.ptag '.txt >>' fileName]);
  system(['cat temp_files' filesep 'non_targetedPanelC-' alg.ptag '.txt >>' fileName]);
  system(['cat temp_files' filesep 'non_targetedPanelD-' alg.ptag '.txt >>' fileName]);
  system(['cat temp_files' filesep 'prodLineDist-' alg.ptag '.txt >>' fileName]);
  system(['cat temp_files' filesep 'growthDecomp-' alg.ptag '.txt >>' fileName]);
  
  %--------------------
  % Policies
  %--------------------
  fileName = ['output' filesep 'policies-' alg.ptag '.txt'];
  system(['rm ' fileName]);

  system(['echo Baseline: >>' fileName]);
  system(['cat temp_files' filesep 'baseline-' alg.ptag '.txt >>' fileName]);

  system(['echo Incumbent subsidy 1\%: >>' fileName]);
  system(['cat temp_files' filesep 'incumbent_subs-' alg.ptag '.txt >>' fileName]);

  system(['echo Fixed cost subsidy 1\%: >>' fileName]);
  system(['cat temp_files' filesep 'fixed_subs-' alg.ptag '.txt >>' fileName]);

  system(['echo Entry subsidy 1\%: >>' fileName]);
  system(['cat temp_files' filesep 'entry_subs-' alg.ptag  '.txt >>' fileName]);
  
  system(['echo Social planner, full: >>' fileName]);
  system(['cat temp_files' filesep 'socplanfull-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Social planner, only qmin: >>' fileName]);
  system(['cat temp_files' filesep 'socplanonlyQmin-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Social planner, only innovation: >>' fileName]);
  system(['cat temp_files' filesep 'socplanonlyX-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Optimal incumbent policy: >>' fileName]);
  system(['cat temp_files' filesep 'optpol11-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Optimal operating policy: >>' fileName]);
  system(['cat temp_files' filesep 'optpol12-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Optimal entrant policy: >>' fileName]);
  system(['cat temp_files' filesep 'optpol13-' alg.ptag '.txt >>' fileName]);
  
  system(['echo Optimal incumbent and operating policy: >>' fileName]);
  system(['cat temp_files' filesep 'optpol212-' alg.ptag '.txt >>' fileName]);

  % clean the temporary file folder
  % system('rm -rf temp_files/*'); 
  disp('Output is compiled. Results are under the folder "Output".');


end