function v = funcFRest(t,y)
global  eq p 


FH    = deval(eq.solFH,t);
FM    = deval(eq.solFM,t);
FAll  = deval(eq.solFAll,t);


v  = [((eq.tau + p.nuHL + p.psi)./(eq.g.*t)).*y(1,:) 	- (p.psi./(eq.g.*t)).*FH;...
      ((eq.tau + p.nuML + p.psi)./(eq.g.*t)).*y(2,:) 	- (p.psi./(eq.g.*t)).*FM;...
      ((eq.tau + p.psi)			./(eq.g.*t)).*y(3,:) 	- (p.psi./(eq.g.*t)).*(FAll - FH - FM) 	- (p.nuML./(eq.g.*t)).*y(2,:) - (p.nuHL./(eq.g.*t)).*y(1,:)];

end
