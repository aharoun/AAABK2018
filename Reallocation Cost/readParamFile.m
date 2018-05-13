function [pvec,names] = readParamFile(fname)

% parsing the parameter values and names given in file 'fname'

  fid = fopen(fname);

  pvec = struct();
  names = {};

  while (1)
    line = fgets(fid);
    if ~ischar(line)
      break
    end

    [name,val] = strtok(line,':');
    name = strtrim(name);
    val = str2num(strtrim(val(2:end)));
    
    names{end+1} = name;
    pvec.(name)  = val;
    
  end

  fclose(fid);

end

