% calculate average quality of active product lines
function qbarActive
global  p eq alg

% qBarAct update
out = funQbarAct(alg.chebBin);
eq.qbarAct  = sum(alg.w'*out(:,1:2));
eq.qPlusEps = (alg.w'*out(:,3:4))./[1 - eq.FAllcut];



function outFinal = funQbarAct(x)
        [~,outRest]  = deval(eq.solFRest,x);
        [~,outFH]    = deval(eq.solFH,x);
        [~,outFAll]  = deval(eq.solFAll,x);
        
        out1L = ((outFAll - outFH) - outRest(2,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(1));
        out1H = (outFH - outRest(1,:))'            .*(x.^(p.eps-1)).*(x>=eq.qmin(2));

        out2L = (outFAll)'.*((x + (p.lam-1)*eq.qbar).^(p.eps-1)).*(x>=(eq.qmin(1)-(p.lam-1)*eq.qbar));
        out2H = (outFAll)'.*((x + (p.lam-1)*eq.qbar).^(p.eps-1)).*(x>=(eq.qmin(2)-(p.lam-1)*eq.qbar));

        outFinal = [out1L out1H out2L out2H];
end

end

