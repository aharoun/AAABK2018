% Gauss-Chebyshev quadrature
function [nodes,w] = gaussCheb(nNodes,t0,tEnd)

    nodes = (tEnd + t0)/2 - (tEnd - t0)/2*cos(pi/nNodes*(0.5:(nNodes-0.5))');
    w     = ((tEnd - t0)/nNodes)*(cos(pi/nNodes*((1:nNodes)'-0.5)*(0:2:nNodes-1))*[1;-2./((1:2:nNodes-2).*(3:2:nNodes))']);

end