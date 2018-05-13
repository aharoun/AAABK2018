% calculate average quality of active product lines
function qbarActive
global  p eq alg

% qBarAct update
eq.qbarAct  = sum(alg.w'*funQbarAct(alg.chebBin));



function out2 = funQbarAct(x)
        [~,outRest]  = deval(eq.solFRest,x);
        [~,outFM]    = deval(eq.solFM,x);
        [~,outFH]    = deval(eq.solFH,x);
        [~,outFAll]  = deval(eq.solFAll,x);
        
        outL = (outFAll - outFH - outFM - outRest(3,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(1));
        outM = (outFM                   - outRest(2,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(2));
        outH = (outFH                   - outRest(1,:))'.*(x.^(p.eps-1)).*(x>=eq.qmin(3));
        out2 = [outL outM outH];
end


end


