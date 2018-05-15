
% Compile output and create tables
function [] = compileTablesRobustness()
  global alg
  
  %--------------------
  % Targeted moments
  %--------------------
  copyfile(['temp_files' filesep 'moments_format.txt'],['output' filesep 'targeted_moments-' alg.ptag '.txt']);

  %--------------------
  % Policies
  %--------------------
  fileName = ['output' filesep 'policies-' alg.ptag '.txt'];

  list     = {'baseline',...
              'socplanfull',...
              'optpol212'};
  tit      = {'Baseline:',...
              'Social planner, full:',...
              'Optimal incumbent and operating policy:'};                 

  fid      = fopen(fileName,'w');

  for j = 1:length(list)
    fir = fopen(['temp_files' filesep list{j} '-' alg.ptag '.txt']);
    fprintf(fid,'\n');
    fprintf(fid,tit{j});
    fprintf(fid,'\n');
    while (1)
      line = fgets(fir);
      if ~ischar(line)
        break
      end
      fprintf(fid,[line]);
    end
  end

  fclose(fid);
  % clean the temporary file folder
  % system('rm -rf temp_files/*'); 
  disp('Output is compiled. Results are under the folder "Output".');


end