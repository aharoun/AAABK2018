function res = boundaryFH(ya,yb)
global p eq
res = yb - eq.taus(2)/(eq.tau + p.nu); ...
end
