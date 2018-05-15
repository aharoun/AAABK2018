function v = funcFM(t,y)
global  eq p alg

delayT 	= max(alg.qMinAll,p.alphaDelay*t - p.betaDelay);
FDelay 	= deval(eq.solFAll,delayT);

v 	= ((eq.tau+p.nuML)./(eq.g.*t)).*y(1,:) - (eq.taus(2)./(eq.g.*t)).*FDelay;                    % FM
                                     

end