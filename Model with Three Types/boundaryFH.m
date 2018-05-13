function res = boundaryFH(ya,yb)
global p eq
res = yb - eq.taus(3)/(eq.tau + p.nuHL);

end
