% calculate average quality of active product lines
function qbarActive
global  p eq alg

eq.qbarAct  = sum(alg.w'*funQbarAct(alg.chebBin));


function out2 = funQbarAct(x)
        [~,outRest]  = deval(eq.solFRest,x);
        [~,outFH]    = deval(eq.solFH,x);
        [~,outFAll]  = deval(eq.solFAll,x);
        
        outL = ((outFAll - outFH) - outRest(2,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(1));
        outH = (outFH - outRest(1,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(2));
        out2 = [outL outH];
end

end

