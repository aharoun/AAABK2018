function res = boundaryFRest(ya,yb)
global p eq
res = [ yb(1) - (p.psi/(eq.tau + p.nuHL + p.psi))*eq.PhiHG;...
        yb(2) - (p.psi/(eq.tau + p.nuML + p.psi))*eq.PhiMG ;...
        yb(3) - (p.psi/(eq.tau + p.psi 		   ))*eq.PhiLG - (p.nuML/(eq.tau + p.psi))*yb(2) - (p.nuHL/(eq.tau  + p.psi))*yb(1)];


end
