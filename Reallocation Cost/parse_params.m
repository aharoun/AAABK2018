function [pvec,names] = parse_params(fname)

% parsing the parameter values and names given in file 'fname'

  fid = fopen(fname);

  pvec = [];
  names = {};

  while (1)
    line = fgets(fid);
    if ~ischar(line)
      break
    end

    [name,val] = strtok(line,':');
    name = strtrim(name);
    val = str2num(strtrim(val(2:end)));

    pvec(end+1) = val;
    names{end+1} = name;
  end

  fclose(fid);

end

