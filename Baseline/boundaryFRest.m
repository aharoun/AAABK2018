function res = boundaryFRest(ya,yb)
global p eq
res = [ yb(1) - (p.psi/(eq.tau + p.nu + p.psi))*eq.PhiHG;...
        yb(2) - (p.psi/(eq.tau + p.psi))*eq.PhiLG - (p.nu/(eq.tau + p.psi))*yb(1)];


end
