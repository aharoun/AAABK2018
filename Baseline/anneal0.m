% [xmin,fmin] = anneal0(fun,x0,scale,maxiter)
function [xmin,fmin] = anneal0(fun,x0,varargin)
  if (nargin >= 3)
    scale = varargin{1};
  else
    scale = 0.25;
  end
  if (nargin >= 4)
    maxiter = varargin{2};
  else
    maxiter = 1000000;
  end

  afid = fopen(['temp_files' filesep 'anneal.txt'],'w+');

  sz = size(x0);
  xp = x0;
  fp = fun(x0);
  xmin = xp;
  fmin = fp;

  stay = 0;
  fprintf(afid,'SCALE -> %16.12f\n',scale);
  for i=1:maxiter
    xp = xmin.*exp(scale*randn(sz));
    try
      fp = fun(xp);
    catch err
      fp = Inf;
    end

    if (fp < fmin)
      xmin = xp;
      fmin = fp;
      fprintf(afid,'MIN: '); fprintf(afid,'%16.12f,',xmin); fprintf(afid,' -> %16.12f\n',fmin);

      stay = 0;
    else
      if (~isinf(fp))
        stay = stay + 1;
      end
    end

    if (stay == 50)
      scale = 0.5*scale;
      fprintf(afid,'SCALE -> %16.12f\n',scale);
      stay = 0;
    end

    if (scale < 1.0e-5)
      break;
    end
  end
end

