function v = funcFAll(t,y,Z)
global  eq
v = (eq.tau./(eq.g*t))*y(1) - (eq.tau./(eq.g*t))*Z(1);
end