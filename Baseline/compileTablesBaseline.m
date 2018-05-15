
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
  list     = {'non_targetedPanelA','non_targetedPanelB','non_targetedPanelC','non_targetedPanelD',...
              'prodLineDist','growthDecomp'};

  fid      = fopen(fileName,'w');

  for j = 1:length(list)
    fir = fopen(['temp_files' filesep list{j} '-' alg.ptag '.txt']);
    while (1)
      line = fgets(fir);
      if ~ischar(line)
        break
      end
      fprintf(fid,[line]);
    end
  end

  fclose(fid);
  
  %--------------------
  % Policies
  %--------------------
  fileName = ['output' filesep 'policies-' alg.ptag '.txt'];
  list     = {'baseline','incumbent_subs','fixed_subs','entry_subs',...
              'socplanfull','socplanonlyQmin','socplanonlyX',...
              'optpol11','optpol12','optpol13','optpol212'};
  tit      = {'Baseline:','Incumbent subsidy 1%%:','Fixed cost subsidy 1%%:','Entry subsidy 1%%:',...
              'Social planner, full:','Social planner, only qmin:','Social planner, only innovation:',...
              'Optimal incumbent policy:','Optimal operating policy:','Optimal entrant policy:','Optimal incumbent and operating policy:'};                 

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