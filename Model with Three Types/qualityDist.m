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
    % High type
    initBVPFH = bvpinit(linspace(alg.qMinAll,alg.qMaxAll,20),.1);
    eq.solFH  = bvp4c(@funcFH,@boundaryFH,initBVPFH,alg.optBVP);

    % Medium type
    initBVPFM = bvpinit(linspace(alg.qMinAll,alg.qMaxAll,20),.1);
    eq.solFM  = bvp4c(@funcFM,@boundaryFM,initBVPFM,alg.optBVP);


    eq.PhiHG = eq.solFH.y(end);
    eq.PhiMG = eq.solFM.y(end);
    eq.PhiLG = 1.0 - eq.PhiHG - eq.PhiMG;

    %% 3 - Active product line dist.
    initBVPFRest = bvpinit(linspace(alg.qMinAll,alg.qMaxAll,20),ones(3,1)*.1);
    eq.solFRest  = bvp4c(@funcFRest,@boundaryFRest,initBVPFRest,alg.optBVP);

    %% 4 - Update PhiL and PhiM and PhiH
    [FRestcut,fRestcut]    = deval(eq.solFRest,max(alg.qMinAll,eq.qmin));
    [FHcut,fHcut]          = deval(eq.solFH,   max(alg.qMinAll,eq.qmin));
    [FMcut,fMcut]          = deval(eq.solFM,   max(alg.qMinAll,eq.qmin));
    [FAllcut,fAllcut]      = deval(eq.solFAll, max(alg.qMinAll,eq.qmin));   

    eq.PhiHExo   = eq.solFRest.y(1,end);
    eq.PhiMExo   = eq.solFRest.y(2,end);
    eq.PhiLExo   = eq.solFRest.y(3,end);

    eq.PhiHObso  = FHcut(3)                             - FRestcut(1,3);
    eq.PhiMObso  = FMcut(2)                             - FRestcut(2,2);
    eq.PhiLObso  = (FAllcut(1) - FHcut(1) - FMcut(1))   - FRestcut(3,1) ;

    eq.qdropHigh = eq.g*eq.qmin(3)*(fHcut(3)                            - fRestcut(1,3));
    eq.qdropMedi = eq.g*eq.qmin(2)*(fMcut(2)                            - fRestcut(2,2));
    eq.qdropLow  = eq.g*eq.qmin(1)*((fAllcut(1) - fHcut(1)- fMcut(1))   - fRestcut(3,1));


    eq.cactiv(1) = max(0,(eq.PhiLG - eq.PhiLExo) - eq.PhiLObso);
    eq.cactiv(2) = max(0,(eq.PhiMG - eq.PhiMExo) - eq.PhiMObso);
    eq.cactiv(3) = max(0,(eq.PhiHG - eq.PhiHExo) - eq.PhiHObso);

    eq.cactivtot = sum(eq.cactiv);
    eq.cinac     = 1.0 - eq.cactivtot;

end

