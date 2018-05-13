% Saving parameters with filename 'fname'
function writeParams(fname,pvec)
  global alg

 [~,pNames] = parse_params(alg.prm_file);

  np   = length(pNames);
  fpid = fopen(fname,'w');
  for i = 1:np
    fprintf(fpid,'%10s : %18.15f\n',pNames{i},pvec(i));
  end

  fclose(fpid);

end

