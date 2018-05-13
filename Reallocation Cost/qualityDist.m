% Quality distributions
function qualityDist
    global alg p eq

    %% -1 - Parameters for delayed differential equation
    p.alphaDelay = 1/(1 + (p.lam-1)*(1 - p.omega));
    p.betaDelay  = (p.lam - 1)*p.omega*eq.qbar*p.alphaDelay;  


    %% 0 - Growth rate consistent with guessed qbar
    eq.g         = eq.tau*(p.lam-1);

    %% 1 - Overall dist.
    eq.solFAll     = ddesd(@funcFAll,@delayFAll,@dhist,[alg.qMinAll,alg.qMaxAll],alg.optDD); 

    % Normalize
    eq.solFAll.yp  = eq.solFAll.yp./eq.solFAll.y(end);
    eq.solFAll.y   = eq.solFAll.y./eq.solFAll.y(end);


    %% 2 - Gross dist.
    initBVPFH = bvpinit(linspace(alg.qMinAll,alg.qMaxAll,20),.1);
    eq.solFH  = bvp4c(@funcFH,@boundaryFH,initBVPFH,alg.optBVP);


    eq.PhiHG = eq.solFH.y(end);
    eq.PhiLG = 1 - eq.solFH.y(end);

    %% 3 - Active product line dist.
    initBVPFRest = bvpinit(linspace(alg.qMinAll,alg.qMaxAll,20),ones(2,1)*.1);
    eq.solFRest  = bvp4c(@funcFRest,@boundaryFRest,initBVPFRest,alg.optBVP);

    %% 4 - Update PhiL and PhiH
    [FRestcut,fRestcut]    = deval(eq.solFRest,max(alg.qMinAll,eq.qmin));
    [FHcut,fHcut]    	   = deval(eq.solFH,   max(alg.qMinAll,eq.qmin));
    [eq.FAllcut,fAllcut]   = deval(eq.solFAll, max(alg.qMinAll,eq.qmin));	


    eq.PhiHExo   = eq.solFRest.y(1,end);
    eq.PhiLExo   = eq.solFRest.y(2,end);

    eq.PhiHObso  = FHcut(2) - FRestcut(1,2) ;
    eq.PhiLObso  = (eq.FAllcut(1) - FHcut(1)) - FRestcut(2,1) ;
    eq.qdropHigh = eq.g*eq.qmin(2)*(fHcut(2) - fRestcut(1,2));
    eq.qdropLow  = eq.g*eq.qmin(1)*((fAllcut(1) - fHcut(1)) - fRestcut(2,1));


    eq.cactiv(1) = (eq.PhiLG - eq.PhiLExo) - eq.PhiLObso;
    eq.cactiv(2) = (eq.PhiHG - eq.PhiHExo) - eq.PhiHObso;
    eq.cactivtot = sum(eq.cactiv);
    eq.cinac     = 1.0 - eq.cactivtot;


end

