function d = delayFAll(t,y)
global p

d = p.alphaDelay*t - p.betaDelay;

end