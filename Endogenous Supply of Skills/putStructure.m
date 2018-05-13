function [p] = putStructure(params,names)
    pS = struct();
    for i = 1:length(names)
        p.(char(names(i)))=params(i);
    end
end
    
    



