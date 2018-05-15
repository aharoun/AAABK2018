function v = funcFRest(t,y)
    global  eq p 

    FH    = deval(eq.solFH,t);
    FAll  = deval(eq.solFAll,t);

    v  = [((eq.tau + p.nu + p.psi)./(eq.g.*t)).*y(1,:) - (p.psi./(eq.g.*t)).*FH;...
         ((eq.tau+p.psi)./(eq.g.*t)).*y(2,:) - (p.psi./(eq.g.*t)).*(FAll - FH) - (p.nu./(eq.g.*t)).*y(1,:)];

end
